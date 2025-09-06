CC = gcc

all: profiler

profiler: ext/libsmu/libsmu.c main.c
	$(CC) -Iinclude -Iext/libsmu -o $@ $^

clean:
	rm -rf profiler
