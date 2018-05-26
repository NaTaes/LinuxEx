Linux Signals
==============

1.시그널(signal)이란?
--------------------
- 초기 UNIX 시스템에서 간단하게 프로세스간 통신을 하기 위한 메커니즘
- 간단하고 효율적
- 프로세스나 프로세스 그룹에 보내는 짧은 메시지(식별번호)
- 커널도 시스템 이벤트를 프로세스에 알리기 위해 사용
- 프로세스에 무엇인가 발생했음을 알리는 간단한 메시지를 비동기적으로 보내는 것이다.
- 시그널을 받은 프로세스는 시그널에 따른 미리 지정된 기본 동작(default action)을 수행할 수도 있고, 사용자가 미리 정의해 놓은 함수에 의해서 무시하거나, 특별한 처리를 할 수 있다.

2.시그널(signal)종류
--------------------
번호|신호 이름|기본처리|발생조건
----|--------|-------|--------
1|SIGHUP|종료|터미널과 연결이 끊어졌을때
2|SIGINT|종료|인터럽트로 ctrl + c 입력시
3|SIGQUIT|코어 덤프|ctrl + \ 입력시
4|SIGLL|코어 덤프|잘못된 명령 사용
5|SIGTRAP|코어 덤프|trace, breakpoint에서 TRAP 발생
6|SIGABRT|코어 덤프|abort(비정상종료) 함수에 의해 발생
7|SIGBUS|코어 덤프|버스 오류시
8|SIGFPE|코어 덤프|Floating-point exception
9|SIGKILL|종료|강제 종료시
10|SIGUSR1|종료|사용자 정의 시그널1
11|SIGSEGV|코어 덤프|세그먼테이션 폴트 시
12|SIGUSR2|종료|사용자 정의 시그널2
13|SIGPIPE|코어 덤프|파이프 처리 잘못했을때
14|SIGALRM|코어 덤프|알람에 의해 발생
15|SIGTERM|종료|Process termination
16|SIGSTKFLT|종료|Coprocessor stack error
17|SIGCHLD|무시|자식 프로세스(child process)상태 변할때
18|SIGCONT|무시|중지된 프로세스 실행시
19|SIGSTOP|중지|SIGSTOP 시그널을 받으면 SIGCONT시그널을 받을때까지 프로세스 중지
20|SIGSTP|중지|ctrl + z 입력시
21|SIGTTIN|중지|Background process requires input
22|SIGTTOU|중지|Background process requires output
23|SIGURG|무시|Urgent condition on socket
24|SIGXCPU|코어 덤프|CPU time limit exceeded
25|SIGXFSZ|코어 덤프|File size limit exceeded
26|SIGVTALRM|종료|가상 타이머 종료시
27|SIGPROF|종료|Profile timer clock
28|SIGWINCH|무시|Window resizing
29|SIGIO|종료|I/O now possible
30|SIGPWR|종료|Power supply failure
31|SIGSYS|코어 덤프|system call 잘못했을때

> shell창에 kill -l을 입력하면 사용가능한 시그널(signal) 목록을 확인 할 수 있습니다.

3.시그널(signal)속성
-------------------
- signal()의 handler인자로 함수의 주소를 명시하는 대신, 다음 값 중에 하나를 명시 할 수 있다.
1. SIG_DFL
> 시그널 속성을 기본 값으로 재설정
2. SIG_IGN
> 시그널을 무시한다.
- signal()을 성공적으로 호출하면 시그널의 이전 속성이 리턴된다. 이전에 사용된 핸들러 함수의 주소이거나, 상수 SIG_DFL, SIG_IGN중 하나 일 것이다.
에러시 signal()은 SIG_ERR값을 리턴한다.

4.시그널(signal) 핸들러
----------------------
- 시그널핸들러(시그널 캐쳐)는 명시된 시그널이 프로세스로 전달되면 호출되는 함수.
- 시그널 핸들러의 실행은 언제든지 메인 프로그램의 흐름을 멈출 수 있다.
- 커널은 프로세스를 위해 핸들러를 호출하고, 핸들러가 리턴될 때 프로그램의 실행은 핸들러가 인터럽트 한 곳에서 다시 시작한다.

