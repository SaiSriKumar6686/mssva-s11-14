CC=clang
CFLAGS=-g -O0 -Wall -Iinclude
CFLAGS += -fsanitize=address,undefined -g -O0

all: dataproc-agent

dataproc-agent:
	$(CC) $(CFLAGS) src/*.c -o dataproc-agent

asan:
	$(CC) $(CFLAGS) -fsanitize=address src/*.c -o dataproc-agent

clean:
	rm -f dataproc-agent
