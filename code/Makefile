CC = gcc
CFLAGS = -Iinclude -Iext/libsmu -Icommon

all: bench monitor profile

monitor: ext/libsmu/libsmu.c common/utils.c src/monitor.c
	$(CC) $(CFLAGS) -o $@ $^

profile: ext/libsmu/libsmu.c common/utils.c src/profile.c
	$(CC) $(CFLAGS) -o $@ $^

bench: src/bench.c
	$(CC) -g -O2 -Wall -o $@ $^ -I/usr/include -L/usr/lib -lEMA

clean:
	rm -f monitor profile bench
