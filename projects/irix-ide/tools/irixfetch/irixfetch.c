#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pwd.h>
#include <sys/types.h>
#include <sys/utsname.h>
#include <errno.h>
#include <ctype.h>

#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

static void trim_in_place(char *s)
{
    size_t len;
    size_t start;
    size_t end;

    if (s == NULL) {
        return;
    }

    len = strlen(s);
    start = 0U;
    while (start < len && isspace((unsigned char)s[start])) {
        start++;
    }

    end = len;
    while (end > start && isspace((unsigned char)s[end - 1U])) {
        end--;
    }

    if (start > 0U) {
        memmove(s, s + start, end - start);
    }
    s[end - start] = '\0';
}

static int run_command_first_line(const char *command, char *buffer, size_t size)
{
    FILE *fp;

    if (buffer == NULL || size == 0U) {
        return 0;
    }

    buffer[0] = '\0';

    if (command == NULL) {
        return 0;
    }

    fp = popen(command, "r");
    if (fp == NULL) {
        return 0;
    }

    if (fgets(buffer, (int)size, fp) == NULL) {
        buffer[0] = '\0';
        pclose(fp);
        return 0;
    }

    pclose(fp);
    trim_in_place(buffer);
    return buffer[0] != '\0';
}

struct packages_counter {
    long count;
};

static int count_packages_callback(const char *line, void *opaque)
{
    struct packages_counter *counter;

    counter = (struct packages_counter *)opaque;
    if (counter == NULL || line == NULL) {
        return 0;
    }

    if (line[0] == 'I') {
        counter->count++;
    }
    return 0;
}

static void run_command_lines(const char *command,
                              int (*line_cb)(const char *, void *),
                              void *opaque)
{
    FILE *fp;
    char buf[512];

    if (command == NULL || line_cb == NULL) {
        return;
    }

    fp = popen(command, "r");
    if (fp == NULL) {
        return;
    }

    while (fgets(buf, sizeof(buf), fp) != NULL) {
        trim_in_place(buf);
        if (line_cb(buf, opaque) != 0) {
            break;
        }
    }

    pclose(fp);
}

static void copy_string(char *dest, size_t size, const char *src)
{
    if (dest == NULL || size == 0U) {
        return;
    }
    if (src == NULL) {
        dest[0] = '\0';
        return;
    }
    strncpy(dest, src, size - 1U);
    dest[size - 1U] = '\0';
}

static void basename_copy(char *dest, size_t size, const char *path)
{
    const char *slash;

    if (path == NULL) {
        dest[0] = '\0';
        return;
    }

    slash = strrchr(path, '/');
    if (slash != NULL) {
        copy_string(dest, size, slash + 1);
    } else {
        copy_string(dest, size, path);
    }
}

