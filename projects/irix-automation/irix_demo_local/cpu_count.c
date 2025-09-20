#include <stdio.h>
#include <sys/sysmp.h>

int main(void) {
    long nproc;

    nproc = sysmp(MP_NPROCS, 0);
    if (nproc < 0) {
        perror("sysmp(MP_NPROCS)");
        return 1;
    }

    printf("CPUs online: %ld\n", nproc);
    return 0;
}
