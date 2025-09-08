CC = gcc
CFLAGS = -Iinclude -Iext/libsmu -Icommon

all: monitor profile

monitor: ext/libsmu/libsmu.c common/utils.c src/monitor.c
	$(CC) $(CFLAGS) -o $@ $^

profile: ext/libsmu/libsmu.c common/utils.c src/profile.c
	$(CC) $(CFLAGS) -o $@ $^

clean:
	rm -f monitor profile
