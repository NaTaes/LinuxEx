Linux Inter Process Communication(IPC)
======================================

1.Pipe란?
---------
- 한 프로세스에서 다른 프로세스로 데이터 흐름을 연결할 때 Pipe란 용어를 사용한다.
- 한 프로세스의 output을 다른 프로세스의 input으로 보내는 방법

#### 1) popen()함수, pclose()함수 사용
popen()은 파이프의 기능을 이용하여 다른 프로그램의 실행 결과를 읽어 들이거나, 다른프로그램의 표준 입력 장치로 출력 할 수 있다.

구분|설명
----|----
헤더|stdio.h
형태|FILE \*popen(**const char** \*command, **const char** \*type);
인수|**const char** \*command 실행할 명령어<br/>**const char** \*type 통신 형태
반환|NULL 이외의 값 성공<br/>NULL 실패

type|의미
----|----
'r'|파이프를 통해 입력 받습니다.
'w'|파이프로 출력합니다.

pclose()은 popen()에서 열기를 한 파이프 핸들 사용을 종료한다.

구분|설명
----|----
헤더|stdio.h
형태|**int** pclose(FILE \*stream)
인수|FILE \*stream 닫기를 할 파일 포인터
반환|-1 이외의 값 성공<br/>-1 실패

```c
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<unistd.h>

int main()
{
	FILE *read_fp;
	char buffer[BUFSIZ + 1]; //문자열의 마지막 NULL때문에 +1을 시켜준다.
	int chars_read;

	memset(buffer, '\0', sizeof(buffer));
	read_fp = popen("cat popen4.c | wc -l", "r"); //popen4.c형태의 파일을 cat으로 출력한다. 출력한 파일의 내용을 wc -l로 라인수를 가져온다.
                                                      //popen4.c의 줄 수는 29줄이다. 그러므로 파일 read_fp에는 29\n 이 들어있다.
	if(read_fp != NULL)
	{
		chars_read = fread(buffer, sizeof(char), BUFSIZ, read_fp); //read_fp에서 buffer에 내용을 읽어온다.
		while(chars_read > 0) //읽은 내용이 있다면 실행한다.
		{
			printf("%d\n", chars_read); //3이 출력된다. \n 도 문자이기 때문이다.
			buffer[chars_read - 1] = '\0'; //\n을 \0로 만들어 보기좋게 만든다.
			printf("Reading : -\n%s\n", buffer); //29가 출력된다.
			chars_read = fread(buffer, sizeof(char), BUFSIZ, read_fp); //다시 파일 read_fp에서 내용을 buffer로 읽어들인다. 내용이 없다면 반복문을 빠져나온다.
		}
		pclose(read_fp); //파이프 핸들 사용을 종료한다.
		exit(EXIT_SUCCESS);
	}
	exit(EXIT_FAILURE);
}
```

#### 2) pipe()함수 사용
pipe()은 디스크립터를 이용하여 프로세스끼리 통신(IPC)을 위해 파이프를 생성한다. 단 pipe()에서 생성한 파이프는 입출력 방향이 정해져 있다.

구분|설명
----|----
헤더|unistd.h
형태|**int** pipe(**int** filedes\[2])
인수|**int** filedes\[2] 파이프의 입출력 디스크립터
반환|0 성공<br/>-1 실패
> filedes\[0] 은 파이프의 읽기 전용 디스크립터<br/>filedes\[1] 은 파이프의 쓰기 전용 디스크립터

![pipe1](./../img/pipe1.PNG)\[그림.1]

그림.1과 같이 pipe는 같은 출구과 입구를 사용하고 있기 때문에 만일 프로레스끼리 쌍방향 통신을 해야 한다면 Parent쪽에서 보낸 것을 child에서 읽기 전에 먼저 읽는다면 child는 읽을 수 없습니다.

![pipe2](./../img/pipe2.PNG)\[그림.2]

그렇기 때문에 그림.3과 같은 방법으로 parent의 read를 끊어버리고 child의 write를 끊어버린다면, 일방 통행이 가능한 pipe가 됩니다.

![pipe3](./../img/pipe3.PNG)\[그림.3]

