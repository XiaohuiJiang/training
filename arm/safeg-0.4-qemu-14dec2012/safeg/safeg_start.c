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
#include "arm.h"
#include "safeg.h"
#include "safeg_measures.h"

/*
 * コンテキストエリア
 * レジスタ退避情報の保存領域
 */
extern unsigned long NtContextSavedArea0, NtContextSavedAreaEnd0,
  TContextSavedArea0, TContextSavedAreaEnd0, NtContextBase0, TContextBase0;
extern unsigned long NtContextSavedArea1, NtContextSavedAreaEnd1,
  TContextSavedArea1, TContextSavedAreaEnd1, NtContextBase1, TContextBase1;
extern unsigned long NtContextSavedArea2, NtContextSavedAreaEnd2,
  TContextSavedArea2, TContextSavedAreaEnd2, NtContextBase2, TContextBase2;
extern unsigned long NtContextSavedArea3, NtContextSavedAreaEnd3,
  TContextSavedArea3, TContextSavedAreaEnd3, NtContextBase3, TContextBase3;

extern void SafeGStart(unsigned long *, unsigned long *);
extern unsigned long MonitorVectorTableBase;

#ifndef STACK_SIZE
#define STACK_SIZE 128          /* 128 byte stack */
#endif /*  STACK_SIZE */

#if TNUM_PRC == 1
unsigned long smm_stack[STACK_SIZE / 4];
#else /* TNUM_PRC > 1 */
unsigned long smm_stack[TNUM_PRC][STACK_SIZE / 4];
#endif /* TNUM_PRC == 1 */

#if TNUM_PRC > 1
/*
 * マルチコアサポート時にコンテキストエリアを参照するためのテーブル
 */
unsigned long *const Table_NtContextSavedArea[TNUM_PRC] = {
	&NtContextSavedArea0,
	&NtContextSavedArea1,
#if TNUM_PRC > 2
	&NtContextSavedArea2,
#endif /* TNUM_PRC > 2 */
#if TNUM_PRC > 3
	&NtContextSavedArea3
#endif /* TNUM_PRC > 3 */
};
unsigned long *const Table_TContextSavedArea[TNUM_PRC] = {
	&TContextSavedArea0,
	&TContextSavedArea1,
#if TNUM_PRC > 2
	&TContextSavedArea2,
#endif /* TNUM_PRC > 2 */
#if TNUM_PRC > 3
	&TContextSavedArea3
#endif /* TNUM_PRC > 3 */
};
unsigned long *const Table_NtContextBase[TNUM_PRC] = {
	&NtContextBase0,
	&NtContextBase1,
#if TNUM_PRC > 2
	&NtContextBase2,
#endif /* TNUM_PRC > 2 */
#if TNUM_PRC > 3
	&NtContextBase3
#endif /* TNUM_PRC > 3 */
};
unsigned long *const Table_TContextBase[TNUM_PRC] = {
	&TContextBase0,
	&TContextBase1,
#if TNUM_PRC > 2
	&TContextBase2,
#endif /* TNUM_PRC > 2 */
#if TNUM_PRC > 3
	&TContextBase3
#endif /* TNUM_PRC > 3 */
};
#endif /* TNUM_PRC > 1 */

/* stack top をアセンブラのために設定する */

#if TNUM_PRC == 1
unsigned long *const _smm_stack = &smm_stack[STACK_SIZE / 4 - 1];
#else /* TNUM_PRC > 1 */
unsigned long *const _smm_stack0 = &smm_stack[0][STACK_SIZE / 4 - 1];
unsigned long *const _smm_stack1 = &smm_stack[1][STACK_SIZE / 4 - 1];
#if TNUM_PRC > 2
unsigned long *const _smm_stack2 = &smm_stack[2][STACK_SIZE / 4 - 1];
#endif /* TNUM_PRC > 2 */
#if TNUM_PRC > 3
unsigned long *const _smm_stack3 = &smm_stack[3][STACK_SIZE / 4 - 1];
#endif /* TNUM_PRC > 3 */
#endif /* TNUM_PRC == 1 */

#ifdef SAFEG_MEASUREMENTS_ENABLE
unsigned long int safeg_latency[MAX_COUNT];
unsigned int latency_counter;
#endif /* SAFEG_MEASUREMENTS_ENABLE */

/*
 * safeg自身の初期化を行う
 */
