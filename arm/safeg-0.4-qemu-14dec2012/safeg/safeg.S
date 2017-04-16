/*
 *  TOPPERS/SafeG Dual-OS monitor
 *      Toyohashi Open Platform for Embedded Real-Time Systems/
 *      Safety Gate Dual-OS monitor
 *
 *  Copyright (C) 2009-2011 by Embedded and Real-Time Systems Laboratory
 *     Graduate School of Information Science, Nagoya University, JAPAN
 *
 *  上記著作権者は，以下の(1)〜(4)の条件を満たす場合に限り，本ソフトウェ
 *  ア（本ソフトウェアを改変したものを含む．以下同じ）を使用・複製・改
 *  変・再配布（以下，利用と呼ぶ）することを無償で許諾する．
 *  (1) 本ソフトウェアをソースコードの形で利用する場合には，上記の著作
 *      権表示，この利用条件および下記の無保証規定が，そのままの形でソー
 *      スコード中に含まれていること．
 *  (2) 本ソフトウェアを，ライブラリ形式など，他のソフトウェア開発に使
 *      用できる形で再配布する場合には，再配布に伴うドキュメント（利用
 *      者マニュアルなど）に，上記の著作権表示，この利用条件および下記
 *      の無保証規定を掲載すること．
 *  (3) 本ソフトウェアを，機器に組み込むなど，他のソフトウェア開発に使
 *      用できない形で再配布する場合には，次のいずれかの条件を満たすこ
 *      と．
 *    (a) 再配布に伴うドキュメント（利用者マニュアルなど）に，上記の著
 *        作権表示，この利用条件および下記の無保証規定を掲載すること．
 *    (b) 再配布の形態を，別に定める方法によって，TOPPERSプロジェクトに
 *        報告すること．
 *  (4) 本ソフトウェアの利用により直接的または間接的に生じるいかなる損
 *      害からも，上記著作権者およびTOPPERSプロジェクトを免責すること．
 *      また，本ソフトウェアのユーザまたはエンドユーザからのいかなる理
 *      由に基づく請求からも，上記著作権者およびTOPPERSプロジェクトを
 *      免責すること．
 *
 *  本ソフトウェアは，無保証で提供されているものである．上記著作権者お
 *  よびTOPPERSプロジェクトは，本ソフトウェアに関して，特定の使用目的
 *  に対する適合性も含めて，いかなる保証も行わない．また，本ソフトウェ
 *  アの利用により直接的または間接的に生じたいかなる損害に関しても，そ
 *  の責任を負わない．
 *
 */
#define  TOPPERS_MACRO_ONLY

#include "arm.h"
#include "safeg.h"
#include "safeg_syscalls.h"
#include "safeg_measures.h"

/*
 * -----------------
 * Workspace Offsets
 * -----------------
 * Offsets within the workspace
 */

/*
 * Offset to first banked registers from sp_mon.
 * Calculated using the N World Workspace but values are the same for S World.
 */
#define BankedOffset    (N_IRQ_SPSR_CORE0 - NtContextBase0)

/*
 * --------------------
 * Workspace Constants
 * --------------------
 */

#define WORKSPACE_RESET_VALUE   0x0

/*
 * Interrupt Related Constants
 */
#define HIGHVEC_IRQADR        0xffff0018

/*
 * NORMAL_CPSR_INIT_VALUE
 */
#define NORMAL_CPSR_INIT_VALUE CPSR_BIT_8_A | CPSR_BIT_7_I | CPSR_MODE_SVC

/*
 * NORMAL CP15 CTRL レジスタのリセット時の値
 */
#define NORMAL_CP15_CTRL_INIT_VALUE 0x50078

/*
 * ----------------
 * MACRO: SaveState
 * ----------------
 * Saves registers to the workspace sp points into.
 * Corrupts r6, r7, r12
 * Trust状態(SCRのNSビットが0)で呼びだすこと.
 *
 * ToDo : 引数でコア指定ができるようにする
 */
    .macro SaveState
        stmdb   sp, {r0-lr}^
        add     r6, sp, #BankedOffset
        cps     #CPSR_MODE_IRQ
        mrs     r12, spsr
        stmia   r6!, {r12-lr}
        cps     #CPSR_MODE_SVC
        mrs     r12, spsr
        stmia   r6!, {r12-lr}
        cps     #CPSR_MODE_ABORT
        mrs     r12, spsr
        stmia   r6!, {r12-lr}
        cps     #CPSR_MODE_UNDEF
        mrs     r12, spsr
        stmia   r6!, {r12-lr}
        cps     #CPSR_MODE_FIQ
        mrs     r7, spsr
        stmia   r6, {r7-lr}
        cps     #CPSR_MODE_MONITOR
    .endm

/*
 * ----------------
 * MACRO: LoadState
 * ----------------
 * SPは呼び出したいコンテキストの場所を指していること.
 * Trust状態(SCRのNSビットが0)で呼びだすこと.
 * 終了後はモニタモードになっており, レジスタには各コンテキストの内容が復帰しているため,
 * LR_mon, SP_monのみ使用可能.
 *
 * ToDo : 引数でコア指定ができるようにする
 */

    .macro LoadState
        add     r6, sp, #BankedOffset
        cps     #CPSR_MODE_IRQ
        ldmia   r6!, {r12-lr}
        msr     spsr_fsxc, r12
        cps     #CPSR_MODE_SVC
        ldmia   r6!, {r12-lr}
        msr     spsr_fsxc, r12
        cps     #CPSR_MODE_ABORT
        ldmia   r6!, {r12-lr}
        msr     spsr_fsxc, r12
        cps     #CPSR_MODE_UNDEF
        ldmia   r6!, {r12-lr}
        msr     spsr_fsxc, r12
        cps     #CPSR_MODE_FIQ
        ldmia   r6, {r7-lr}
        msr     spsr_fsxc, r7
        cps     #CPSR_MODE_MONITOR
        ldmdb   sp, {r0-lr}^
    .endm

    // マクロ GetContextBase :
    //        自プロセッサのコンテキストエリアアドレスを取得する
    //        context : ContextBase name
    //        sp <= [Address of ContextAreaBase]
    .macro GetContextBase context
#if TNUM_PRC == 1
       ldr sp, =\context
