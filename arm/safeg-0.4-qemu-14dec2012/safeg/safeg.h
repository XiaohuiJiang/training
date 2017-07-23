/*
 *  TOPPERS/SafeG Dual-OS monitor
 *      Toyohashi Open Platform for Embedded Real-Time Systems/
 *      Safety Gate Dual-OS monitor
 *
 *  Copyright (C) 2009-2011 by Embedded and Real-Time Systems Laboratory
 *     Graduate School of Information Science, Nagoya University, JAPAN
 *
 *  �嵭����Ԥϡ��ʲ���(1)��(4)�ξ������������˸¤ꡤ�ܥ��եȥ���
 *  �����ܥ��եȥ���������Ѥ�����Τ�ޤࡥ�ʲ�Ʊ���ˤ���ѡ�ʣ������
 *  �ѡ������ۡʰʲ������ѤȸƤ֡ˤ��뤳�Ȥ�̵���ǵ������롥
 *  (1) �ܥ��եȥ������򥽡��������ɤη������Ѥ�����ˤϡ��嵭������
 *      ��ɽ�����������Ѿ�浪��Ӳ�����̵�ݾڵ��꤬�����Τޤޤη��ǥ���
 *      ����������˴ޤޤ�Ƥ��뤳�ȡ�
 *  (2) �ܥ��եȥ������򡤥饤�֥������ʤɡ�¾�Υ��եȥ�������ȯ�˻�
 *      �ѤǤ�����Ǻ����ۤ�����ˤϡ������ۤ�ȼ���ɥ�����ȡ�����
 *      �ԥޥ˥奢��ʤɡˤˡ��嵭�����ɽ�����������Ѿ�浪��Ӳ���
 *      ��̵�ݾڵ����Ǻܤ��뤳�ȡ�
 *  (3) �ܥ��եȥ������򡤵�����Ȥ߹���ʤɡ�¾�Υ��եȥ�������ȯ�˻�
 *      �ѤǤ��ʤ����Ǻ����ۤ�����ˤϡ����Τ����줫�ξ�����������
 *      �ȡ�
 *    (a) �����ۤ�ȼ���ɥ�����ȡ����Ѽԥޥ˥奢��ʤɡˤˡ��嵭����
 *        �ɽ�����������Ѿ�浪��Ӳ�����̵�ݾڵ����Ǻܤ��뤳�ȡ�
 *    (b) �����ۤη��֤��̤�������ˡ�ˤ�äơ�TOPPERS�ץ������Ȥ�
 *        ��𤹤뤳�ȡ�
 *  (4) �ܥ��եȥ����������Ѥˤ��ľ��Ū�ޤ��ϴ���Ū�������뤤���ʤ�»
 *      ������⡤�嵭����Ԥ����TOPPERS�ץ������Ȥ����դ��뤳�ȡ�
 *      �ޤ����ܥ��եȥ������Υ桼���ޤ��ϥ���ɥ桼������Τ����ʤ���
 *      ͳ�˴�Ť����ᤫ��⡤�嵭����Ԥ����TOPPERS�ץ������Ȥ�
 *      ���դ��뤳�ȡ�
 *
 *  �ܥ��եȥ������ϡ�̵�ݾڤ��󶡤���Ƥ����ΤǤ��롥�嵭����Ԥ�
 *  ���TOPPERS�ץ������Ȥϡ��ܥ��եȥ������˴ؤ��ơ�����λ�����Ū
 *  ���Ф���Ŭ������ޤ�ơ������ʤ��ݾڤ�Ԥ�ʤ����ޤ����ܥ��եȥ���
 *  �������Ѥˤ��ľ��Ū�ޤ��ϴ���Ū�������������ʤ�»���˴ؤ��Ƥ⡤��
 *  ����Ǥ�����ʤ���
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
 * irq, fiq ��������뤿��δؿ�
 * tz_basic.S �� irq, fiq �ϥ�ɥ����ǸƤФ��.
 * �����δؿ���˹Ԥ����������򵭽Ҥ���.
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
 *  �ץ�ե����뵡ǽ�Ѥ������
 */

/*
 *  FIQ/IRQ/NT2T/T2NT�Υեå���ͭ����
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
/* �ץ�ե��������ѿ��ν���� */
extern void c_smc_prof_init(void);

/* �ץ�ե������ͤμ��� */
extern void c_smc_prof_get(struct safeg_smc_args *args);

/* �ץ�ե��������ѿ��Υݥ��󥿼��� */
extern void c_smc_prof_get_ptr(struct safeg_smc_args *args);

/* FIQ�ѤΥեå�  */
extern void prof_fiq_hook(void);

/* IRQ�ѤΥեå�  */
extern void prof_irq_hook(void);

/* T2NT�ѤΥեå�  */
extern void prof_t2nt_hook(void);

/* NT2T�ѤΥեå�  */
extern void prof_nt2t_hook(void);

#endif /* TOPPERS_MACRO_ONLY */
#endif /* PROF_SUPPORT*/

#ifdef TOPPERS_MACRO_ONLY
/*
 *  ������֥��ѤΥޥ���ե�����
 */

/*
 *  Get processor id
 */
    .macro get_prcid cpuid_reg
       mrc p15, 0, \cpuid_reg, c0, c0, 5 /* �ץ��å�ID�μ��� */
       and \cpuid_reg, \cpuid_reg, #0x0f /* ����4bit�Τ�ͭ��(cpuid_reg <= cpu_id) */
    .endm

/*
 *  Set sp to top of Safeg stack(_smm_stack)
 */
    .macro set_smm_stack
#if TNUM_PRC == 1
       ldr sp, =_smm_stack
       ldr sp, [sp]
#else /* TNUM_PRC > 1 */
       mrc p15, 0, sp, c0, c0, 5 /* �ץ��å�ID�μ��� */
       and sp, sp, #0x0f /* ����4bit�Τ�ͭ��(sp <= cpu_id) */
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
