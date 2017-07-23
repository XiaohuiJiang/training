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
#ifndef _T_SAFEG_SYSCALLS_H_
#define _T_SAFEG_SYSCALLS_H_

#include "safeg_syscalls.h"

#ifndef __ASSEMBLY__

struct safeg_smc_args {
    void *arg0;
    void *arg1;
    void *arg2;
    void *arg3;
    void *arg4;
};

static inline
void safeg_switch_to_nt(volatile struct safeg_smc_args *ret_args)
{
    ret_args->arg0 = T_SMC_SWITCH_OK;
    while (1) {
        Asm("mov r0, %0\n\t"
            "mov r1, %1\n\t"
            "smc 0\n\t"
            : /* no output */
            : "I" (T_SMC_SWITCH), "r" (ret_args)
            : "r0", "r1", "memory");
        if (ret_args->arg0 != T_SMC_SWITCH_OK) return;
    }
}

struct safeg_fifo_msg {
    unsigned int id;        /* FIFO ID */
    unsigned char *buffer;  /* data buffer address */
    unsigned int bytes;     /* number of bytes to write/read */
    int rw_bytes;           /* result: written/read bytes */
};

static inline
void safeg_fifo_write(struct safeg_fifo_msg *msg)
{
    register unsigned long r0 asm("r0") = T_SMC_FIFO_WRITE;
    register unsigned long r1 asm("r1") = (unsigned long)msg;

    Asm("smc #0"
        : /* no output */
        : "r" (r0), "r" (r1)
        : "memory");
}

static inline
void safeg_fifo_read(struct safeg_fifo_msg *msg)
{
    register unsigned long r0 asm("r0") = T_SMC_FIFO_READ;
    register unsigned long r1 asm("r1") = (unsigned long)msg;

    Asm("smc #0"
        : /* no output */
        : "r" (r0), "r" (r1)
        : "memory");
}

static inline void safeg_reboot_nt(void)
{
    Asm("mov r0, %0\n\t"
        "smc 0\n\t"
        : /* no output */
        : "I" (T_SMC_REBOOT)
        : "r0", "memory");
}

Inline void
safeg_prof_init(void)
{
    Asm("mov r0, %0\n\t"
        "smc 0\n\t"
        : /* no output */
        : "I" (T_SMC_PROF_INIT)
        : "r0", "memory");
}

Inline void
safeg_prof_get(int cpuid,
                uint32_t *p_trust_int_cnt, uint32_t *p_nontrust_int_cnt, 
                uint32_t *p_trust_exc_cnt,  uint32_t *p_nontrust_exc_cnt)
{
    struct safeg_smc_args args;

    args.arg0 = cpuid;
    args.arg1 = p_trust_int_cnt;
    args.arg2 = p_nontrust_int_cnt;
    args.arg3 = p_trust_exc_cnt;
    args.arg4 = p_nontrust_exc_cnt;

    Asm("mov r0, %0\n\t"
        "mov r1, %1\n\t"
        "smc 0\n\t"
        : /* no output */
        : "I" (T_SMC_PROF_GET), "r" (&args)
        : "r0", "r1", "memory");
}

Inline void
safeg_prof_get_ptr(int cpuid,
                uint32_t *p_trust_int_cnt, uint32_t *p_nontrust_int_cnt, 
                uint32_t *p_trust_exc_cnt,  uint32_t *p_nontrust_exc_cnt)
{
    struct safeg_smc_args args;

    args.arg0 = cpuid;

    Asm("mov r0, %0\n\t"
        "mov r1, %1\n\t"
        "smc 0\n\t"
        : /* no output */
        : "I" (T_SMC_PROF_GET_PTR), "r" (&args)
        : "r0", "r1", "memory");

    p_trust_int_cnt = args.arg1;
    p_nontrust_int_cnt = args.arg2;
    p_trust_exc_cnt = args.arg3;
    p_nontrust_exc_cnt = args.arg4;
}

#endif /* __ASSEMBLY__ */

#endif /* _T_SAFEG_SYSCALLS_H_ */