결국 두개의 프로세스에서 pipe를 이용해서 read, write를 하려면 두개의 일방 통행 pipe를 생성하면 됩니다.
하지만, 서로다른 프로그램에서 실행된다면 프로세스는 디스크립터를 사용할 수 없기 때문에 FIFO를 이용해야한다.

##### 1. 하나의 pipe로 자신이 write한 내용을 자신이 read하는 코드 \[그림.1]
```c
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<unistd.h>

int main() 
{ 
	int data_processed; 
	int file_pipes[2]; 
	const char some_data[] = "123"; 
	char buffer[BUFSIZ + 1];
	memset(buffer, '\0', sizeof(buffer));
	if (pipe(file_pipes) == 0)
	{
		data_processed = write(file_pipes[1], some_data, strlen(some_data)); //pipe 쓰기 디스크립터에 some_data를 write한다.
		printf("Wrote %d bytes\n", data_processed); //읽어들인 길이를 출력
		data_processed = read(file_pipes[0], buffer, BUFSIZ); //pipe 읽기 디스크립터에서 내용을 buffer에 저장한다.
		printf("Read %d bytes: %s\n", data_processed, buffer); //buffer의 내용을 출력
		exit(EXIT_SUCCESS);
	}
	exit(EXIT_FAILURE);
}
```

##### 2. fork()를 사용해서 부모 프로세스 자식프로세스간 pipe()사용 \[그림.1]
```c
#include<unistd.h> 
#include<stdlib.h> 
#include<stdio.h> 
#include<string.h>
#include<sys/types.h>
#include<sys/wait.h>

int main() 
{ 
       	int data_processed;
	int file_pipes[2]; 
       	const char some_data[]="123"; 
       	const char some_data2[]="456"; 
	char buffer[BUFSIZ + 1]; 
	pid_t fork_result;
	int status;
     	memset(buffer,'\0', sizeof(buffer)); 
	
	if(pipe(file_pipes)==0)
	{ 
		fork_result = fork(); //자식 프로세스 생성
		if(fork_result==-1)
		{
			fprintf(stderr,"Fork failure"); 
			exit(EXIT_FAILURE);
		}
		if (fork_result == 0) 
		{ 
			sleep(1); //프로세스 속도때문에 자식이 부모의 쓰기 디스크립터를 읽어버린다.
			data_processed = write(file_pipes[1], some_data2, strlen(some_data2)); //456을 pipe 쓰기 디스크립터에 write한다.
			printf("child Wrote %d bytes\n", data_processed); //쓴 내용을 출력

			data_processed = read(file_pipes[0], buffer, BUFSIZ); //pipe 읽기 디스크립터로 read한다.
			printf("child Read %d bytes: %s\n", data_processed, buffer); //읽은 내용을 출력

			exit(EXIT_SUCCESS);
		}
		else
		{
			data_processed = write(file_pipes[1], some_data, strlen(some_data)); //123을 pipe 쓰기 디스크립터에 write한다.
			printf("parent Wrote %d bytes\n", data_processed); //쓴 내용을 출력

			data_processed = read(file_pipes[0], buffer, BUFSIZ); //pipe 읽기 디스크립터로 read한다.
			printf("parent Read %d bytes: %s\n", data_processed, buffer); //읽은 내용을 출력

			wait(&status); //자식 프로세스가 끝나기를 기다린다.
		}
	}
	exit(EXIT_SUCCESS);
}
```

##### 3. 서로 다른 프로세스간의 pipe를 이용하기 위한 argv 전달 \[그림.3]을 argv전달로 해결
- concept
> process1 -> fork() -> child : process2를 execl()로 실행 및 읽기 pipe 디스크립터 전달, parent : pipe에 쓰기<br/>process2 -> argv로 받은 pipe 읽기 디스크립터를 이용해서 pipe에서 읽기

