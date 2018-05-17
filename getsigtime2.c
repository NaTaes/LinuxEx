#include<stdio.h>
#include<stdlib.h>
#include<signal.h>
#include<unistd.h>
#include<sys/types.h>
#include<sys/stat.h>
#include<fcntl.h>
#include<string.h>
#include<time.h>

#define BUFSIZE 256

volatile sig_atomic_t quitflag;

static void sigHandler(int sig)
{
	int i, j;
	time_t UTCtime;
	struct tm *tm;
	char buf[BUFSIZE];
        static int fd;
	int bytecount;
	
	if(sig == SIGINT || sig == SIGQUIT)
	{
		printf("GET signal %d\n", sig);
		time(&UTCtime);
		tm = localtime(&UTCtime);
		strftime(buf, sizeof(buf), "%Y-%m-%e %H:%M:%S", tm);
		if(sig==SIGINT)
			strcat(buf, " [SIGINT]\n");
		else
			strcat(buf, " [SIGQUIT]\n");

		write(fd, buf, strlen(buf));		
	}
	else if(sig == SIGUSR2)
	{
		printf("GET signal SIGUSR2 %d\n", sig);
		close(fd);
		quitflag = 1;
	}
	else if(sig == SIGUSR1)
	{
		printf("GET signal SIGUSR1 %d\n", sig);
		fd = open("./getsigtime.txt", O_RDWR | O_APPEND | O_CREAT, \
			S_IRWXU | S_IWGRP | S_IRGRP | S_IROTH);
		if(bytecount == 0)
			printf("ERROR : system write pid number to pidfile.txt\n");
	}
	return;
}

int main(int argc, char *argv[])
{
	if(signal(SIGINT, sigHandler) == SIG_ERR)
		printf("ERROR :system SIGINT\n");
	if(signal(SIGQUIT, sigHandler) == SIG_ERR)
		printf("ERROR :system SIGINT\n");
	if(signal(SIGUSR1, sigHandler) == SIG_ERR)
		printf("ERROR :system SIGINT\n");
	if(signal(SIGUSR2, sigHandler) == SIG_ERR)
		printf("ERROR :system SIGINT\n");

	while(quitflag == 0)
		sleep(1);
}