### - 시그널의 전달 및 핸들러 수행
![signalhandler](./../img/시그널핸들러.PNG)

5.시그널(signal) 실습 코드
-------------------------
#### 1) SIG_INT와 SIG_QUIT를 받는 시그널 핸들러
signal()은 시그널 처리를 설정한다.

구분|설명
----|----
헤더|signal.h
형태|**void**(\*signal(**int** signum, **void** (\*handler)(**int**)))(**int**)
인수|**int** signum 시그널 번호<br />**void** (\*handler)(**int**) 시그널을 처리할 핸들러
반환|**void** \*()(**int**) 이전에 설정된 시그널 핸들러

유형|의미
----|----
SIG_DFL|기본값으로 설정한다.
SIG_IGN|시그널을 무시한다.
함수이름|시그널이 발생하면 지정된 함수를 호출한다.

kill()은 프로세스에 시그널을 전송한다.

구분|설명
----|----
헤더|signal.h
형태|**int** kill(pid_t pid, **int** sig)
인수|pid_t pid 시그널을 받을 프로세스 ID<br />**int** sig 시그널 번호
반환|0 성공<br />-1 실패

pid|의미
----|----
양의 정수|지정한 프로세스 ID에만 시그널을 전송
0|함수를 호출하는 프로세스와 같은 그룹에 있는 모든 프로세스에 시그널을 전송
-1|함수를 호출하는 프로세스가 전송할 수 있는 권한을 가진 모든 프로세스에 시그널을 전송
-1 이외의 음수|첫번째 인수 pid 의 절대값 프로세스 그룹에 속하는 모든 프로세스에 시그널을 전송

```c
#include<stdio.h>
#include<signal.h>
#include<unistd.h>
#include<stdlib.h>

static void sigHandler(int sig)
{
	static int count1 = 0; //SIGINT을 count
	static int count2 = 0; //SIGQUIT을 count
	{
		if(sig == SIGINT) //SIGINT이면 실행
		{
			count1++;
			printf("Caught SIGINT (%d)\n", count1);
		}
		else if(sig == SIGQUIT) //SIGQUIT이면 실행
		{
			count2++;
			printf("Caught SIGQUIT (%d)\n", count2);
		}
		else //그외의 signal일때 실행
			printf("Caught else signal\n");
		return;
	}
	exit(0);
}

int main(int argc, char *argv[])
{
	if(signal(SIGINT, sigHandler) == SIG_ERR) //signal()이 호출이 되지 않았을 시 SIG_ERR를 리턴 => return -1
		return -1;

	if(signal(SIGQUIT, sigHandler) == SIG_ERR)
		return -1;

	for(;;) //무한 루프
	pause(); //시그널 대기
}
```

#### 2) SIG_INT시그널 다른 프로세스에 보내기
```c
//SIG_INT를 받는 코드
#include<stdio.h>
#include<signal.h>
#include<unistd.h>

void sigHandler(int sig)
{
	printf("\nkillTest:i got signal %d\n", sig); //시그널 핸들러가 받은 시그널 번호를 출력한다.
	(void)signal(SIGINT, SIG_DFL); //SIGINT를 SIG_DFL(디폴트) 기본값으로  재설정한다.
}

int main(void)
{
	signal(SIGINT, sigHandler); //SIGINT를 시그널 핸들러로 등록한다.
	while(1)
	{
		printf("Hello world\n");
		sleep(1);
	}
}
```
```c
//SIG_INT를 보내는 코드
#include<signal.h>
#include<string.h>
#include<stdio.h>
#include<stdlib.h>
#include<errno.h>

int main(int argc, char *argv[])
{
	int s, sig;
	if(argc != 3 || strcmp(argv[1], "--help") == 0) //인자가 3개가 아니거나 첫번째 인자에 --help를 입력했을시 에러를 출력한다.
		printf("%s pid sig-num\n", argv[0]);
	sig = atoi(argv[2]); //두번째 인자(시그널 번호)를 int로 변환해 준다.
	s = kill(atoi(argv[1]), sig); //kill 함수로 첫번째인자인 시그널을 보낼 pid에 sig(보낼 시그널)을 보낸다.

	if(sig!=0)
	{
		if(s == -1) //kill함수의 반환 값이 -1이라면 kill이 실행되지 않았다는 것이다.
			printf("ERROR : system call kill\n");
		else
			if(s == 0) //반환 값이 0이라면 kill함수가 제대로 실행된것이다.
				printf("Process exists and we can send it a signal\n");
			else //그 외
			{
				if(errno == EPERM)
					printf("Process exists, but we don't have permission to send it a signal\n");
				else if(errno == ESRCH)
					printf("Process does not exist\n");
				else
					printf("kill\n");
			}
	}
	return 0;
}

```

