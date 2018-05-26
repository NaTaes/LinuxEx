Linux Inter Process Communication(IPC)
======================================

1.Pipe란?
---------
- 한 프로세스에서 다른 프로세스로 데이터 흐름을 연결할 때 Pipe란 용어를 사용한다.
- 한 프로세스의 output을 다른 프로세스의 input으로 보내는 방법

#### 1) popen()함수, pclose()함수 사용
- popen()은 파이프의 기능을 이용하여 다른 프로그램의 실행 결과를 읽어 들이거나, 다른프로그램의 표준 입력 장치로 출력 할 수 있다.

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

- pclose()은 popen()에서 열기를 한 파이프 핸들 사용을 종료한다.

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
- pipe()은 디스크립터를 이용하여 프로세스끼리 통신(IPC)을 위해 파이프를 생성한다. 단 pipe()에서 생성한 파이프는 입출력 방향이 정해져 있다.

구분|설명
----|----
헤더|unistd.h
형태|**int** pipe(**int** filedes\[2])
인수|**int** filedes\[2] 파이프의 입출력 디스크립터
반환|0 성공<br/>-1 실패
> filedes\[0] 은 파이프의 읽기 전용 디스크립터<br/>filedes\[1] 은 파이프의 쓰기 전용 디스크립터

