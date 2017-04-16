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

    .text
    .balign 2
    .globl _start
_start:
    /* svc モードで開始するが, SafeGはモニタモードで動作したいので変更 */
    cps #CPSR_MODE_MONITOR
    set_smm_stack
    mov r0, #SCR_S                 // secureかつ FWビットを0に設定
    CP15_SCR_WRITE r0

    /*
     * hardware_init_hookの呼び出し （0でない場合）
     *
     * ターゲットハードウェアに依存して必要な初期化処理がある場合
     * は，hardware_init_hook という関数を用意する
     */
    ldr   r0, =hardware_init_hook
    cmp   r0, #0x00
    movne lr, pc
    movne pc, r0

#if 0
    /*
     *  bssセクションのクリア
     */
start_1:
    ldr  r1, =__bss_start
    ldr  r2, =__bss_end
    cmp  r1,r2
    bhs  start_3
    mov  r0,#0
start_2:
    str  r0,[r1],#4
    cmp  r1, r2
    blo  start_2

    /*
     *  dataセクションの初期化(ROM化対応)
     *  __idata_start から __idata_end までを，__data_start 以降に
     *  コピーする
     */
start_3:
    ldr  r1, =__idata_start
    ldr  r3, =__idata_end
    cmp  r1, r3
    bhs  start_5
    ldr  r2, =__data_start
start_4:
    ldr  r0, [r1],#4
    str  r0, [r2],#4
    cmp  r1, r3
    blo  start_4
#endif
    /*
     *  software_init_hook を呼出し（0 でない場合）
     *
     *  ソフトウェア環境（特にライブラリ）に依存して必要な初期化処
     *  理がある場合は，software_init_hook という関数を用意すれば
     *  よい．
     */
start_5:
    ldr   r0, =software_init_hook
    cmp   r0, #0x00
    movne lr, pc
    movne pc, r0

    /*
     * カーネルを起動する
     */
start_6:
    bl arm_main
l_end:
    b   l_end
