#include <stdio.h>
#include <unistd.h>
#include <sys/utsname.h>

int main(void) {
    struct utsname info;

    if (uname(&info) == 0) {
        printf("Hello from %s running %s %s on %s\n", info.nodename, info.sysname, info.release, info.machine);
    } else {
        perror("uname");
        return 1;
    }

    printf("Process ID: %d\n", getpid());
    return 0;
}