#### 3) 두 프로세스간 양방향 시그널 보내기
- concept
> process1(kill) → process2(pause)<br/>process1(pause) ← process2(kill)
```c
//process1
#include<stdio.h>
#include<stdlib.h>
#include<signal.h>
#include<unistd.h>
#include<sys/types.h>
#include<sys/stat.h>
#include<fcntl.h>
#include<string.h>

static void sigHandler(int sig)
{
	static int count = 0;
	{
		count++;
		printf("sigGen1 : SIGINT %d\n", count);
		if(count == 5) //시그널 핸들러를 5번 실행하면 실행한다.
		{
			(void)signal(SIGINT, SIG_DFL); //SIGINT를 기본값으로 재설정한다.
			kill(getpid(), SIGINT); //자신의 PID를 읽어와 자기 자신에게 SIGINT를 보낸다.
		}
		return;
	}
}

int main(int argc, char *argv[])
{
	pid_t pid;
        int fd, bytecount;
	int s;
	char buf[10]; //자신의 PID를 저장할 버퍼
	if(signal(SIGINT, sigHandler) == SIG_ERR) //SIGINT를 sigHandler함수에 등록
		printf("ERROR :system SIGINT\n");
	pid = getpid(); //자신의 PID를 읽는다.
	sprintf(buf, "%d", pid); //pid의 값을 buf에 저장한다.(문자열)
	//pidfile.txt를 오픈한다.(읽기쓰기모드, 생성, 파일비우기)
	fd = open("./pidfile.txt", O_RDWR | O_CREAT | O_TRUNC, \
			S_IRWXU | S_IWGRP | S_IRGRP | S_IROTH);
	bytecount = write(fd, buf, strlen(buf)); //파일에 buf값을 쓴다.
	if(bytecount == 0) //write가 제대로 실행되지 않으면 0을 리턴함으로 에러를 호출한다.
		printf("ERROR : system write pid number to pidfile.txt\n");
	close(fd); //파일을 닫는다.

	if(argc!=2 || strcmp(argv[1], "--help") == 0)
		printf("ERROR : system segment default\n");

	while(1)
	{
		s = kill(atoi(argv[1]), SIGINT); //1번째 인자인 process2의 pid에 SIGINT 시그널을 보낸다.
		if(s == -1) //kill함수 비정상 처리
			printf("ERROR : system don't send signal kill\n");
		else 
			if(s == 0) //kill함수 정상 처리
				printf("Process exists and we can send it a signal\n");
		pause(); //pause상태로 다음 시그널을 기다린다.
		sleep(1);
	}
}
```

```c
//process2
#include<stdio.h>
#include<stdlib.h>
#include<signal.h>
#include<unistd.h>
#include<sys/types.h>
#include<sys/stat.h>
#include<fcntl.h>
#include<string.h>

pid_t pid; //process1의 pid를 저장할 변수
static void sigHandler(int sig)
{
	static int count = 0;
	{
		count++;
		printf("sigGen2 : SIGINT %d\n", count);
		if(count == 5)
		{
			kill(pid, SIGINT); //process1에 SIGINT 시그널을 보낸다.
			(void)signal(SIGINT, SIG_DFL); //SIGINT를 기본값으로 설정한다.
			kill(getpid(), SIGINT); //자신의 PID값을 읽어 자기자신에게 SIGINT를 보낸다.
		}
		return;
	}
}

int main(int argc, char *argv[])
{
	int fd, bytecount;
	int s;
	char buf[10];
	if(signal(SIGINT, sigHandler) == SIG_ERR)
		printf("ERROR :system SIGINT\n");

	while(1)
	{
		pause(); //pause상태로 다음 시그널을 기다린다.

		sleep(1);
		fd = open("./pidfile.txt", O_RDONLY); //process1의 PID값이 저장된 pidfile.txt를 읽기모드로 연다.
		bytecount = read(fd, buf, 10); //buf에 PID값을 읽어온다.
		if(bytecount == 0) //read가 제대로 실행되지 않았다면 0을 리턴하므로 에러를 출력한다.
			printf("ERROR : system write pid number to pidfile.txt\n");
		close(fd); //파일을 닫는다.

		pid = atoi(buf); //buf(string)의 값을 int로 바꾼다.
		s = kill(pid, SIGINT); //
	
		if(s == -1)
			printf("ERROR : system don't send signal kill\n");
		else 
			if(s == 0)
				printf("Process exists and we can send it a signal\n");
	}
}
```