```c
//process1
#include<unistd.h> 
#include<stdlib.h> 
#include<stdio.h> 
#include<string.h>
#include<sys/types.h>
#include<sys/wait.h>

int main() 
{ 
       	int data_processed;
	int file_pipes[2]; 
	const char some_data[]="123";
	char buffer[BUFSIZ + 1];
	int status;
	pid_t fork_result;
	memset(buffer,'\0', sizeof(buffer)); 
	if(pipe(file_pipes)==0)
	{
		fork_result = fork();
		if(fork_result==-1) //fork fail
		{
			fprintf(stderr,"Fork failure");
			exit(EXIT_FAILURE);
		}
		if(fork_result==0) //child process
		{
			sprintf(buffer,"%d", file_pipes[0]); //pipe 읽기 디스크립터를 buffer에 저장
			execl("pipe4", "pipe4", buffer, (char *)0); //process2를 실행하면서 인자값으로 buffer를 전달
			exit(EXIT_FAILURE); //실행이 제대로 되지않았다면 FAILURE
		}
		else //parent process
		{
			data_processed=write(file_pipes[1], some_data, strlen(some_data)); //pipe에 some_data를 write한다.
			printf("%d - wrote %d bytes\n", getpid(), data_processed); //자신의 pid와 쓴 길이를 출력
			wait(&status); //자식프로세스가 끝나기를 기다린다.
		}
	}
	exit(EXIT_SUCCESS);
}
```

```c
//process2
#include<unistd.h> 
#include<stdlib.h> 
#include<stdio.h> 
#include<string.h>
#include<sys/stat.h>
#include<fcntl.h>

int main(int argc, char *argv[])
{ 
	int data_processed;
	char buffer[BUFSIZ + 1];
	int file_descriptor;

	memset(buffer,'\0', sizeof(buffer)); //buffer 초기화
	sscanf(argv[1], "%d", &file_descriptor); //argv로 받은 pipe 읽기 디스크립터를 file_descriptor에 저장
       	data_processed = read(file_descriptor, buffer, BUFSIZ); //pipe에서 내용을 읽어 buffer에 저장
	printf("%d - read %d bytes: %s\n", getpid(), data_processed, buffer); //자신의 pid값과 읽은 내용을 출력
	exit(EXIT_SUCCESS);
}
```

##### 4. 부모 프로세스와 자식 프로세스간의 일방통행 pipe사용, dup()활용
dup()은 파일 디스크립터 복사본을 만든다. 원본 디스크립터와 복사된 디스크립터의 읽기/쓰기 포인터는 공유된다.

구분|설명
----|----
헤더|unistd.h
형태|**int** dup(**int** fildes)
인수|**int** fildes 파일 디스크립터
반환|복사된 파일 디스크립터 번호로 사용되지 않은 가장 작은 번호가 자동으로 지정되어 반환<br/>함수 실행이 실패되면 -1 이 반환

```c
#include<unistd.h> 
#include<stdlib.h> 
#include<stdio.h> 
#include<string.h>
#include<sys/types.h>
#include<sys/wait.h>

int main() 
{  
	int data_processed;
	int file_pipes[2]; 
	const char some_data[]="123"; 
	int fd;
	int status;
	pid_t fork_result;
	if(pipe(file_pipes)==0)
	{
		fork_result = fork(); //자식 프로세스 생성
		if(fork_result==-1)
		{ 
			fprintf(stderr,"Fork failure"); 
			exit(EXIT_FAILURE);
		}
		if(fork_result==0) //child process
		{
			close(0); //파일 디스크립터 0 = stdin, 파일 디스크립터 1 = stdout, 파일 디스크립터 2 = stderr
			fd = dup(file_pipes[0]); //읽기 전용 pipe 디스크립터를 복사
			if(fd != -1)
				printf("dup fd = %d\n", fd); //0번째 디스크립터가 없으므로 가장작은 번호인 0으로 fd값이 저장된다.
			else
				printf("can't dup\n");
			close(file_pipes[0]); //읽기 전용 pipe 디스크립터를 close
			close(file_pipes[1]); //쓰기 전용 pipe 디스크립터를 close
			//자식 프로세스는 0번째 디스크립터 위치에 복사본 읽기 전용 pipe 디스크립터만 가지고 있다.
			execlp("od", "od", "-c", (char *)0);
			//stdin(표준 입력-키보드)대신 pipe에 some_data값이 저장되어 있으므로 대체되어 od -c [pipe에 쓴 값] 으로 출력된다.
			exit(EXIT_FAILURE);
		}
		else //parent process
		{
			close(file_pipes[0]); //읽기 전용 pipe 디스크립터를 close
			//부모 프로세스는 쓰기 전용 pipe 디스크립터만 가지고 있다.
			data_processed = write(file_pipes[1], some_data, strlen(some_data)); //pipe에 some_data를 write한다
			close(file_pipes[1]); //쓰기 전용 pipe 디스크립터를 close
			printf("%d - wrote %d bytes\n", (int)getpid(), data_processed); //자신의 pid값과 pipe에 쓴 길이를 출력
			wait(&status); //자식 프로세스가 끝나기를 기다린다.
		}
	}
	exit(EXIT_SUCCESS);
}
```