int
safeg_init()
{
    unsigned long *t_addr;
    unsigned long *nt_addr;
    unsigned int index;
#if TNUM_PRC > 1
    int cpu_id;
#endif /* TNUM_PRC > 1 */

    /*
     * Monitor Vector Table Base Register へのアドレスを登録
     */
    CP15_MVBAR_WRITE(&MonitorVectorTableBase);

    /*
     * Non-Secure Access Control Registerの設定
     */
    CP15_NSACR_WRITE(NSACR_SETTING);

    /*
     * context areaの初期化.
     * safeg 上で動作するOSが想定しているHWリセット時の値になるように,
     * 適切な値を設定する．
     */
    // Context Area for Trust and Non-Trust
#if TNUM_PRC == 1    
    nt_addr = &NtContextSavedArea0;
    t_addr = &TContextSavedArea0;
#else /* TNUM_PRC > 1 */
    cpu_id = get_cpuid();
    nt_addr = Table_NtContextSavedArea[cpu_id];
    t_addr = Table_TContextSavedArea[cpu_id];
#endif /* TNUM_PRC == 1 */

    for (index = 0; index < sizeof(NtContextSavedAreaStruct)/4; index++) {
        nt_addr[index] = 0;
    }

    for (index = 0; index < sizeof(TContextSavedAreaStruct)/4; index++) {
        t_addr[index] = 0;
    }

    return 0;
}

#ifdef DUALOSCOM_FIFO_SUPPORT

typedef struct {
    unsigned char *buffer;
    int write_index;
    int read_index;
    int capacity;
    int count;
} fifo_buffer_t;

void fifo_buffer_init(fifo_buffer_t *fifo, void *buffer, int capacity)
{
    fifo->buffer = (unsigned char *)buffer;
    fifo->write_index = 0;
    fifo->read_index  = 0;
    fifo->capacity    = capacity;
    fifo->count       = 0;
}

void fifo_buffer_write(fifo_buffer_t *fifo, const void *data, int len, int *written)
{
    int i;
    int overflow;

    overflow = len > (fifo->capacity - fifo->count);

    if (overflow) {
        *written    = fifo->capacity - fifo->count;
        fifo->count = fifo->capacity;
    } else {
        *written    = len;
        fifo->count = fifo->count + len;
    }

    for (i=0; i<*written; i++) {
        fifo->buffer[fifo->write_index] = ((unsigned char *)data)[i];
        fifo->write_index = (fifo->write_index + 1) % fifo->capacity;
    }
}

void fifo_buffer_read(fifo_buffer_t *fifo, void *data, int len, int *read)
{
    int i;
    unsigned char *buff = (unsigned char *)data;

    if (len > fifo->count) {
        *read = fifo->count;
    } else {
        *read = len;
    }

    for(i=0; i < *read; i++) {
        buff[i] = fifo->buffer[fifo->read_index];
        fifo->read_index = (fifo->read_index + 1) % fifo->capacity;
    }

    fifo->count = fifo->count - *read;
}

#define SAFEG_FIFO_NUM_CHANNELS    2
#define SAFEG_FIFO_CHANNEL_0_SIZE  64
#define SAFEG_FIFO_CHANNEL_1_SIZE  128
unsigned char the_channel_0_buffer[SAFEG_FIFO_CHANNEL_0_SIZE];
unsigned char the_channel_1_buffer[SAFEG_FIFO_CHANNEL_1_SIZE];
fifo_buffer_t channels[SAFEG_FIFO_NUM_CHANNELS];

struct safeg_fifo_msg {
    unsigned int id;
    unsigned char *buffer;
    unsigned int bytes;
    int rw_bytes;
};

