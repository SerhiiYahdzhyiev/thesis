#include <cpuid.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>

#include <libsmu.h>
#include <pm_table.h>

volatile static int running = 1;
static smu_obj_t smu;

#include <utils.h>

void handle_signal(int sig)
{
    switch(sig) {
        case SIGINT:
        case SIGABRT:
        case SIGTERM:
            running = 0;
        default:
            break;
    }
}

int main()
{
    
    if (getuid() != 0 && geteuid() != 0) {
        fprintf(stderr, "Program must be run as root.\n");
        return 1;
    }

    smu_return_val ret = smu_init(&smu);
    if (ret != SMU_Return_OK) {
        fprintf(
            stderr,
            "Error initializing userspace library: %s\n",
            smu_return_to_str(ret)
        );
        return 1;
    }

    if (!smu_pm_tables_supported(&smu))
    {
        fprintf(stderr, "Error: pm_tabes are not supported.\n");
        return 1;
    }

    unsigned int cores = get_cores_count();

    unsigned char* pm_buf = calloc(smu.pm_table_size, sizeof(unsigned char));
    ppm_table_0x240903 pmt = (ppm_table_0x240903)pm_buf;

    int ticks = 10;

    while(running && ticks)
    {
        ret = smu_read_pm_table(&smu, pm_buf, smu.pm_table_size);
        if (ret != SMU_Return_OK)
        {
            fprintf(
                stdout,
                "failed to read pm_table: %s\n",
                smu_return_to_str(ret)
            );
        }
        fprintf(stdout, "Package Power: %f W\n", pmt->SOCKET_POWER);
        fprintf(stdout, "Core Power: %f W\n", pmt->VDDCR_CPU_POWER);
        if (cores != -1)
        {
            for(int i = 0; i < cores; i++)
            {
                fprintf(
                    stdout, "Core[%d] Power: %f W\n", i, pmt->CORE_POWER[i]
                );
            }
        }
        ticks--;
        struct timespec t, _;
        t.tv_sec = 0;
        t.tv_nsec  = 1e6;
        nanosleep(&t, &_);
    }

    smu_free(&smu);
}