#### 4) raise()함수 사용
raise()은 프로세스 자신에게 시그널을 보낸다.<br />kill(getpid(), SIGINT) == raise(SIGINT)

구분|설명
----|----
헤더|signal.h
형태|**int** raise(**int** sig)
인수|**int** sig	전송하려는 시그널 번호
반환|0 성공<br />0 이외의 값 실패

```c
#include<stdio.h>
#include<signal.h>
#include<unistd.h>

void sigHandler(int sig)
{
	printf("raise() : i got signal %d\n", sig);
	(void)signal(SIGINT, SIG_DFL);
}

int main(void)
{
	int count = 0;
	signal(SIGINT, sigHandler);
	while(1)
	{
		printf("Hello World\n");
		count++;
		if(count == 3) //count가 3이 된다면 실행한다.
		{
			raise(SIGINT); //SIGINT를 발생시킨다. kill(getpid(), SIGINT)와 동일하게 수행된다.
			count = 0;
		}
		sleep(1);
	}
}
```

#### 5) sigemptyset()함수, sigaddset()함수, sigprocmask()함수, sigpending()함수, sigismember()함수 사용
sigemptyset()은 signal sets를 비운다.

구분|설명
----|----
헤더|signal.h
형태|**int** sigemptyset(sigset_t \*set)
인수|signal_t \*set 시그널 집합 변수
반환|0 집합변수를 성공적으로 비웠음<br />-1 실패

sigaddset()은 signal sets에 시그널을 추가한다.

구분|설명
----|----
헤더|signal.h
형태|**int** sigaddset(sigset_t \*set, **int** signum)
인수|signal_t \*set 시그널 집합 변수<br />**int** signum 시그널 번호
반환|0 집합변수를 성공적으로 비웠음<br />-1 실패

sigprocmask()은 시그널 집합에 대해 how 인수값에 따라 블록 여부를 지정합니다.

구분|설명
----|----
헤더|signal.h
형태|**int** sigprocmask(**int** how, **const** sigset_t \*set, sigset_t \*oldset)
인수|**int** how 시그널 집합을 어떻게 처리할지 방법을 지정<br />signal_t \*set 이번에 설정할 시그널 집합<br />signal_t \*oldset 이전에 블록된 시그널 집합
반환|0 성공<br />-1 실패

how|의미
---|----
SIG_BLOCK|기존에 블록화된 시그널 집합에 두번째 인수 set 시그널 집합을 추가
SIG_UNBLOCK|기존에 블록화된 시그널 집합에서 두번째 인수 set 시그널 집합에 있는 시그널을 제거
SIG_SETMASK|이전 블록된 시그널 집합을 모두 지우고 두 번째 인수인 set 시그널 집합으로 설정

sigpending()은 시그널을 블록된 상태에서 어떤 시그널이 발생해서 블록되었는지를 알 수 있습니다. 즉, 발생했지만 블록되어 대기 중인 시그널이 무엇인지를 확인합니다.

구분|설명
----|----
헤더|signal.h
형태|**int** sigpending(sigset_t \*set)
인수|signal_t \*set 블록화된 시그널집합을 담을 변수
반환|0 성공<br />-1 실패

sigismember()은 시그널 집합 변수에 지정한 시그널이 있는지를 확인합니다.