void c_safeg_fifo_init(unsigned int id)
{
    switch(id){ /* just to avoid global initialized data */
        case 0:
            fifo_buffer_init(&channels[id], the_channel_0_buffer, SAFEG_FIFO_CHANNEL_0_SIZE);
            break;
        case 1:
            fifo_buffer_init(&channels[id], the_channel_1_buffer, SAFEG_FIFO_CHANNEL_1_SIZE);
            break;
        default:
            return;
    
}

void c_safeg_fifo_write(struct safeg_fifo_msg *msg)
{
    fifo_buffer_write(&channels[msg->id], msg->buffer, msg->bytes, &msg->rw_bytes);
}

void c_safeg_fifo_read(struct safeg_fifo_msg *msg)
{
    fifo_buffer_read(&channels[msg->id], msg->buffer, msg->bytes, &msg->rw_bytes);
}

#endif /* DUALOSCOM_FIFO_SUPPORT */

/*
 * safeg_init, monitor_init に含まれない初期化を記述する
 */
int
misc_init()
{
#ifdef SAFEG_MEASUREMENTS_ENABLE

    latency_counter = 0;
#if __TARGET_ARCH_ARM == 7
    asm("mcr p15, 0, %0, c9, c12, 2"::"r"(0)); /* counter disabled */
#elif __TARGET_ARCH_ARM == 6
    asm("mcr p15, 0, %0, c15, c12, 0"::"r"(0)); /* counter disabled */
#endif /* __TARGET_ARCH_ARM */

#endif /* SAFEG_MEASUREMENTS_ENABLE */

#ifdef DUALOSCOM_FIFO_SUPPORT
    int i;
    for(i=0; i<SAFEG_FIFO_NUM_CHANNELS; i++)
        c_safeg_fifo_init(i);
#endif /* DUALOSCOM_FIFO_SUPPORT */

#ifdef PROF_SUPPORT
    c_smc_prof_init();
#endif /* PROF_SUPPORT */

    return 0;
}

int
arm_main()
{
    safeg_init();
    misc_init();
    SafeGStart((unsigned long *) NORMAL_START_ADDRESS,
               (unsigned long *) SECURE_START_ADDRESS);
    return 0;
}


/*
 *  各種フックルーチン
 */
#ifdef ENABLE_FIQ_HOOK
/*
 * FIQフックルーチン
 * 呼び出し前のスクラッチレジスタは保存してあるので, スクラッチレジスタを破壊
 * してもよい.
 */
void fiq_hook()
{
#ifdef PROF_SUPPORT
	prof_fiq_hook();
#endif /* PROF_SUPPORT */
}
#endif /* ENABLE_FIQ_HOOK */

#ifdef ENABLE_IRQ_HOOK
/*
 * IRQフックルーチン
 * 呼び出し前のスクラッチレジスタは保存してあるので, スクラッチレジスタを破壊
 * してもよい.
 */
void irq_hook()
{
#ifdef PROF_SUPPORT
	prof_irq_hook();
#endif /* PROF_SUPPORT */
}
#endif /* ENABLE_IRQ_HOOK */

#ifdef ENABLE_T2NT_HOOK
/*
 * TからNTへの遷移フックルーチン
 * 呼び出し前のスクラッチレジスタは保存してあるので, スクラッチレジスタを破壊
 * してもよい.
 */
void
t2nt_hook(void)
{
#ifdef PROF_SUPPORT
	prof_t2nt_hook();
#endif /* PROF_SUPPORT */
}
#endif /* ENABLE_T2NT_HOOK */

#ifdef ENABLE_NT2T_HOOK
/*
 * NTからTへの遷移フックルーチン
 * 呼び出し前のスクラッチレジスタは保存してあるので, スクラッチレジスタを破壊
 * してもよい.
 */
void
nt2t_hook(void)
{
#ifdef PROF_SUPPORT
	prof_nt2t_hook();
#endif /* PROF_SUPPORT */
}
#endif /* ENABLE_NT2T_HOOK */

#ifdef PROF_SUPPORT
/*
 *  プロファイル用変数
 */
unsigned int trust_int_cnt[TNUM_PRC];
unsigned int nontrust_int_cnt[TNUM_PRC];
unsigned int trust_exc_cnt[TNUM_PRC];
unsigned int nontrust_exc_cnt[TNUM_PRC];

/*
 * プロファイル用変数の初期化
 */
void
c_smc_prof_init(void)
{
	unsigned int cpu_id = get_cpuid();

	/* プロファイル用変数の初期化 */
	trust_int_cnt[cpu_id] = 0;
	nontrust_int_cnt[cpu_id] = 0;
	trust_exc_cnt[cpu_id] = 0;
	nontrust_exc_cnt[cpu_id] = 0;
}

/*
 * プロファイル値の取得
 */
void
c_smc_prof_get(struct safeg_smc_args *args)
{
	int cpu_id = (int)(args->arg0);

	*((unsigned int*)(args->arg1)) = trust_int_cnt[cpu_id];
	*((unsigned int*)(args->arg2)) = nontrust_int_cnt[cpu_id];
	*((unsigned int*)(args->arg3)) = trust_exc_cnt[cpu_id];
	*((unsigned int*)(args->arg4)) = nontrust_exc_cnt[cpu_id];
}

/*
 * プロファイル用変数のポインタ取得
 */
void
c_smc_prof_get_ptr(struct safeg_smc_args *args)
{
	unsigned int cpu_id = (int)(args->arg0);

	args->arg1 = &trust_int_cnt[cpu_id];
	args->arg2 = &nontrust_int_cnt[cpu_id];
	args->arg3 = &trust_exc_cnt[cpu_id];
	args->arg4 = &nontrust_exc_cnt[cpu_id];
}

/*
 *  FIQ用のフック
 */
void
prof_fiq_hook(void)
{
	unsigned int cpu_id = get_cpuid();

	trust_int_cnt[cpu_id]++;
}

/*
 *  IRQ用のフック
 */
void
prof_irq_hook(void)
{
	unsigned int cpu_id = get_cpuid();

	nontrust_int_cnt[cpu_id]++;
}

/*
 * T2NT用のフック
 */
void
prof_t2nt_hook(void)
{
	unsigned int cpu_id = get_cpuid();

	trust_exc_cnt[cpu_id]++;
}

/*
 * NT2T用のフック
 */
void
prof_nt2t_hook(void)
{
	unsigned int cpu_id = get_cpuid();

	nontrust_exc_cnt[cpu_id]++;
}

#endif /* PROF_SUPPORT */
