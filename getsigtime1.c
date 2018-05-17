#include<stdio.h>
#include<stdlib.h>
#include<signal.h>
#include<unistd.h>
#include<sys/types.h>
#include<sys/stat.h>
#include<fcntl.h>
#include<string.h>

pid_t pid;
volatile sig_atomic_t quitflag;

static void sigHandler(int sig)
{
	static int count1 = 0;
	static int count2 = 0;
	int s;
	{
		if(sig == SIGINT)
		{
			s = kill(pid, SIGINT);
			if(s == -1)
				printf("ERROR : system don't send signal SIGINT\n");
			else if(s == 0)
				printf("Process exists and we can send it a signal\n");
			count1++;
			printf("SEND SIGNAL SIGINT %d : %d\n", sig, count1);
		}
		else if(sig == SIGQUIT)
		{
			s = kill(pid, SIGQUIT);
			if(s == -1)
				printf("ERROR : system don't send signal SIGQUIT\n");
			else if(s == 0)
				printf("Process exists and we can send it a signal\n");
			count2++;
			printf("SEND SIGNAL SIGQUIT %d : %d\n", sig, count2);
			if(count2 == 5)
			{
				quitflag = 1;
				s = kill(pid, SIGUSR2);
				if(s == -1)
					printf("ERROR : system don't send signal SIGUSR2\n");
				else if(s == 0)
					printf("Process exists and we can send it a signal\n");
			}
		}
		return;
	}
}

int main(int argc, char *argv[])
{
	int s;

	sigset_t zeromask;
	if(signal(SIGINT, sigHandler) == SIG_ERR)
		printf("ERROR :system SIGINT\n");
	if(signal(SIGQUIT, sigHandler) == SIG_ERR)
		printf("ERROR :system SIGQUIT\n");

	if(argc!=2 || strcmp(argv[1], "--help") == 0)
		printf("ERROR : system segment default\n");
	pid = atoi(argv[1]);

	s = kill(atoi(argv[1]), SIGUSR1);
	if(s == -1)
		printf("ERROR : system don't send signal SIGUSR1\n");
	else if(s == 0)
		printf("Process exists and we can send it a signal\n");

	printf("IF SIGQUIT COUNT == 5, you send signal SIGUSR2\n");
	while(quitflag == 0)
		sleep(1);

	exit(0);
}