2.FIFO(named pipe)란?
---------
- FIFO는 First In First Out의 줄임말이다. 먼저 입력된게 먼저 출력되는 선입선출의 데이터 구조를 의미한다.
- 전혀 관련 없는 프로세스들 사이에서 pipe를 이용해서 통신을 하려면 pipe에 이름이 주어져야한다. 그렇기 때문에 FIFO를 사용한다.
- pipe()에서 생성한 파이프를 이용하는 것은 부모, 자식 프로세스에서만 사용된다. 그러나 FIFO를 이용하면 서로 다른 프로세스에서 사용할 수 있으며, FIFO를 생성하는 파일 이름을 알고 있다면 누구나 사용할 수 있다.

##### mkfifo()함수 사용

구분|설명
----|----
헤더|sys/types.h, sys/stat.h
형태|**int** mkfifo(**const char** \*pathname, mode_t mode)
인수|**const char** \*pathname 파이프로 사용할 파일 이름<br/>mode_t mode FIFO파일에 대한 접근 권한
반환|0 성공<br/>-1 실패, errno에 에러 번호가 설정된다.

```c
#include<unistd.h> 
#include<stdlib.h> 
#include<stdio.h>
#include<sys/types.h>
#include<sys/stat.h>

int main()
{ 
	int res = mkfifo("/tmp/my_fifo", 0777); // /tmp/my_fifo를 만든다. 접근권한은 0777
	if(res == 0) 
		printf("FIFO created\n");
	exit(EXIT_SUCCESS);
}
```

3.메시지 큐 란?
---------------------

- 메시지 큐는 IPC 방법 중에 하나로 자료를 다른 프로세스로 전송할 수 있다. 전송되는 자료도 큐의 용량이 허용하는 한, 상대편이 가져가지 않는다고 하더라도 계속 전송할 수 있으며, 나중에 다른 프로세스가 큐가 비워질 때까지 계속 읽어 들일 수 있다.<br/>또한 메시지 큐는 전송한는 자료를 커널이 간직하기 때문에 전송한 프로세스가 종료되었다고 하더라고 자료가 사라지지 않는다. 즉, 전송 프로세스가 데이터를 전송한 후 종료해도, 나중에 다른 프로세스가 메시지 큐의 데이터를 가져 올 수 있다.<br/>또한 전송되는 큐의 자료는 순자적으로 가져 갈 수도 있지만 데이터 타입에 따라 원하는 자료만 가져 갈 수 있다. 즉, 메시지 큐에 전송되는 데이터 구조는 아래와 같다.

```c
struct {
   long  data_type;
   //원하는 데이터
}
```

##### 1) msgget()함수 사용
msgget()은 메시지 큐를 생성한다.

구분|설명
----|----
헤더|sys/types.h, sys/ipc.h, sys/msg.h
형태|**int** msgget (key_t key, **int** msgflg)
인수|key_t key 시스템에서 다른 큐와 구별하기 위한 번호<br/>**int** msgflg 옵션
반환|-1 이외의 메세지 큐 식별자 성공<br/>-1 실패

msgflg|의미
------|---
IPC_CREAT|key에 해당하는 큐가 있다면 큐의 식별자를 반환하며, 없으면 생성합니다.
IPC_EXCL|key에 해당하는 큐가 없다면 생성하지만 있다면 -1을 반환하고 복귀합니다.

