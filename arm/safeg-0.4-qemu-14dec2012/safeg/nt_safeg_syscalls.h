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
#ifndef _NT_SAFEG_SYSCALLS_H_
#define _NT_SAFEG_SYSCALLS_H_

#include "safeg_syscalls.h"

#ifndef __ASSEMBLY__

#define Asm __asm__ volatile

static inline
void safeg_switch_to_t(int arg0, int arg1)
{
    Asm("mov r0, %0\n\t"
        "mov r1, %1\n\t"
        "mov r2, %2\n\t"
        "smc 0\n\t"
        : /* no output */
        : "I" (NT_SMC_SWITCH), "r" (arg0), "r" (arg1)
        : "r0", "r1", "r2", "memory");
}

static inline
void safeg_raise_softfiq(void)
{
    Asm("mov r0, %0\n\t"
        "smc 0\n\t"
        : /* no output */
        : "I" (NT_SMC_SOFTIRQ)
        : "r0","memory");
}

struct safeg_fifo_msg {
    unsigned int id;        /* FIFO ID */
    unsigned char *buffer;  /* data buffer address */
    unsigned int bytes;     /* number of bytes to write/read */
    int rw_bytes;           /* result: written/read bytes */
};

#define CP15_DCACHE_INVALIDATE_CLEAN() \
    __asm__ volatile ("mcr p15, 0, %0, c7, c14, 0":: "r"(0))

static inline
void safeg_fifo_write(struct safeg_fifo_msg *msg)
{
    register unsigned long r0 asm("r0") = NT_SMC_FIFO_WRITE;
    register unsigned long r1 asm("r1") = (unsigned long)msg;

    CP15_DCACHE_INVALIDATE_CLEAN();

    Asm("smc #0"
        : /* no output */
        : "r" (r0), "r" (r1)
        : "memory");

    CP15_DCACHE_INVALIDATE_CLEAN();
}

static inline
void safeg_fifo_read(struct safeg_fifo_msg *msg)
{
    register unsigned long r0 asm("r0") = NT_SMC_FIFO_READ;
    register unsigned long r1 asm("r1") = (unsigned long)msg;

    CP15_DCACHE_INVALIDATE_CLEAN();

    Asm("smc #0"
        : /* no output */
        : "r" (r0), "r" (r1)
        : "memory");

    CP15_DCACHE_INVALIDATE_CLEAN();
}

static inline
void safeg_write_reg(unsigned int val, unsigned int phy_add)
{
    CP15_DCACHE_INVALIDATE_CLEAN();

    Asm("mov r0, %0\n\t"
        "mov r1, %1\n\t"
        "mov r2, %2\n\t"
        "smc 0\n\t"
        : /* no output */
        : "I" (NT_SMC_WRITE_REG), "r" (val), "r" (phy_add)
        : "r0", "r1", "r2", "memory");

    __asm__ __volatile__ ("mcr p15, 0, %0, c7, c10, 5" : : "r" (0) : "memory");

    CP15_DCACHE_INVALIDATE_CLEAN();
}

static inline
void safeg_read_reg(unsigned int val_phy_add, unsigned int reg_phy_add)
{
    CP15_DCACHE_INVALIDATE_CLEAN();

    Asm("mov r0, %0\n\t"
        "mov r1, %1\n\t"
        "mov r2, %2\n\t"
        "smc 0\n\t"
        : /* no output */
        : "I" (NT_SMC_READ_REG), "r" (val_phy_add), "r" (reg_phy_add)
        : "r0", "r1", "r2", "memory");

    CP15_DCACHE_INVALIDATE_CLEAN();
}

static inline
void safeg_memcpy_4(unsigned int dest_phy_addr, unsigned int src_phy_add)
{
    CP15_DCACHE_INVALIDATE_CLEAN();

    Asm("mov r0, %0\n\t"
        "mov r1, %1\n\t"
        "mov r2, %2\n\t"
        "smc 0\n\t"
        : /* no output */
        : "I" (NT_SMC_MEMCPY4), "r" (dest_phy_addr), "r" (src_phy_add)
        : "r0", "r1", "r2", "r3", "r4", "r5", "r6", "memory", "cc");

    CP15_DCACHE_INVALIDATE_CLEAN();
}

#endif /* __ASSEMBLY__ */

#endif /* _NT_SAFEG_SYSCALLS_H_ */
