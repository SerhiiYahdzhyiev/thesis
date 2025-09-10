#include <stdlib.h>
#include <unistd.h>

#include <EMA.h>

#define SIZE_CMD 128

int main(int argc, char **argv)
{
    char cmd[SIZE_CMD], cmd2[SIZE_CMD];
    int cores = sysconf(_SC_NPROCESSORS_ONLN);

    sprintf(
        cmd,
        "stress-ng --no-rand-seed --cpu %d --timeout 10s > /dev/null 2>&1",
        cores
    );
    sprintf(
        cmd2,
        "stress-ng --no-rand-seed --cpu %d --backoff 1000000 "
        "--timeout 10s > /dev/null 2>&1",
        cores
    );

    int err = EMA_init(NULL);
    if( err )
    {
        fprintf(stderr, "error: failed to initialize EMA: %d\n", err);
        return 1;
    }
    EMA_REGION_DECLARE(region1);
    EMA_REGION_DEFINE_WITH_FILTER(&region1, "static_10s", NULL);

    EMA_REGION_BEGIN(region1);

    system(cmd);

    EMA_REGION_END(region1);

    sleep(2);

    EMA_REGION_DECLARE(region2);
    EMA_REGION_DEFINE_WITH_FILTER(&region2, "idle_10s", NULL);

    EMA_REGION_BEGIN(region2);

    sleep(10);

    EMA_REGION_END(region2);

    EMA_REGION_DECLARE(region3);
    EMA_REGION_DEFINE_WITH_FILTER(&region3, "burst_10s", NULL);

    EMA_REGION_BEGIN(region3);

    system(cmd2);

    EMA_REGION_END(region3);

    err = EMA_finalize();
    if (err) {
        fprintf(stderr, "error: failed to finalize EMA: %d\n", err);
        return 1;
    }

    return 0;
}
