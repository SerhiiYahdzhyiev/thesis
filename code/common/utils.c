#include <cpuid.h>
#include <stdio.h>
#include <libsmu.h>

int _get_fuse_topology(
    smu_obj_t* smu,
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
        smu_read_smn_addr(smu, ccd_fuse1, &ccds_present) != SMU_Return_OK ||
        smu_read_smn_addr(smu, ccd_fuse2, &ccds_down) != SMU_Return_OK
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

    if (smu_read_smn_addr(smu, core_fuse_addr, &core_fuse) != SMU_Return_OK) {
        fprintf(stdout, "error: failed to read core fuse");
        return 1;
    }

    *cores_disabled = core_fuse & 0xFF;
    *smt_enabled = (core_fuse & (1 << 8)) != 0;
    return 0;
}

unsigned int get_cores_count()
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
    smu_obj_t _smu;
    smu_return_val ret = smu_init(&_smu);
    if (ret != SMU_Return_OK) {
        fprintf(
            stderr,
            "Error initializing userspace library: %s\n",
            smu_return_to_str(ret)
        );
        return 1;
    }

    __get_cpuid(0x00000001, &eax, &ebx, &ecx, &edx);
    fam = ((eax & 0xf00) >> 8) + ((eax & 0xff00000) >> 20);
    model = ((eax & 0xf0000) >> 12) + ((eax & 0xf0) >> 4);
    logical_cores = (ebx >> 16) & 0xFF;

    int err = _get_fuse_topology(
        &_smu, fam, model, &ccds_enabled, &ccds_disabled, &core_disable_map, &smt
    );

    if (err) return -1;

    unsigned int cores = logical_cores;
    if (smt) cores /= 2;

    smu_free(&_smu);

    return cores;
}