int main(void)
{
    struct utsname uts;
    struct passwd *pw;
    char username[128];
    char hostname[256];
    char model[256];
    char cpu[256];
    char graphics[256];
    char memory[256];
    char uptime[256];
    char packages[64];
    char shell_name[128];
    char term_name[128];
    char os_display[256];
    char line[512];
    const char *env;
    const char *reset;
    const char *bold;
    const char *color1;
    const char *color2;
    const char *color3;
    int color_enabled;
    struct packages_counter counter;

    const char *ascii_art[] = {
        "%s         _______%s",
        "%s      .-'  _   '-.%s",
        "%s    .'   (_)     '.%s",
        "%s   /   .-----.     \\%s",
        "%s  ;   /  _   \\     ;%s",
        "%s  |  ;  (_)   ;    |%s",
        "%s  |  |         |   |%s",
        "%s  |  ;  _____  ;   |%s",
        "%s  ;   \\       /    ;%s",
        "%s   \\   '.___.'    /%s",
        "%s    '.         .'%s",
        "%s      '-.___.-'%s"
    };
    char info_lines[10][512];
    size_t info_count;
    size_t i;

    memset(&uts, 0, sizeof(uts));

    color_enabled = 0;
    if (isatty(STDOUT_FILENO)) {
        env = getenv("IRIXFETCH_NO_COLOR");
        if (!(env != NULL && strcmp(env, "1") == 0)) {
            env = getenv("NO_COLOR");
            if (env == NULL) {
                color_enabled = 1;
            }
        }
    }

    if (color_enabled) {
        reset = "\033[0m";
        bold = "\033[1m";
        color1 = "\033[35m";
        color2 = "\033[36m";
        color3 = "\033[34m";
    } else {
        reset = "";
        bold = "";
        color1 = "";
        color2 = "";
        color3 = "";
    }

    env = getenv("USER");
    if (env != NULL && env[0] != '\0') {
        copy_string(username, sizeof(username), env);
    } else {
        pw = getpwuid(geteuid());
        if (pw != NULL && pw->pw_name != NULL) {
            copy_string(username, sizeof(username), pw->pw_name);
        } else {
            copy_string(username, sizeof(username), "user");
        }
    }

    if (gethostname(hostname, sizeof(hostname)) != 0) {
        copy_string(hostname, sizeof(hostname), "irix");
    }
    hostname[sizeof(hostname) - 1U] = '\0';

    if (uname(&uts) == 0) {
        copy_string(os_display, sizeof(os_display), uts.sysname);
        if (uts.release[0] != '\0') {
            strncat(os_display, " ", sizeof(os_display) - strlen(os_display) - 1U);
            strncat(os_display, uts.release, sizeof(os_display) - strlen(os_display) - 1U);
        }
        if (uts.version[0] != '\0' && strcmp(uts.version, uts.release) != 0) {
            strncat(os_display, " (", sizeof(os_display) - strlen(os_display) - 1U);
            strncat(os_display, uts.version, sizeof(os_display) - strlen(os_display) - 1U);
            strncat(os_display, ")", sizeof(os_display) - strlen(os_display) - 1U);
        }
    } else {
        copy_string(os_display, sizeof(os_display), "IRIX");
    }

    if (!run_command_first_line("hinv -m 2>/dev/null", model, sizeof(model))) {
        copy_string(model, sizeof(model), uts.machine);
    }
    if (model[0] == '\0' && uts.machine[0] != '\0') {
        copy_string(model, sizeof(model), uts.machine);
    }
    if (model[0] == '\0') {
        copy_string(model, sizeof(model), "(n/a)");
    }

    if (!run_command_first_line("hinv -c processor 2>/dev/null", cpu, sizeof(cpu))) {
        run_command_first_line("hinv 2>/dev/null | awk '/processor/ {print $0; exit}'", cpu, sizeof(cpu));
    }
    if (cpu[0] == '\0') {
        copy_string(cpu, sizeof(cpu), "(n/a)");
    }

    if (!run_command_first_line("hinv -c gfx 2>/dev/null", graphics, sizeof(graphics))) {
        if (!run_command_first_line("gfxinfo -v 2>/dev/null", line, sizeof(line))) {
            graphics[0] = '\0';
        } else {
            copy_string(graphics, sizeof(graphics), line);
        }
    }
    if (graphics[0] == '\0') {
        copy_string(graphics, sizeof(graphics), "(n/a)");
    }

    if (!run_command_first_line("hinv 2>/dev/null | awk '/Main memory size:/ {print $4 \" \" $5; exit}'", memory, sizeof(memory))) {
        if (!run_command_first_line("sysinfo -m 2>/dev/null", memory, sizeof(memory))) {
            copy_string(memory, sizeof(memory), "(n/a)");
        }
    }

    if (!run_command_first_line("uptime 2>/dev/null", uptime, sizeof(uptime))) {
        copy_string(uptime, sizeof(uptime), "(n/a)");
    }

    env = getenv("SHELL");
    if (env != NULL && env[0] != '\0') {
        basename_copy(shell_name, sizeof(shell_name), env);
    } else {
        copy_string(shell_name, sizeof(shell_name), "sh");
    }

    env = getenv("TERM");
    if (env != NULL && env[0] != '\0') {
        copy_string(term_name, sizeof(term_name), env);
    } else {
        copy_string(term_name, sizeof(term_name), "unknown");
    }

    counter.count = 0;
    run_command_lines("versions 2>/dev/null", count_packages_callback, &counter);
    if (counter.count > 0) {
        snprintf(packages, sizeof(packages), "%ld packages", counter.count);
    } else {
        copy_string(packages, sizeof(packages), "(n/a)");
    }

    info_count = 0U;
    if (info_count < ARRAY_SIZE(info_lines)) {
        snprintf(info_lines[info_count], sizeof(info_lines[info_count]),
                 "%s%s%s@%s%s%s",
                 bold, username, reset, bold, hostname, reset);
        info_count++;
    }
    if (info_count < ARRAY_SIZE(info_lines)) {
        snprintf(info_lines[info_count], sizeof(info_lines[info_count]),
                 "%sOS%s: %s",
                 bold, reset, os_display);
        info_count++;
    }
    if (info_count < ARRAY_SIZE(info_lines)) {
        snprintf(info_lines[info_count], sizeof(info_lines[info_count]),
                 "%sModel%s: %s",
                 bold, reset, model);
        info_count++;
    }
    if (info_count < ARRAY_SIZE(info_lines)) {
        snprintf(info_lines[info_count], sizeof(info_lines[info_count]),
                 "%sCPU%s: %s",
                 bold, reset, cpu);
        info_count++;
    }
    if (info_count < ARRAY_SIZE(info_lines)) {
        snprintf(info_lines[info_count], sizeof(info_lines[info_count]),
                 "%sGraphics%s: %s",
                 bold, reset, graphics);
        info_count++;
    }
    if (info_count < ARRAY_SIZE(info_lines)) {
        snprintf(info_lines[info_count], sizeof(info_lines[info_count]),
                 "%sMemory%s: %s",
                 bold, reset, memory);
        info_count++;
    }
    if (info_count < ARRAY_SIZE(info_lines)) {
        snprintf(info_lines[info_count], sizeof(info_lines[info_count]),
                 "%sPackages%s: %s",
                 bold, reset, packages);
        info_count++;
    }
    if (info_count < ARRAY_SIZE(info_lines)) {
        snprintf(info_lines[info_count], sizeof(info_lines[info_count]),
                 "%sUptime%s: %s",
                 bold, reset, uptime);
        info_count++;
    }
    if (info_count < ARRAY_SIZE(info_lines)) {
        snprintf(info_lines[info_count], sizeof(info_lines[info_count]),
                 "%sShell%s: %s",
                 bold, reset, shell_name);
        info_count++;
    }
    if (info_count < ARRAY_SIZE(info_lines)) {
        snprintf(info_lines[info_count], sizeof(info_lines[info_count]),
                 "%sTerminal%s: %s",
                 bold, reset, term_name);
        info_count++;
    }

    for (i = 0U; i < ARRAY_SIZE(ascii_art) || i < info_count; i++) {
        const char *ascii_line = "";
        const char *art_color_start = "";
        const char *art_color_end = "";
        const char *info_line = "";

        if (i < ARRAY_SIZE(ascii_art)) {
            if (i < 4U) {
                art_color_start = color1;
                art_color_end = reset;
            } else if (i < 8U) {
                art_color_start = color2;
                art_color_end = reset;
            } else {
                art_color_start = color3;
                art_color_end = reset;
            }
            snprintf(line, sizeof(line), ascii_art[i], art_color_start, art_color_end);
            ascii_line = line;
        }

        if (i < info_count) {
            info_line = info_lines[i];
        }

        if (info_line[0] != '\0') {
            printf("%-36s  %s\n", ascii_line, info_line);
        } else if (ascii_line[0] != '\0') {
            printf("%s\n", ascii_line);
        }
    }

    return 0;
}
