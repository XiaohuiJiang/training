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
#ifndef _SAFEG_H_
#define _SAFEG_H_

/*
 *  Number of processor
 */
#ifndef TNUM_PRC
#define TNUM_PRC   1
#endif /* TNUM_PRC */

/*
 * irq, fiq を管理するための関数
 * tz_basic.S の irq, fiq ハンドラの中で呼ばれる.
 * これらの関数内に行いたい処理を記述する.
 */

// #define ENABLE_FIQ_HOOK
// #define ENABLE_IRQ_HOOK

#ifndef TOPPERS_MACRO_ONLY

/*
 * Argment for systemcall
 */
struct safeg_smc_args {
    void *arg0;
    void *arg1;
    void *arg2;
    void *arg3;
    void *arg4;
};

#ifdef ENABLE_IRQ_HOOK
extern void irq_hook(void);
#endif /* ENABLE_IRQ_HOOK */

#ifdef ENABLE_FIQ_HOOK
extern void fiq_hook(void);
#endif /* ENABLE_FIQ_HOOK */

typedef struct {
    unsigned long n_usr_r0;
    unsigned long n_usr_r1;
    unsigned long n_usr_r2;
    unsigned long n_usr_r3;
    unsigned long n_usr_r4;
    unsigned long n_usr_r5;
    unsigned long n_usr_r6;
    unsigned long n_usr_r7;
    unsigned long n_usr_r8;
    unsigned long n_usr_r9;
    unsigned long n_usr_r10;
    unsigned long n_usr_r11;
    unsigned long n_usr_r12;
    unsigned long n_usr_sp;
    unsigned long n_usr_lr;
    unsigned long n_pc;
    unsigned long n_cpsr;
    unsigned long n_scratch;
    unsigned long n_irq_spsr;
    unsigned long n_irq_sp;
    unsigned long n_irq_lr;
    unsigned long n_svc_spsr;
    unsigned long n_svc_sp;
    unsigned long n_svc_lr;
    unsigned long n_abt_spsr;
    unsigned long n_abt_sp;
    unsigned long n_abt_lr;
    unsigned long n_und_spsr;
    unsigned long n_und_sp;
    unsigned long n_und_lr;
    unsigned long n_fiq_spsr;
    unsigned long n_fiq_r8;
    unsigned long n_fiq_r9;
    unsigned long n_fiq_r10;
    unsigned long n_fiq_r11;
    unsigned long n_fiq_r12;
    unsigned long n_fiq_sp;
    unsigned long n_fiq_lr;
}NtContextSavedAreaStruct;

typedef struct
{
    unsigned long s_usr_r0;
    unsigned long s_usr_r1;
    unsigned long s_usr_r2;
    unsigned long s_usr_r3;
    unsigned long s_usr_r4;
    unsigned long s_usr_r5;
    unsigned long s_usr_r6;
    unsigned long s_usr_r7;
    unsigned long s_usr_r8;
    unsigned long s_usr_r9;
    unsigned long s_usr_r10;
    unsigned long s_usr_r11;
    unsigned long s_usr_r12;
    unsigned long s_usr_sp;
    unsigned long s_usr_lr;
    unsigned long s_pc;
    unsigned long s_cpsr;
    unsigned long s_scratch;
    unsigned long s_irq_spsr;
    unsigned long s_irq_sp;
    unsigned long s_irq_lr;
    unsigned long s_svc_spsr;
    unsigned long s_svc_sp;
    unsigned long s_svc_lr;
    unsigned long s_abt_spsr;
    unsigned long s_abt_sp;
    unsigned long s_abt_lr;
    unsigned long s_und_spsr;
    unsigned long s_und_sp;
    unsigned long s_und_lr;
    unsigned long s_fiq_spsr;
    unsigned long s_fiq_r8;
    unsigned long s_fiq_r9;
    unsigned long s_fiq_r10;
    unsigned long s_fiq_r11;
    unsigned long s_fiq_r12;
    unsigned long s_fiq_sp;
    unsigned long s_fiq_lr;
}TContextSavedAreaStruct;

static inline unsigned int
get_cpuid(void)
{
	unsigned int tmp;
	CP15_MPIDR_READ(tmp);
	return tmp & 0x0f;
}

#endif /* TOPPERS_MACRO_ONLY */

#endif /* _SAFEG_H_ */

#ifdef PROF_SUPPORT
/*
 *  プロファイル機能用の定義等
 */

/*
 *  FIQ/IRQ/NT2T/T2NTのフックを有効に
 */
#ifndef ENABLE_FIQ_HOOK
#define ENABLE_FIQ_HOOK
#endif /* ENABLE_FIQ_HOOK */

#ifndef ENABLE_IRQ_HOOK
#define ENABLE_IRQ_HOOK
#endif  /* ENABLE_IRQ_HOOK */

#ifndef ENABLE_NT2T_HOOK
#define ENABLE_NT2T_HOOK
#endif /* ENABLE_NT2T_HOOK */

#ifndef ENABLE_T2NT_HOOK
#define ENABLE_T2NT_HOOK
#endif /* ENABLE_T2NT_HOOK */

#ifndef TOPPERS_MACRO_ONLY
/* プロファイル用変数の初期化 */
extern void c_smc_prof_init(void);

/* プロファイル値の取得 */
extern void c_smc_prof_get(struct safeg_smc_args *args);

/* プロファイル用変数のポインタ取得 */
extern void c_smc_prof_get_ptr(struct safeg_smc_args *args);

/* FIQ用のフック  */
extern void prof_fiq_hook(void);

/* IRQ用のフック  */
extern void prof_irq_hook(void);

/* T2NT用のフック  */
extern void prof_t2nt_hook(void);

/* NT2T用のフック  */
extern void prof_nt2t_hook(void);

#endif /* TOPPERS_MACRO_ONLY */
#endif /* PROF_SUPPORT*/

#ifdef TOPPERS_MACRO_ONLY
/*
 *  アセンブラ用のマクロファイル
 */

/*
 *  Get processor id
 */
    .macro get_prcid cpuid_reg
       mrc p15, 0, \cpuid_reg, c0, c0, 5 /* プロセッサIDの取得 */
       and \cpuid_reg, \cpuid_reg, #0x0f /* 下位4bitのみ有効(cpuid_reg <= cpu_id) */
    .endm

/*
 *  Set sp to top of Safeg stack(_smm_stack)
 */
    .macro set_smm_stack
#if TNUM_PRC == 1
       ldr sp, =_smm_stack
       ldr sp, [sp]
#else /* TNUM_PRC > 1 */
       mrc p15, 0, sp, c0, c0, 5 /* プロセッサIDの取得 */
       and sp, sp, #0x0f /* 下位4bitのみ有効(sp <= cpu_id) */
       cmp sp, #0
       ldreq sp, =_smm_stack0
       beq 1f
       cmp sp, #1
       ldreq sp, =_smm_stack1
       beq 1f
#if TNUM_PRC > 2
       cmp sp, #2
       ldreq sp, =_smm_stack2
       beq 1f
#endif /* TNUM_PRC > 2 */
#if TNUM_PRC > 3
       cmp sp, #3
       ldreq sp, =_smm_stack3
#endif /* TNUM_PRC > 3 */
1:     ldr sp, [sp]
#endif /* TNUM_PRC == 1 */
    .endm
#endif /* TOPPERS_MACRO_ONLY */
