#include <stdlib.h>
#include <unistd.h>

#include <EMA.h>

#define SIZE_CMD 128
#define COOLDOWN 5

void make_cmd(char* dest, int cores, int seconds) {
    sprintf(
        dest,
        "stress-ng --no-rand-seed --cpu %d --timeout %ds 2>&1",
        cores, seconds
    );
}

int main(int argc, char **argv)
{
    char cmd[SIZE_CMD],
         cmd2[SIZE_CMD],
         cmd3[SIZE_CMD],
         cmd4[SIZE_CMD];

    int cores = sysconf(_SC_NPROCESSORS_ONLN);

    make_cmd(cmd, cores, 10);
    make_cmd(cmd2, cores, 60);
    make_cmd(cmd3, cores, 1);
    make_cmd(cmd4, cores, 5);

    int err = EMA_init(NULL);
    if( err )
    {
        fprintf(stderr, "error: failed to initialize EMA: %d\n", err);
        return 1;
    }
    EMA_REGION_DECLARE(region1);
    EMA_REGION_DEFINE_WITH_FILTER(&region1, "static_10s", NULL);

    EMA_REGION_BEGIN(region1);

    if (system(cmd) != 0) {
        fprintf(stderr,"stress-ng failed: %s\n", cmd);
    }


    EMA_REGION_END(region1);

    sleep(COOLDOWN);

    EMA_REGION_DECLARE(region2);
    EMA_REGION_DEFINE_WITH_FILTER(&region2, "idle_10s", NULL);

    EMA_REGION_BEGIN(region2);

    sleep(10);

    EMA_REGION_END(region2);

    EMA_REGION_DECLARE(region3);
    EMA_REGION_DEFINE_WITH_FILTER(&region3, "static_60s", NULL);

    EMA_REGION_BEGIN(region3);

    if (system(cmd2) != 0) {
        fprintf(stderr,"stress-ng failed: %s\n", cmd2);
    }

    EMA_REGION_END(region3);

    sleep(COOLDOWN);

    EMA_REGION_DECLARE(region4);
    EMA_REGION_DEFINE_WITH_FILTER(&region4, "burst_10s", NULL);

    EMA_REGION_BEGIN(region4);

    for (int i = 0; i < 5; i++)
    {
        if (system(cmd3) != 0) {
            fprintf(stderr,"stress-ng failed: %s\n", cmd3);
        }
        sleep(1);
    }

    EMA_REGION_END(region4);

    sleep(COOLDOWN);

    EMA_REGION_DECLARE(region5);
    EMA_REGION_DEFINE_WITH_FILTER(&region5, "burst_60s", NULL);

    EMA_REGION_BEGIN(region5);

    for (int i = 0; i < 6; i++)
    {
        if (system(cmd4) != 0) {
            fprintf(stderr,"stress-ng failed: %s\n", cmd4);
        }
        sleep(5);
    }

    EMA_REGION_END(region5);

    err = EMA_finalize();
    if (err) {
        fprintf(stderr, "error: failed to finalize EMA: %d\n", err);
        return 1;
    }

    return 0;
}