#else /* TNUM_PRC > 1 */
        set_smm_stack
        sub sp, sp, #4
        stmfd sp!, {r0, r1} /* r0, r1を保存 */

        // 自プロセッサのコンテキストベースアドレスを取得
        get_prcid r0
        ldr r1, =Table_\context
        ldr r0, [r1, r0, asl #2] /* r0 <= table[cpu_id] */

        str r0, [sp, #8] /* r0,r1の下にContextBaseのアドレスを入れる */
        ldmfd sp!, {r0, r1} /* r0, r1を復帰 */
        ldr sp, [sp]
#endif /* TNUM_PRC == 1 */
    .endm

    // マクロ GetContextBase_reg :
    //        自プロセッサのコンテキストエリアアドレスを取得する(スクラッチレジスタあり)
    //        table   : ContextAreaBase name
    //        ret_reg : register which return [Address of ContextAreaBase]
    //        tmp_reg : temporary register
    .macro GetContextBase_reg context, ret_reg, tmp_reg
#if TNUM_PRC == 1
       ldr \ret_reg, =\context
#else /* TNUM_PRC > 1 */
        get_prcid \ret_reg
        ldr \tmp_reg, =Table_\context
        ldr \ret_reg, [\tmp_reg, \ret_reg, asl #2] 
#endif /* TNUM_PRC == 1 */
    .endm

/*
 * ----------------------------------------------------------------------------
 * ===============
 * モニタベクタ
 * ===============
 *
 * tableを作成して, ベクタは0番地に配置する
 */
    .section .vector, "a"
    .align 5
    .globl MonitorVectorTableBase
MonitorVectorTableBase:
    ldr pc, reset_vector       /* リセット             */
    ldr pc, undef_vector       /* 未定義命令           */
    ldr pc, smc_vector         /* SMC                  */
    ldr pc, prefech_vector     /* プリフェッチアボート */
    ldr pc, data_abort_vector  /* データアボート       */
    ldr pc, reset_vector       /* 予約                 */
    ldr pc, irq_vector         /* IRQ                  */
    ldr pc, fiq_vector         /* FIQ                  */

/*
 *  例外ベクタの命令から参照される
 *  ジャンプ先アドレス
 */
    .global monitor_vector_ref_tbl
monitor_vector_ref_tbl:
reset_vector:
    .long   _start
undef_vector:
    .long   disaster
smc_vector:
    .long   smc_handler
prefech_vector:
    .long   disaster
data_abort_vector:
    .long   data_abort_handler
irq_vector:
    .long   irq_handler
fiq_vector:
    .long   fiq_handler
disaster: //error handling
    b   disaster

/*
 *-----------------------------------------------------------------------------
 * ===========
 * IRQ Handler
 *
 * IRQはNon Trusted側からしか来ないと仮定している
 * モニタモード, IRQ/FIQ禁止で呼び出される.
 * IRQ の処理をしている間にFIQやSMCが入ることがあるので,
 * IRQ 用のスタックだけは別にする.
 *
 * H ┌──────────┐offset
 *   │ジャンプ先 │+0x14 _smm_stack
 *   │ip        │+0x10
 *   │r3        │+0x0c
 *   │r2        │+0x08
 *   │r1        │+0x04
 * sp│r0        │+0x00
 * L └──────────┘
 * ===========
 */
    .text
    .align 5
    .global irq_handler
irq_handler:
    /* 発生元のワールドを判断し, Trustから来たときの対応をここでする */
    CP15_SCR_READ sp
    tst sp, #SCR_BIT_0_NS
    beq trusted_irq                 // trustからの場合, trusted_irqへジャンプ

    /* スタックを切り替えて, コンテキストを保存する.
     * fdでそのまま積んでもプリデクリメントのため一番上は空く.
     */
    set_smm_stack
    stmfd sp!, {r0-r1}

#if (SAFEG_MEASURE_IRQ_OVH == 1) || (LINUX_MEASURE_TIMER_LAT == 1)
    perfmon_start r0
#endif /* SAFEG_MEASURE_IRQ_OVH */

    /*
     * NT側のベクタテーブルの読み出し.
     * SCRのNSビットが1の状態で読み出す必要がある.
     * (NT側のMMUを利用したいため).
     */
    CP15_CONTROL_READ r0
    tst r0, #CP15_CONTROL_V_BIT

    /* high vector の場合は r0 に HIGHVEC_IRQ を読み込む */
    ldrne r0, =HIGHVEC_IRQADR
    bne highvec

    /* high vector でない場合 */
    CP15_VBAR_READ r0                // check non-secure irq vector address
    add r0, r0, #0x18                // IRQベクタのアドレスは vectorbase + 0x18
highvec:
    /*
     * ここまではNSで実行する必要がある.
     * SCRのNSビットを0にしておく.
     * (モード切替を行うため).
     */
    mov r1, #SCR_S
    CP15_SCR_WRITE r1

    /*
     * このハンドラが終わった後にジャンプする実際のベクタアドレスを保存.
     * 保存するレジスタ群が変わるとオフセットが変わるので注意すること.
     *
     * Note: the stack after "stmfd sp!, {r0-r1}" is like this:
     *
     *                                 +------------------+ high address
     * _smm_stack = old_sp = sp + 8 -> |      xxx         |
     *                       sp + 4 -> |      r1          |     ↓
     *                       sp + 0 -> |      r0          |
     *                                 +------------------+ low address
     *
     * The xxx space is there because we used "!" which increments the
     * stack pointer before. Now we will do: xxx = r0 = irq handler address
     */
    str r0, [sp, #8]

    /*
     * NT側の割込みハンドラを改変せずに済むように,
     * lr_mon, spsr_mon を lr_irq, spsr_irq に移す
     */
    mov r0, lr                       //[r0] = lr_mon
    mrs r1, spsr                     //[r1] = spsr_mon
    cps #CPSR_MODE_IRQ
    mov lr, r0                       // lr_irq = lr_mon
    msr spsr_cxsf, r1                // spsr_irq = spsr_mon
    cps #CPSR_MODE_MONITOR

    /* NT 側の IRQ ベクタを呼び出すための準備 */
    mov r1, #SCR_NS
    CP15_SCR_WRITE r1

    /* spsr が IRQ モードとなるような設定をする */
    mov r0, #(CPSR_MODE_IRQ | CPSR_BIT_7_I)
    msr spsr_fsxc, r0

#ifdef ENABLE_IRQ_HOOK
   /* Call IRQ hook, sp is smm_stack */
    stmfd sp!, {r2-r3, ip}
    bl irq_hook
    ldmfd sp!, {r2-r3, ip}
#endif /* ENABLE_IRQ_HOOK */

#if SAFEG_MEASURE_IRQ_OVH == 1
    stmfd sp!, {r2}
    perfmon_end r0, r1, r2
    ldmfd sp!, {r2}
#endif /* SAFEG_MEASURE_IRQ_OVH */

    /* NT 側の IRQ ベクタにジャンプ */
    ldmfd sp!, {r0-r1, pc}^

   /*
    * trusted_irq の場合の処理を行う.
    * 独自に処理を行いたい場合には, trusted_irq_handler に定義する.
    */
trusted_irq:
    ldr r0, =trusted_irq_handler
    ldr r0, [r0]
    cmp r0, #0
    movne pc, r0
    b   disaster

/*
 *-----------------------------------------------------------------------------
 * ===========
 * FIQ handler
 * ===========
 */
    .text
    .align 5
    .global fiq_handler
fiq_handler:
    /* 割込み発生元のワールドの判定 */
    /* Note: r13=sp and r14=lr are banked in monitor mode */
    CP15_SCR_READ sp
    tst sp, #SCR_BIT_0_NS
    bne non_trusted_fiq

    /* secureから来た場合 */
trusted_fiq:
    /* save trust r0-r1 registers in SafeG stack cause we need to use them */
    set_smm_stack
    stmfd sp!, {r0-r1}

#if SAFEG_MEASURE_FIQ_FIQ == 1
    perfmon_start r0
#endif /* SAFEG_MEASURE_FIQ_FIQ */

    /*
     * T側の割込みハンドラを改変せずに済むように,
     * lr_mon, spsr_mon を lr_irq, spsr_irq に移す
     */
    mov r0, lr
    mrs r1, spsr
    cps #CPSR_MODE_IRQ
    mov lr, r0
    msr spsr_fsxc, r1
    cps #CPSR_MODE_MONITOR
    ldmfd sp!, {r0-r1}
    b fiq_exit

    /* non-secureから来た場合 */
non_trusted_fiq:
    /* SaveStateの前にSCRをsecureに変更 */
    mov sp, #SCR_S
    CP15_SCR_WRITE sp
    /* 割込みで入ってきたので, 戻り先アドレスはLRから4減らした値になる */
    sub lr, lr, #4

    /* save non-trust pc and spsr to monitor stack */
    /* sp <= NtContextBase */
    GetContextBase NtContextBase

    srsia #CPSR_MODE_MONITOR
    /* save the rest of non-trust registers */
    SaveState

#ifdef ENABLE_NT2T_HOOK
    /* call NT2T hook, sp is smm_stack */
    set_smm_stack
    bl nt2t_hook
#endif /* ENABLE_NT2T_HOOK */

    /*
     * LoadState をする前にIRQモードの内容も入れ替わるので書き換え前に行う.
     * LoadState で復帰されるコンテキストは, 前回の SMC 実行時に保存されたもの
     * であるため, IRQハンドラで使用するために事前に 4 を足しておく.
     * Trust側でIRQハンドラが終わった後に返るための SPSR_irq, LR_irq を
     * IRQモードに設定しておく.
     */
    /* sp <= TContextBase */
    GetContextBase TContextBase

    ldmfd sp, {r0, r1} // 前回SMCを呼び出した時点の pc, cpsr.
    add r0, r0, #4
    str r1, [sp, #0xc]
    str r0, [sp, #0x14]
    LoadState

    /* Prepare stack to store CPSR and PC before returning with rfeia*/
    set_smm_stack

/*
 * secureに必ず抜けるので、ここにはSCRはsecureでくる.
 * rfeiaで戻るためにスタックにCPSRとPCを積む.
 */
fiq_exit:
#ifdef ENABLE_FIQ_HOOK
    stmfd sp!, {r0-r3, ip}
    bl fiq_hook
    ldmfd sp!, {r0-r3, ip}
#endif /* ENABLE_FIQ_HOOK */
    /* push CPSR = (IRQ and FIQ disabled) + IRQ mode */
    mov lr, #(CPSR_MODE_IRQ | CPSR_BIT_6_F | CPSR_BIT_7_I)
    str lr, [sp, #-4]!
    /* IRQベクタのアドレスはvectorbase + 0x18 */
    CP15_VBAR_READ lr
    add lr, lr, #0x18
    str lr, [sp, #-4]!
    /* IRQモードに切り替え (load CPSR + PC from stack) T側の IRQベクタにジャンプ */
    rfeia sp

/*
 * ===========
 * SMC handler
 * ===========
 */
    .text
    .align 5
    .global smc_handler
smc_handler:
    /* check if it is a Trust or Non-Trust SMC (NS bit) */
    CP15_SCR_READ sp
    tst sp, #SCR_BIT_0_NS

    /* if is Non-Trust SMC jump to nt_smc_handler */
    bne nt_smc_handler

    /* check whether swith to NT */
    cmp r0, #T_SMC_SWITCH
    beq t_smc_swich

t_smc_handler:
    /* Call syscall function*/
    set_smm_stack
    stmfd sp!, {r0-r3, ip, lr}
    adr   lr, t_smc_handler_exit

    cmp r0, #T_SMC_REBOOT
    beq t_smc_reboot

#ifdef DUALOSCOM_FIFO_SUPPORT
    cmp r0, #T_SMC_FIFO_WRITE
    beq c_safeg_fifo_write

    cmp r0, #T_SMC_FIFO_READ
    beq  c_safeg_fifo_read
#endif /* DUALOSCOM_FIFO_SUPPORT */

#ifdef PROF_SUPPORT
    cmp r0, #T_SMC_PROF_INIT
    moveq r0, r1
    beq c_smc_prof_init

    cmp r0, #T_SMC_PROF_GET
    moveq r0, r1
    beq c_smc_prof_get

    cmp r0, #T_SMC_PROF_GET_PTR
    moveq r0, r1
    beq c_smc_prof_get_ptr
#endif /* PROF_SUPPORT */

t_smc_handler_exit:
   ldmfd sp!, {r0-r3, ip, lr}
   movs  pc, lr

    /* Swith to NT */
t_smc_swich:
    /*first we save the Trust context */
    /* sp <= TContextBase */
    GetContextBase TContextBase
    srsia   #CPSR_MODE_MONITOR  // [sp_mon] = lr_mon, [sp_mon, #4] = spsr_mon
    SaveState                   // S-Context = Context

#ifdef ENABLE_T2NT_HOOK
    set_smm_stack
    bl t2nt_hook
#endif /* ENABLE_T2NT_HOOK */

    /* load the non-trust context state */
    /* sp = NtContextBase */
    GetContextBase_reg NtContextBase sp r5  

    LoadState                   // Context = N-Context

    /* set the SCR to non-trust world settings */
    mov lr, #SCR_NS             // lr_mon = Normal SCR Config
    CP15_SCR_WRITE lr           // cp15_SCR = lr_mon (N-World Config)

    /* flush the branch target address cache */
    CP15_Flush_BTAC lr          // flush BTAC (corrupts lr_mon)

t_smc_switch_exit:
    /* switch to non-trust world */
    rfeia   sp                  // load cpsr and pc from NtContext


t_smc_reboot:
    /*
     * reset した後の CPSR と PC をNT側コンテキストに設定する
     * r0 を NORMAL_CP15_CTRL_INIT_VALUE のロードに使わないのは,
     * stmea がストアする順序が重要なため.
     */
    /* r0 = NtContextBase */
    GetContextBase_reg NtContextBase r0, r3 

    ldr r1, =NORMAL_START_ADDRESS
    ldr r2, =NORMAL_CPSR_INIT_VALUE
    stmea r0, {r1, r2}

    /* 直接 linux を boot するためのレジスタ設定 */
    mov r1, #0
    mov r2, #0x5e0
    mov r3, #0x100
    /* r0 = NtContextSavedArea */
    GetContextBase_reg NtContextSavedArea r0, lr 

    stmea r0, {r1-r3}

    /* CP15 CTRL レジスタを操作する前に Non-Secure にしておく必要がある. */
    mov     r2, #SCR_NS
    CP15_SCR_WRITE  r2

    /* MMU と キャッシュをDISABLEにする */
    ldr r1, =NORMAL_CP15_CTRL_INIT_VALUE
    mcr p15, 0, r1, c1, c0, 0

    /* 操作が終わったら Secureに戻す. */
    mov     r2, #SCR_S
    CP15_SCR_WRITE  r2
    b t_smc_handler_exit


nt_smc_handler: /* TODO: use table */
#ifdef DUALOSCOM_FIFO_SUPPORT
	/* write data to fifo */
    cmp r0, #NT_SMC_FIFO_WRITE
    beq nt_smc_fifo_write
	/* read data from fifo */
    cmp r0, #NT_SMC_FIFO_READ
    beq nt_smc_fifo_read
#endif /* DUALOSCOM_FIFO_SUPPORT */
#ifdef DUALOS_DEVICE_SHARING
	/* write Trust device register */
    cmp r0, #NT_SMC_WRITE_REG
    beq nt_smc_write_reg
	/* read Trust device register */
    cmp r0, #NT_SMC_READ_REG
    beq nt_smc_read_reg
	/* memcpy to Trust device */
    cmp r0, #NT_SMC_MEMCPY4
    beq nt_smc_memcpy4
#endif /* DUALOS_DEVICE_SHARING */
    /* switch to NT (and pass arguments) */
    cmp r0, #NT_SMC_SWITCH
    beq nt_smc_switch
    /* emulate a software interrupt in Trust world */
    cmp r0, #NT_SMC_SOFTIRQ
    addeq lr, lr, #4
    beq non_trusted_fiq
    /* invalidate the cache */
    cmp r0, #NT_SMC_INV_CACHE
    beq nt_smc_cache

    /* if SMC number is not supported go back to nt with error (TODO: test) */
    mov r1, #NT_SMC_SWITCH_ERR
    b nt_smc_return_to_nt

#ifdef DUALOSCOM_FIFO_SUPPORT
nt_smc_fifo_write:
    /* r0 = NT_SMC_FIFO_WRITE; r1 = &msg */
    set_smm_stack
    stmfd sp!, {r0-r3, ip, lr}
    mov r0, r1 /* r0 = msg */
    bl c_safeg_fifo_write
    ldmfd sp!, {r0-r3, ip, lr}
    movs pc, lr

nt_smc_fifo_read:
    /* r0 = NT_SMC_FIFO_READ; r1 = &msg */
    set_smm_stack
    stmfd sp!, {r0-r3, ip, lr}
    mov r0, r1 /* r0 = msg */
    bl c_safeg_fifo_read
    ldmfd sp!, {r0-r3, ip, lr}
    movs pc, lr
#endif /* DUALOSCOM_FIFO_SUPPORT */

#ifdef DUALOS_DEVICE_SHARING
/* TODO: validate access depending on the system */
nt_smc_write_reg:
    mov sp, #SCR_S
    CP15_SCR_WRITE  sp
    str r1, [r2]
    mov sp, #SCR_NS
    CP15_SCR_WRITE  sp
    movs pc, lr

/* TODO: validate access depending on the system */
nt_smc_read_reg:
    mov sp, #SCR_S
    CP15_SCR_WRITE  sp
    ldr r2, [r2]
    str r2, [r1]
    mov sp, #SCR_NS
    CP15_SCR_WRITE  sp
    movs pc, lr

/* TODO: validate access depending on the system */
nt_smc_memcpy4:
    ldmia r2, {r3, r4, r5, r6}
    mov sp, #SCR_S
    CP15_SCR_WRITE  sp
    stmia  r1, {r3, r4, r5, r6}
    mov sp, #SCR_NS
    CP15_SCR_WRITE  sp
    movs pc, lr
#endif /* DUALOS_DEVICE_SHARING */

nt_smc_switch:
    /* go to secure world, to save NT state in secure memory */
    mov     sp, #SCR_S          // lr_mon = Secure World SCR config
    CP15_SCR_WRITE  sp          // cp15_SCR = lr_mon (S-World Config)

    /* save NT world state */
    /* sp = NtContextBase */
    GetContextBase_reg NtContextBase sp, r5 

    srsia #CPSR_MODE_MONITOR
    SaveState                   // N-Context = Context

    cmp r1, #T_SMC_SWITCH_HANDLER
    beq nt_smc_switch_raise_handler

    /*
     * In S_USR_R1 we have  &ret_args, get it to r6 (SaveState already
     * corrupted r6,r7,r12) and write args (r1-r2) in there
     */
    /* r6 = TTContextSavedArea */
    GetContextBase_reg TContextSavedArea r6, r5 

    ldr r6, [r6, #4]            // r6 = *(S_USR_R1) = ret_args
    str r1, [r6, #0]            // ret_args->arg0 = r1
    str r2, [r6, #4]            // ret_args->arg1 = r2

nt_smc_switch_exit:
    /* Load the trust world state */
    /* Note: BTAC flush is automatic in this direction */
    /* sp = TContextBase */
    GetContextBase_reg TContextBase sp, r5 

    LoadState                   // Context = S-Context
    rfeia   sp                  // switch to the trust-world os

nt_smc_switch_raise_handler:
    /* turn to trust world and raise a safeg soft interrupt handler */
    /* sp = TContextBase */
    GetContextBase_reg TContextBase sp, r5 

    ldmfd sp, {r0, r1} // 前回SMCを呼び出した時点の pc, cpsr.
    add r0, r0, #4
    str r1, [sp, #0xc]
    str r0, [sp, #0x14]
    LoadState
    set_smm_stack
    mov lr, #(CPSR_MODE_IRQ | CPSR_BIT_6_F | CPSR_BIT_7_I)
    str lr, [sp, #-4]!
    /* SAFEGベクタのアドレスはvectorbase + 0x20 */
    CP15_VBAR_READ lr
    add lr, lr, #0x20
    str lr, [sp, #-4]!
    /* IRQ モードに切り替え, T 側の IRQ ベクタにジャンプ */
    rfeia sp

nt_smc_cache:
    /* check arg0 in r1 to know what to invalidate */
    cmp r1, #NT_SMC_INV_CACHE_D
    beq nt_smc_cache_invalidate_dcache
    cmp r1, #NT_SMC_INV_CACHE_I
    beq nt_smc_cache_invalidate_icache
    cmp r1, #NT_SMC_INV_CACHE_ALL
    beq nt_smc_cache_invalidate_allcache

    /* if argument number is not supported return with error (TODO: test)*/
    mov r1, #NT_SMC_INV_CACHE_ERR
    b nt_smc_return_to_nt

nt_smc_cache_invalidate_dcache:
    /* invalidate the entire data cache */
    mov r0, #0
    mcr p15, 0, r0, c7, c6, 0
    b nt_smc_return_to_nt

nt_smc_cache_invalidate_icache:
    /* invalidate the entire instruction cache */
    mov r0, #0
    mcr p15, 0, r0, c7, c5, 0
    b nt_smc_return_to_nt

nt_smc_cache_invalidate_allcache:
    /* invalidate both the data and the instruction cache */
    mov r0, #0
    mcr p15, 0, r0, c7, c14, 0
    mcr p15, 0, r0, c7, c5, 0
    b nt_smc_return_to_nt

nt_smc_return_to_nt:
    movs pc, lr

/*
 * SCRのEAビットを立てたことによって，NT側がTrust領域にアクセスした際に
 * このベクタが呼ばれる．
 * なので確実にNT側としてdata_abort_handlerは呼び出される．
 * NT側には戻らないので，SaveStateは呼び出さない．
 * 内容としてはdata abortだが，NT側のフォルトをハンドリングするという
 * 処理の性質上，SWIとしてT側に処理させることとした．
 */
    .text
    .align 5
    .global data_abort_handler
data_abort_handler:
    /* LoadStateを呼び出す前に, Secureにしておく必要がある. */
    mov     sp, #SCR_S                 // lr_mon = Secure World SCR config
    CP15_SCR_WRITE  sp                 // cp15_SCR = lr_mon (S-World Config)

    /*
     * TContextBase, TContextBase+4 は 前回 SMC が呼び出された
     * ときの pc, cpsr となっている．
     * これらの値は swi 終了後に戻る先となるので，swi が通常呼ばれた状態に合わせ
     * lr_svc, spsr_svc に設定する．
     * lr_svc, spsr_svcを破壊するが，asm_target_idleではこれらを破壊しても
     * よいことになっているので保存復帰はしない
     */
    /* sp = TContextBase */
    GetContextBase_reg TContextBase sp, r5 

    ldmia sp, {r0, r1}
#if TNUM_PRC == 1
    ldr sp, =S_SVC_LR_CORE0
#else /* TNUM_PRC > 1 */
    get_prcid sp
    cmp sp, #0
    ldreq sp, =S_SVC_LR_CORE0
    cmp sp, #1
    ldreq sp, =S_SVC_LR_CORE1
#if TNUM_PRC > 2
    cmp sp, #2
    ldreq sp, =S_SVC_LR_CORE2
#endif /* TNUM_PRC > 2 */
#if TNUM_PRC > 3
    cmp sp, #3
    ldreq sp, =S_SVC_LR_CORE3
#endif /* TNUM_PRC > 3 */
#endif /* TNUM_PRC == 1 */
    str r0, [sp]
    str r1, [sp, #-8]

    /*
     * rfeiaで戻るために S_PC, S_CPSR を書き換える．
     * FIQ 許可，IRQ 禁止，SVCモードになる状態で抜ける.
     */
   /* sp = TContextBase */
   GetContextBase_reg TContextBase sp r5  

    /* SWI ベクタのアドレスはvectorbase + 0x8 */
    CP15_VBAR_READ r0
    add r0, r0, #0x8
    mov r1, #(CPSR_MODE_SVC | CPSR_BIT_7_I)
    stmia sp, {r0, r1}

    /*
     * Tコンテキストを復帰．
     */
    LoadState

    /* SVC モードに切り替え, T 側の SWI ベクタにジャンプ */
    rfeia sp

/*
 * SafeG の起動を行う.
 * trust側からのSMCによりnon-trustに移動できるように
 * non-trustの起動のための情報をNTコンテキストに保存する.
 * Trust側の起動処理を呼び出す.
 *
 * r0: Non-Trust側スタートアドレス
 * r1: Trust側スタートアドレス
 */
    .text
    .align 5
    .global SafeGStart
SafeGStart:
    /* Non-Trust側のコンテキストを設定する */
    /* stmea をやめて label を使った単発ストア2個にする */
    /* r2 = NtContextBase */
    GetContextBase_reg NtContextBase r2 r5  

    ldr r3, =NORMAL_CPSR_INIT_VALUE
    stmea r2, {r0, r3}

    /* Trust側リセット時のモードに変更する */
    cps #CPSR_MODE_SVC

    /* Trust側のスタートアドレスにジャンプする */
    mov pc, r1

/*
 *-----------------------------------------------------------------------------
 * =================
 * Monitor workspace
 * =================
 */

/*
 * =================
 * Core 0
 * =================
 */
    .bss
    .align 5
    .global NtContextSavedArea
    .global NtContextSavedAreaEnd
    .global TContextSavedArea
    .global TContextSavedAreaEnd
    .global NtContextBase
    .global TContextBase
    .global NtContextSavedArea0
    .global NtContextSavedAreaEnd0
    .global TContextSavedArea0
    .global TContextSavedAreaEnd0
    .global NtContextBase0
    .global TContextBase0
NtContextSavedArea:
NtContextSavedArea0:
N_USR_R0_CORE0       : .long 0x00
N_USR_R1_CORE0       : .long 0x00
N_USR_R2_CORE0       : .long 0x00
N_USR_R3_CORE0       : .long 0x00
N_USR_R4_CORE0       : .long 0x00
N_USR_R5_CORE0       : .long 0x00
N_USR_R6_CORE0       : .long 0x00
N_USR_R7_CORE0       : .long 0x00
N_USR_R8_CORE0       : .long 0x00
N_USR_R9_CORE0       : .long 0x00
N_USR_R10_CORE0      : .long 0x00
N_USR_R11_CORE0      : .long 0x00
N_USR_R12_CORE0      : .long 0x00
N_USR_SP_CORE0       : .long 0x00
N_USR_LR_CORE0       : .long 0x00

NtContextBase:
NtContextBase0:
N_PC_CORE0           : .long 0x00    // PC to load to return to Normal World
N_CPSR_CORE0         : .long 0x00    // CPSR to load when returning to Normal World
N_SCRATCH_CORE0      : .long 0x00
N_IRQ_SPSR_CORE0     : .long 0x00    // Normal World IRQ mode SPSR, SP and LR reg
N_IRQ_SP_CORE0       : .long 0x00
N_IRQ_LR_CORE0       : .long 0x00
N_SVC_SPSR_CORE0     : .long 0x00    // etc.
N_SVC_SP_CORE0       : .long 0x00
N_SVC_LR_CORE0       : .long 0x00
N_ABT_SPSR_CORE0     : .long 0x00
N_ABT_SP_CORE0       : .long 0x00
N_ABT_LR_CORE0       : .long 0x00
N_UND_SPSR_CORE0     : .long 0x00
N_UND_SP_CORE0       : .long 0x00
N_UND_LR_CORE0       : .long 0x00
N_FIQ_SPSR_CORE0     : .long 0x00
N_FIQ_R8_CORE0       : .long 0x00
N_FIQ_R9_CORE0       : .long 0x00
N_FIQ_R10_CORE0      : .long 0x00
N_FIQ_R11_CORE0      : .long 0x00
N_FIQ_R12_CORE0      : .long 0x00
N_FIQ_SP_CORE0       : .long 0x00
N_FIQ_LR_CORE0       : .long 0x00
NtContextSavedAreaEnd:
NtContextSavedAreaEnd0:

TContextSavedArea:
TContextSavedArea0:
S_USR_R0_CORE0       : .long 0x00    // Secure World USR/SYS registers
S_USR_R1_CORE0       : .long 0x00
S_USR_R2_CORE0       : .long 0x00
S_USR_R3_CORE0       : .long 0x00
S_USR_R4_CORE0       : .long 0x00
S_USR_R5_CORE0       : .long 0x00
S_USR_R6_CORE0       : .long 0x00
S_USR_R7_CORE0       : .long 0x00
S_USR_R8_CORE0       : .long 0x00
S_USR_R9_CORE0       : .long 0x00
S_USR_R10_CORE0      : .long 0x00
S_USR_R11_CORE0      : .long 0x00
S_USR_R12_CORE0      : .long 0x00
S_USR_SP_CORE0       : .long 0x00
S_USR_LR_CORE0       : .long 0x00

TContextBase:
TContextBase0:
S_PC_CORE0           : .long 0x00    // PC to load to return to Secure World
S_CPSR_CORE0         : .long 0x00    // CPSR to load to return to Secure World
S_SCRATCH_CORE0      : .long 0x00
S_IRQ_SPSR_CORE0     : .long 0x00    // Secure World IRQ mode SPSR, SP and LR reg
S_IRQ_SP_CORE0       : .long 0x00
S_IRQ_LR_CORE0       : .long 0x00
S_SVC_SPSR_CORE0     : .long 0x00    // etc.
S_SVC_SP_CORE0       : .long 0x00
S_SVC_LR_CORE0       : .long 0x00
S_ABT_SPSR_CORE0     : .long 0x00
S_ABT_SP_CORE0       : .long 0x00
S_ABT_LR_CORE0       : .long 0x00
S_UND_SPSR_CORE0     : .long 0x00
S_UND_SP_CORE0       : .long 0x00
S_UND_LR_CORE0       : .long 0x00
S_FIQ_SPSR_CORE0     : .long 0x00
S_FIQ_R8_CORE0       : .long 0x00
S_FIQ_R9_CORE0       : .long 0x00
S_FIQ_R10_CORE0      : .long 0x00
S_FIQ_R11_CORE0      : .long 0x00
S_FIQ_R12_CORE0      : .long 0x00
S_FIQ_SP_CORE0       : .long 0x00
S_FIQ_LR_CORE0       : .long 0x00
TContextSavedAreaEnd:
TContextSavedAreaEnd0:

#if TNUM_PRC > 1
/*
 * =================
 * Core 1
 * =================
 */
    .bss
    .align 5
    .global NtContextSavedArea1
    .global NtContextSavedAreaEnd1
    .global TContextSavedArea1
    .global TContextSavedAreaEnd1
    .global NtContextBase1
    .global TContextBase1
NtContextSavedArea1:
N_USR_R0_CORE1       : .long 0x00
N_USR_R1_CORE1       : .long 0x00
N_USR_R2_CORE1       : .long 0x00
N_USR_R3_CORE1       : .long 0x00
N_USR_R4_CORE1       : .long 0x00
N_USR_R5_CORE1       : .long 0x00
N_USR_R6_CORE1       : .long 0x00
N_USR_R7_CORE1       : .long 0x00
N_USR_R8_CORE1       : .long 0x00
N_USR_R9_CORE1       : .long 0x00
N_USR_R10_CORE1      : .long 0x00
N_USR_R11_CORE1      : .long 0x00
N_USR_R12_CORE1      : .long 0x00
N_USR_SP_CORE1       : .long 0x00
N_USR_LR_CORE1       : .long 0x00

NtContextBase1:
N_PC_CORE1           : .long 0x00    // PC to load to return to Normal World
N_CPSR_CORE1         : .long 0x00    // CPSR to load when returning to Normal World
N_SCRATCH_CORE1      : .long 0x00
N_IRQ_SPSR_CORE1     : .long 0x00    // Normal World IRQ mode SPSR, SP and LR reg
N_IRQ_SP_CORE1       : .long 0x00
N_IRQ_LR_CORE1       : .long 0x00
N_SVC_SPSR_CORE1     : .long 0x00    // etc.
N_SVC_SP_CORE1       : .long 0x00
N_SVC_LR_CORE1       : .long 0x00
N_ABT_SPSR_CORE1     : .long 0x00
N_ABT_SP_CORE1       : .long 0x00
N_ABT_LR_CORE1       : .long 0x00
N_UND_SPSR_CORE1     : .long 0x00
N_UND_SP_CORE1       : .long 0x00
N_UND_LR_CORE1       : .long 0x00
N_FIQ_SPSR_CORE1     : .long 0x00
N_FIQ_R8_CORE1       : .long 0x00
N_FIQ_R9_CORE1       : .long 0x00
N_FIQ_R10_CORE1      : .long 0x00
N_FIQ_R11_CORE1      : .long 0x00
N_FIQ_R12_CORE1      : .long 0x00
N_FIQ_SP_CORE1       : .long 0x00
N_FIQ_LR_CORE1       : .long 0x00
NtContextSavedAreaEnd1:

TContextSavedArea1:
S_USR_R0_CORE1       : .long 0x00    // Secure World USR/SYS registers
S_USR_R1_CORE1       : .long 0x00
S_USR_R2_CORE1       : .long 0x00
S_USR_R3_CORE1       : .long 0x00
S_USR_R4_CORE1       : .long 0x00
S_USR_R5_CORE1       : .long 0x00
S_USR_R6_CORE1       : .long 0x00
S_USR_R7_CORE1       : .long 0x00
S_USR_R8_CORE1       : .long 0x00
S_USR_R9_CORE1       : .long 0x00
S_USR_R10_CORE1      : .long 0x00
S_USR_R11_CORE1      : .long 0x00
S_USR_R12_CORE1      : .long 0x00
S_USR_SP_CORE1       : .long 0x00
S_USR_LR_CORE1       : .long 0x00

TContextBase1:
S_PC_CORE1           : .long 0x00    // PC to load to return to Secure World
S_CPSR_CORE1         : .long 0x00    // CPSR to load to return to Secure World
S_SCRATCH_CORE1      : .long 0x00
S_IRQ_SPSR_CORE1     : .long 0x00    // Secure World IRQ mode SPSR, SP and LR reg
S_IRQ_SP_CORE1       : .long 0x00
S_IRQ_LR_CORE1       : .long 0x00
S_SVC_SPSR_CORE1     : .long 0x00    // etc.
S_SVC_SP_CORE1       : .long 0x00
S_SVC_LR_CORE1       : .long 0x00
S_ABT_SPSR_CORE1     : .long 0x00
S_ABT_SP_CORE1       : .long 0x00
S_ABT_LR_CORE1       : .long 0x00
S_UND_SPSR_CORE1     : .long 0x00
S_UND_SP_CORE1       : .long 0x00
S_UND_LR_CORE1       : .long 0x00
S_FIQ_SPSR_CORE1     : .long 0x00
S_FIQ_R8_CORE1       : .long 0x00
S_FIQ_R9_CORE1       : .long 0x00
S_FIQ_R10_CORE1      : .long 0x00
S_FIQ_R11_CORE1      : .long 0x00
S_FIQ_R12_CORE1      : .long 0x00
S_FIQ_SP_CORE1       : .long 0x00
S_FIQ_LR_CORE1       : .long 0x00
TContextSavedAreaEnd1:
#endif /* TNUM_PRC > 1 */

#if TNUM_PRC > 2
/*
 * =================
 * Core 2
 * =================
 */
    .bss
    .align 5
    .global NtContextSavedArea2
    .global NtContextSavedAreaEnd2
    .global TContextSavedArea2
    .global TContextSavedAreaEnd2
    .global NtContextBase2
    .global TContextBase2
NtContextSavedArea2:
N_USR_R0_CORE2       : .long 0x00
N_USR_R1_CORE2       : .long 0x00
N_USR_R2_CORE2       : .long 0x00
N_USR_R3_CORE2       : .long 0x00
N_USR_R4_CORE2       : .long 0x00
N_USR_R5_CORE2       : .long 0x00
N_USR_R6_CORE2       : .long 0x00
N_USR_R7_CORE2       : .long 0x00
N_USR_R8_CORE2       : .long 0x00
N_USR_R9_CORE2       : .long 0x00
N_USR_R10_CORE2      : .long 0x00
N_USR_R11_CORE2      : .long 0x00
N_USR_R12_CORE2      : .long 0x00
N_USR_SP_CORE2       : .long 0x00
N_USR_LR_CORE2       : .long 0x00

NtContextBase2:
N_PC_CORE2           : .long 0x00    // PC to load to return to Normal World
N_CPSR_CORE2         : .long 0x00    // CPSR to load when returning to Normal World
N_SCRATCH_CORE2      : .long 0x00
N_IRQ_SPSR_CORE2     : .long 0x00    // Normal World IRQ mode SPSR, SP and LR reg
N_IRQ_SP_CORE2       : .long 0x00
N_IRQ_LR_CORE2       : .long 0x00
N_SVC_SPSR_CORE2     : .long 0x00    // etc.
N_SVC_SP_CORE2       : .long 0x00
N_SVC_LR_CORE2       : .long 0x00
N_ABT_SPSR_CORE2     : .long 0x00
N_ABT_SP_CORE2       : .long 0x00
N_ABT_LR_CORE2       : .long 0x00
N_UND_SPSR_CORE2     : .long 0x00
N_UND_SP_CORE2       : .long 0x00
N_UND_LR_CORE2       : .long 0x00
N_FIQ_SPSR_CORE2     : .long 0x00
N_FIQ_R8_CORE2       : .long 0x00
N_FIQ_R9_CORE2       : .long 0x00
N_FIQ_R10_CORE2      : .long 0x00
N_FIQ_R11_CORE2      : .long 0x00
N_FIQ_R12_CORE2      : .long 0x00
N_FIQ_SP_CORE2       : .long 0x00
N_FIQ_LR_CORE2       : .long 0x00
NtContextSavedAreaEnd2:

TContextSavedArea2:
S_USR_R0_CORE2       : .long 0x00    // Secure World USR/SYS registers
S_USR_R1_CORE2       : .long 0x00
S_USR_R2_CORE2       : .long 0x00
S_USR_R3_CORE2       : .long 0x00
S_USR_R4_CORE2       : .long 0x00
S_USR_R5_CORE2       : .long 0x00
S_USR_R6_CORE2       : .long 0x00
S_USR_R7_CORE2       : .long 0x00
S_USR_R8_CORE2       : .long 0x00
S_USR_R9_CORE2       : .long 0x00
S_USR_R10_CORE2      : .long 0x00
S_USR_R11_CORE2      : .long 0x00
S_USR_R12_CORE2      : .long 0x00
S_USR_SP_CORE2       : .long 0x00
S_USR_LR_CORE2       : .long 0x00

TContextBase2:
S_PC_CORE2           : .long 0x00    // PC to load to return to Secure World
S_CPSR_CORE2         : .long 0x00    // CPSR to load to return to Secure World
S_SCRATCH_CORE2      : .long 0x00
S_IRQ_SPSR_CORE2     : .long 0x00    // Secure World IRQ mode SPSR, SP and LR reg
S_IRQ_SP_CORE2       : .long 0x00
S_IRQ_LR_CORE2       : .long 0x00
S_SVC_SPSR_CORE2     : .long 0x00    // etc.
S_SVC_SP_CORE2       : .long 0x00
S_SVC_LR_CORE2       : .long 0x00
S_ABT_SPSR_CORE2     : .long 0x00
S_ABT_SP_CORE2       : .long 0x00
S_ABT_LR_CORE2       : .long 0x00
S_UND_SPSR_CORE2     : .long 0x00
S_UND_SP_CORE2       : .long 0x00
S_UND_LR_CORE2       : .long 0x00
S_FIQ_SPSR_CORE2     : .long 0x00
S_FIQ_R8_CORE2       : .long 0x00
S_FIQ_R9_CORE2       : .long 0x00
S_FIQ_R10_CORE2      : .long 0x00
S_FIQ_R11_CORE2      : .long 0x00
S_FIQ_R12_CORE2      : .long 0x00
S_FIQ_SP_CORE2       : .long 0x00
S_FIQ_LR_CORE2       : .long 0x00
TContextSavedAreaEnd2:
#endif /* TNUM_PRC > 2 */

#if TNUM_PRC > 3
/*
 * =================
 * Core 3
 * =================
 */
    .bss
    .align 5
    .global NtContextSavedArea3
    .global NtContextSavedAreaEnd3
    .global TContextSavedArea3
    .global TContextSavedAreaEnd3
    .global NtContextBase3
    .global TContextBase3
NtContextSavedArea3:
N_USR_R0_CORE3       : .long 0x00
N_USR_R1_CORE3       : .long 0x00
N_USR_R2_CORE3       : .long 0x00
N_USR_R3_CORE3       : .long 0x00
N_USR_R4_CORE3       : .long 0x00
N_USR_R5_CORE3       : .long 0x00
N_USR_R6_CORE3       : .long 0x00
N_USR_R7_CORE3       : .long 0x00
N_USR_R8_CORE3       : .long 0x00
N_USR_R9_CORE3       : .long 0x00
N_USR_R10_CORE3      : .long 0x00
N_USR_R11_CORE3      : .long 0x00
N_USR_R12_CORE3      : .long 0x00
N_USR_SP_CORE3       : .long 0x00
N_USR_LR_CORE3       : .long 0x00

NtContextBase3:
N_PC_CORE3           : .long 0x00    // PC to load to return to Normal World
N_CPSR_CORE3         : .long 0x00    // CPSR to load when returning to Normal World
N_SCRATCH_CORE3      : .long 0x00
N_IRQ_SPSR_CORE3     : .long 0x00    // Normal World IRQ mode SPSR, SP and LR reg
N_IRQ_SP_CORE3       : .long 0x00
N_IRQ_LR_CORE3       : .long 0x00
N_SVC_SPSR_CORE3     : .long 0x00    // etc.
N_SVC_SP_CORE3       : .long 0x00
N_SVC_LR_CORE3       : .long 0x00
N_ABT_SPSR_CORE3     : .long 0x00
N_ABT_SP_CORE3       : .long 0x00
N_ABT_LR_CORE3       : .long 0x00
N_UND_SPSR_CORE3     : .long 0x00
N_UND_SP_CORE3       : .long 0x00
N_UND_LR_CORE3       : .long 0x00
N_FIQ_SPSR_CORE3     : .long 0x00
N_FIQ_R8_CORE3       : .long 0x00
N_FIQ_R9_CORE3       : .long 0x00
N_FIQ_R10_CORE3      : .long 0x00
N_FIQ_R11_CORE3      : .long 0x00
N_FIQ_R12_CORE3      : .long 0x00
N_FIQ_SP_CORE3       : .long 0x00
N_FIQ_LR_CORE3       : .long 0x00
NtContextSavedAreaEnd3:

TContextSavedArea3:
S_USR_R0_CORE3       : .long 0x00    // Secure World USR/SYS registers
S_USR_R1_CORE3       : .long 0x00
S_USR_R2_CORE3       : .long 0x00
S_USR_R3_CORE3       : .long 0x00
S_USR_R4_CORE3       : .long 0x00
S_USR_R5_CORE3       : .long 0x00
S_USR_R6_CORE3       : .long 0x00
S_USR_R7_CORE3       : .long 0x00
S_USR_R8_CORE3       : .long 0x00
S_USR_R9_CORE3       : .long 0x00
S_USR_R10_CORE3      : .long 0x00
S_USR_R11_CORE3      : .long 0x00
S_USR_R12_CORE3      : .long 0x00
S_USR_SP_CORE3       : .long 0x00
S_USR_LR_CORE3       : .long 0x00

TContextBase3:
S_PC_CORE3           : .long 0x00    // PC to load to return to Secure World
S_CPSR_CORE3         : .long 0x00    // CPSR to load to return to Secure World
S_SCRATCH_CORE3      : .long 0x00
S_IRQ_SPSR_CORE3     : .long 0x00    // Secure World IRQ mode SPSR, SP and LR reg
S_IRQ_SP_CORE3       : .long 0x00
S_IRQ_LR_CORE3       : .long 0x00
S_SVC_SPSR_CORE3     : .long 0x00    // etc.
S_SVC_SP_CORE3       : .long 0x00
S_SVC_LR_CORE3       : .long 0x00
S_ABT_SPSR_CORE3     : .long 0x00
S_ABT_SP_CORE3       : .long 0x00
S_ABT_LR_CORE3       : .long 0x00
S_UND_SPSR_CORE3     : .long 0x00
S_UND_SP_CORE3       : .long 0x00
S_UND_LR_CORE3       : .long 0x00
S_FIQ_SPSR_CORE3     : .long 0x00
S_FIQ_R8_CORE3       : .long 0x00
S_FIQ_R9_CORE3       : .long 0x00
S_FIQ_R10_CORE3      : .long 0x00
S_FIQ_R11_CORE3      : .long 0x00
S_FIQ_R12_CORE3      : .long 0x00
S_FIQ_SP_CORE3       : .long 0x00
S_FIQ_LR_CORE3       : .long 0x00
TContextSavedAreaEnd3:
#endif /* TNUM_PRC > 3 */
