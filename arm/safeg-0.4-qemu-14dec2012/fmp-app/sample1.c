#include <kernel.h>
#include <t_syslog.h>
#include <t_stdlib.h>
#include <sil.h>
#include "syssvc/serial.h"
#include "syssvc/syslog.h"
#include "kernel_cfg.h"
#include "sample1.h"

/*
 *  サービスコールのエラーのログ出力
 */
Inline void
svc_perror(const char *file, int_t line, const char *expr, ER ercd)
{
        if (ercd < 0) {
                t_perror(LOG_ERROR, file, line, expr, ercd);
        }
}

#define SVC_PERROR(expr)        svc_perror(__FILE__, __LINE__, #expr, (expr))

/*
 * Periodic task
 */
void task(intptr_t exinf)
{
        static int i = 0;

        syslog(LOG_EMERG, "task %d", i++);
}

#ifdef TOPPERS_SAFEG_SECURE
void btask(intptr_t exinf)
{
    syslog(LOG_NOTICE, "BTASK Starts");
    while(1)
        Asm("smc #0");
}
#endif /* TOPPERS_SAFEG_SECURE */

/*
 * Cyclic handler
 */
void cyclic_handler(intptr_t exinf)
{
        SVC_PERROR(iact_tsk(TASK1_1));
}

/*
 * Main task
 */
void main_task(intptr_t exinf)
{
        ER_UINT ercd;

        SVC_PERROR(syslog_msk_log(0, LOG_UPTO(LOG_DEBUG)));
        syslog(LOG_NOTICE, "Simple starts (exinf = %d).", (int_t) exinf);

        ercd = serial_opn_por(TASK_PORTID_G_SYSLOG);
        if (ercd < 0 && MERCD(ercd) != E_OBJ) {
                syslog(LOG_ERROR, "%s (%d) reported by `serial_opn_por'.",
                       itron_strerror(ercd), SERCD(ercd));
        }
        SVC_PERROR(serial_ctl_por(TASK_PORTID_G_SYSLOG,
                                  (IOCTL_CRLF | IOCTL_FCSND | IOCTL_FCRCV)));

#ifdef TOPPERS_SAFEG_SECURE
        syslog(LOG_NOTICE, "Hello T-FMP");
#else
        syslog(LOG_NOTICE, "Hello NT-FMP");
#endif /* TOPPERS_SAFEG_SECURE */

        SVC_PERROR(sta_cyc(CYCHDR1)); // start the cyclic handler

        syslog(LOG_NOTICE, "Main goes to sleep.");
        SVC_PERROR(slp_tsk());
        SVC_PERROR(ext_ker());
        assert(0);
}