구분|설명
----|----
헤더|signal.h
형태|**int** sigismember(sigset_t \*set, **int** signum)
인수|signal_t \*set 시그널 집합 변수<br />**int** signum 확인할 시그널 번호
반환|1 집합에 시그널이 있음<br />0 집합에 시그널이 없음<br />-1 확인에 실패했음

```c
#include<signal.h>
#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>

static void sigHandler(int);

int main(void)
{
	sigset_t newmask, oldmask, pendmask;

	if(signal(SIGQUIT, sigHandler) == SIG_ERR)
		printf("can't catch SIGQUIT\n");

	if(signal(SIGINT, sigHandler) == SIG_ERR)
		printf("can't catch SIGINT\n");

	sigemptyset(&newmask); //newmask를 비운다.(signal sets를 전부 0으로 비운다.)
	sigaddset(&newmask, SIGQUIT); //newmask(signal sets)에 SIGQUIT을 set한다.
	if(sigprocmask(SIG_BLOCK, &newmask, &oldmask) < 0) //newmask를 이용해 SIG_BLOCK처리를 한다. 원래 가지고 있던 signal sets는 oldmask에 저장한다.
		printf("SIG_BLOCK ERROR\n"); //sigprocmask함수의 리턴값이 0보다 작다면 함수가 비정상작동했음으로 에러메세지를 띄운다.

	sleep(10);
	if(sigpending(&pendmask) < 0) //sigpending함수를 사용해서 현재 처리되지 않은 signal을 확인 후 pendmask에 저장
		printf("sigpending ERROR\n"); //sigpending함수의 리턴값이 0보다 작다면 함수가 비정상작동했음으로 에러메세지를 띄운다.
	if(sigismember(&pendmask, SIGQUIT)) //sigismember함수를 사용해서 pendmask에 SIGQUIT이 set되었는지 확인한다.(set되었다면 1을 리턴)
		printf("SIGQUIT pending\n");

	if(sigprocmask(SIG_SETMASK, &oldmask, NULL) < 0) //원래 signal sets의 값을 저장한 oldmask를 다시 SIG_SETMASK를 이용해 set해준다.
		printf("SIG_SETMASK ERROR\n");
	printf("SIGQUIT UNBLOCKED\n");

	sleep(10);
	exit(0);
}

static void sigHandler(int signo)
{
	printf("caught signal %d\n", signo);
}
```

#### 6) sigaction()함수 사용
sigaction()은 signal()보다 향상된 기능을 제공하는 시그널 처리를 결정하는 함수다.

구분|설명
----|----
헤더|signal.h
형태|**int** sigaction(**int** signum, **const struct** sigaction \*act, **struct** sigaction \*oldact);
인수|**int** signum 시그널 번호<br />**struct** sigaction \*act 설정할 행동. 즉, 새롭게 지정할 처리 행동<br />**struct** sigaction \*oldact 이전 행동, 이 함수를 호출하기 전에 지정된 행동 정보가 입력됩니다.
반환|0 성공<br />-1	실패

```
struct sigaction {
    void (*sa_handler)(int); //시그널을 처리하기 위한 핸들러. SIG_DFL, SIG_IGN 또는 핸들러 함수
    void (*sa_sigaction)(int, siginfo_t *, void *); //밑의 sa_flags가 SA_SIGINFO일때 sa_handler 대신에 동작하는 핸들러
    sigset_t sa_mask; //시그널을 처리하는 동안 블록화할 시그널 집합의 마스크
    int sa_flags; //아래 설명을 참고하세요.
    void (*sa_restorer)(void); //사용해서는 안됩니다.
}
```

옵션|의미
----|---
SA_NOCLDSTOP|signum이 SIGCHILD일 경우 자식 프로세스가 멈추었을 때 부모 프로세스에 SIGCHILD가 전달되지 않는다.
SA_ONESHOT<br />또는 SA_RESETHAND|시그널을 받으면 설정된 행도을 취하고 시스템 기본 설정인 SIG_DFL로 재설정된다.
SA_RESTART|시그널 처리에 의해 방해 받은 시스템 호출은 시그널 처리가 끝나면 재시작한다.
SA_NOMASK<br />또는 SA_NODEFER|시그널을 처리하는 동안에 전달되는 시그널은 블록되지 않는다.
SA_SIGINFO|이 옵션이 사용되면 sa_handler대신에 sa_sigaction이 동작되며, sa_handler 보다 더 다양한 인수를 받을 수 있습니다. sa_sigaction이 받는 인수에는 시그널 번호, 시그널이 만들어진 이유, 시그널을 받는 프로세스의 정보입니다.

