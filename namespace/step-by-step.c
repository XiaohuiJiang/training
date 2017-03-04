#define _GNU_SOURCE
#include <sched.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <sys/mount.h>
#include <signal.h>
#include <stdio.h>

#define STACK_SIZE (1024 * 1024)

#define errExit(msg)    do { perror(msg); exit(EXIT_FAILURE); \
                        } while (0)

static char child_stack[STACK_SIZE];

int child_main(void *arg)
{
	printf("child\n");
	system("mount -t proc none /proc");
	system("mkdir /test-dir");
	mount("/home/baohua/test-dir", "/mnt", "none", MS_BIND, NULL);
	execlp("/bin/bash","bash",NULL,NULL);
	return 1;
}

int main()
{
    	pid_t child_pid;
	child_pid = clone(child_main,child_stack+STACK_SIZE,SIGCHLD | CLONE_NEWPID | CLONE_NEWNS,NULL);

	if (child_pid == -1)
        	errExit("clone");


	wait(NULL);

	return 0;
}
