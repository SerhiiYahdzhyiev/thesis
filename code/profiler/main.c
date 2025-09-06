#include <cpuid.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>

#include <libsmu.h>
#include <profiler.h>

volatile static int running = 1;
static smu_obj_t smu;

static
int _get_fuse_topology(
    int fam,
    int model,
    unsigned int* ccds_enabled,
    unsigned int* ccds_disabled,
    unsigned int* cores_disabled,
    unsigned int* smt_enabled
) {
    unsigned int ccds_down,
                 ccds_present,
                 core_fuse,
                 core_fuse_addr,
                 ccd_fuse1,
                 ccd_fuse2;

    ccd_fuse1 = 0x5D218;
    ccd_fuse2 = 0x5D21C;

    if (fam == 0x17 && model != 0x71) {
        ccd_fuse1 += 0x40;
        ccd_fuse2 += 0x40;
    }

    if (
        smu_read_smn_addr(&smu, ccd_fuse1, &ccds_present) != SMU_Return_OK ||
        smu_read_smn_addr(&smu, ccd_fuse2, &ccds_down) != SMU_Return_OK
    ) {
        fprintf(stdout, "error: failed to read CCD fuses");
        return 1;
    }

    *ccds_disabled = ((ccds_down & 0x3F) << 2) | ((ccds_present >> 30) & 0x3);

    ccds_present = (ccds_present >> 22) & 0xFF;
    *ccds_enabled = ccds_present;

    if (fam == 0x19)
        core_fuse_addr = (0x30081800 + 0x598) |
            ((((*ccds_disabled & ccds_present) & 1) == 1) ? 0x2000000 : 0);
    else
        core_fuse_addr =
            (0x30081800 + 0x238) | (((ccds_present & 1) == 0) ? 0x2000000 : 0);

    if (smu_read_smn_addr(&smu, core_fuse_addr, &core_fuse) != SMU_Return_OK) {
        fprintf(stdout, "error: failed to read core fuse");
        return 1;
    }

    *cores_disabled = core_fuse & 0xFF;
    *smt_enabled = (core_fuse & (1 << 8)) != 0;
    return 0;
}

static
unsigned int _get_cores_count()
{
    unsigned int ccds_enabled,
                 ccds_disabled,
                 core_disable_map,
                 logical_cores,
                 smt,
                 fam,
                 model,
                 eax,
                 ebx,
                 ecx,
                 edx;

    __get_cpuid(0x00000001, &eax, &ebx, &ecx, &edx);
    fam = ((eax & 0xf00) >> 8) + ((eax & 0xff00000) >> 20);
    model = ((eax & 0xf0000) >> 12) + ((eax & 0xf0) >> 4);
    logical_cores = (ebx >> 16) & 0xFF;

    int err = _get_fuse_topology(
        fam, model, &ccds_enabled, &ccds_disabled, &core_disable_map, &smt
    );

    if (err) return -1;

    unsigned int cores = logical_cores;
    if (smt) cores /= 2;

    return cores;
}

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

    unsigned int cores = _get_cores_count();

    unsigned char* pm_buf = calloc(smu.pm_table_size, sizeof(unsigned char));
    ppm_table_0x240903 pmt = (ppm_table_0x240903)pm_buf;

    while(running)
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
        struct timespec t, _;
        t.tv_sec = 1;
        t.tv_nsec  = 5e8;
        nanosleep(&t, &_);
    }

    smu_free(&smu);
}