```c
#include<signal.h>
#include<stdio.h>
#include<unistd.h>

void sigHandler(int sig)
{
	printf("system : get signal %d\n", sig);
}

int main()
{
	struct sigaction act; //sigaction 구조체 선언
	act.sa_handler = sigHandler; //핸들러 지정
	sigemptyset(&act.sa_mask); //sa_mask를 비운다.
	act.sa_flags = 0;
	sigaction(SIGINT, &act, 0); //SIGINT 처리를 설정
	while(1)
	{
		printf("Hello world\n");
		sleep(1);
	}
}
```

#### 7) 6번코드 + sigaction()
```c
#include<signal.h>
#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>

static void sigHandler(int);

int main(void)
{
	sigset_t newmask, oldmask, pendmask;
	struct sigaction act;

	act.sa_handler = sigHandler;
	sigemptyset(&act.sa_mask);
	act.sa_flags = 0;

	//바뀐부분-------------------------------------
	
	if(sigaction(SIGQUIT, &act, NULL) == -1)
		printf("can't catch SIGQUIT\n");
	if(sigaction(SIGINT, &act, NULL) == -1)
		printf("can't catch SIGINT\n");
		
	//if(signal(SIGQUIT, sigHandler) == SIG_ERR)
	//	printf("can't catch SIGQUIT\n");

	//if(signal(SIGINT, sigHandler) == SIG_ERR)
	//	printf("can't catch SIGINT\n");

	//---------------------------------------------
	
	sigemptyset(&newmask);
	sigaddset(&newmask, SIGQUIT);
	if(sigprocmask(SIG_BLOCK, &newmask, &oldmask) < 0)
		printf("SIG_BLOCK ERROR\n");
	printf("SIGQUIT is BLOCKED\n");

	sleep(10);

	if(sigpending(&pendmask) < 0)
		printf("sigpending ERROR\n");
	if(sigismember(&pendmask, SIGQUIT))
		printf("SIGQUIT pending\n");

	if(sigprocmask(SIG_SETMASK, &oldmask, NULL) < 0)
		printf("SIG_SETMASK ERROR\n");
	printf("SIGQUIT UNBLOCKED\n");
	
	sleep(10);
	exit(0);
}

static void sigHandler(int signo)
{
	printf("caught signal %d\n", signo);
}
```

#### 8) sigsuspend()함수
sigsuspend()은 시그널 블록을 설정하고, 시그널이 도착할 때 까지 프로세스를 중단합니다.

구분|설명
----|----
헤더|signal.h
형태|**int** sigsuspend(**const** sigset_t \*mask);
인수|sigset_t \*mask 블록될 시그널 집합
반환|0 성공<br />-1	실패

abort()은 강제로 프로그램을 비정상적으로 종료시킨다.

구분|설명
----|----
헤더|stdlib.h
형태|**void** abort(**void**)

```c
#include<stdio.h>
#include<signal.h>
#include<stdio.h>
#include<stdlib.h>

volatile sig_atomic_t quitflag;

static void sigHandler(int signo)
{
	if(signo == SIGINT) //SIGINT일때 실행
		printf("\ninterrupt SIGINT\n");
	else if(signo == SIGQUIT) //SIGQUIT일때 실행
		quitflag = 1;
}

int main(void)
{
	sigset_t newmask, oldmask, zeromask;

	if(signal(SIGINT, sigHandler) == SIG_ERR)
		printf("ERROR : system signal(SIGINT)\n");
	if(signal(SIGQUIT, sigHandler) == SIG_ERR)
		printf("ERROR : system signal(SIGQUIT)\n");

	sigemptyset(&zeromask); //zeromask를 비운다.
	sigemptyset(&newmask); //newmask를 비운다.
	sigaddset(&newmask, SIGQUIT); //newmask에 SIGQUIT을 추가한다.

	if(sigprocmask(SIG_BLOCK, &newmask, &oldmask) < 0) //SIGQUIT을 블록시킨다.
		printf("ERROR : system SIG_BLOCK\n");

	while(quitflag == 0) //quitflag가 0이면 실행
		sigsuspend(&zeromask); //zeromask는 비워져있기 때문에 sigsuspend는 모든 시그널을 기다리고 있다.
		//현재 SIGQUIT은 블록되에 있지만, sigsuspend()는 블록되어 있는 대기 시그널도 확인한다.
		//zeromask에 SIGQUIT을 추가한다면, sigsuspend()는 SIGQUIT는 기다리지 않는다.

	if(sigprocmask(SIG_SETMASK, &oldmask, NULL) < 0)
		printf("ERROR : system SIG_SETMASK\n");

	abort(); //프로그램을 비정상적으로 종료시킨다.
	exit(0);
}
```

#### 9) 시간 받기

```
#include<stdio.h>
#include<time.h>
#include<sys/time.h> //for gettimeofday() function
#include<stdlib.h>

#define BUFSIZE 256

int main(int argc, char *argv[])
{
	int i, j;
	time_t UTCtime;
	struct tm *tm;
	char buf[BUFSIZE];
	struct timeval UTCtime_u;

	time(&UTCtime); //현재시간을 UTCtime에 저장
	printf("time : %u\n", (unsigned)UTCtime); //UTC 현재 시간 출력

	gettimeofday(&UTCtime_u, NULL); //UTC 현재 시간을 micro초 단위로 가져온다.
	printf("gettimeofday : %ld/%d\n", UTCtime_u.tv_sec, UTCtime_u.tv_usec);

	printf("ctime : %s", ctime(&UTCtime)); //현재 시간을 문자열로 바꿔서 출력한다.

	tm = localtime(&UTCtime); //tm = gmtime(&UTCtime);
	printf("asctime : %s", asctime(tm)); //현재 시간을 tm 구조체를 이용해서 출력한다.

	strftime(buf, sizeof(buf), "%Y/%m/%e %A %H:%M:%S", tm); //사용자정의 시간 문자열로 set한다.

	printf("strftime : %s\n", buf);

	return 0;
}
```

#### 10) 시그널(signal)을 받았을 때 시간, 시그널 저장하기
```c
//Process1
#include<stdio.h>
#include<stdlib.h>
#include<signal.h>
#include<unistd.h>
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
			s = kill(pid, SIGINT); //Process2에 SIGINT를 보낸다.
			if(s == -1)
				printf("ERROR : system don't send signal SIGINT\n");
			else if(s == 0)
				printf("Process exists and we can send it a signal\n");
			count1++;
			printf("SEND SIGNAL SIGINT %d : %d\n", sig, count1);
		}
		else if(sig == SIGQUIT)
		{
			s = kill(pid, SIGQUIT); //Process2에 SIGQUIT을 보낸다.
			if(s == -1)
				printf("ERROR : system don't send signal SIGQUIT\n");
			else if(s == 0)
				printf("Process exists and we can send it a signal\n");
			count2++;
			printf("SEND SIGNAL SIGQUIT %d : %d\n", sig, count2);
			if(count2 == 5) //SIGQUIT이 5번 발생되면 실행한다.
			{
				quitflag = 1;
				s = kill(pid, SIGUSR2); //Process2에 SIGUSR2를 보낸다.
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

	if(signal(SIGINT, sigHandler) == SIG_ERR)
		printf("ERROR :system SIGINT\n");
	if(signal(SIGQUIT, sigHandler) == SIG_ERR)
		printf("ERROR :system SIGQUIT\n");

	if(argc!=2 || strcmp(argv[1], "--help") == 0)
		printf("ERROR : system segment default\n");
	pid = atoi(argv[1]);

	s = kill(atoi(argv[1]), SIGUSR1); //Process1에 SIGUSR1을 보낸다.
	if(s == -1)
		printf("ERROR : system don't send signal SIGUSR1\n");
	else if(s == 0)
		printf("Process exists and we can send it a signal\n");

	printf("IF SIGQUIT COUNT == 5, you send signal SIGUSR2\n");
	while(quitflag == 0)
		sleep(1);

	exit(0);
}
```

```c
//Process2
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
```
