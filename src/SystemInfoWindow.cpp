#include "SystemInfoWindow.h"

#include <Xm/Form.h>
#include <Xm/Label.h>
#include <Xm/PushB.h>

#include <sys/utsname.h>
#ifdef __sgi
#include <sys/sysmp.h>
#endif
#include <unistd.h>
#include <time.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

SystemInfoWindow::SystemInfoWindow(const char *name)
    : VkSimpleWindow(name),
      _infoLabel(0),
      _refreshButton(0),
      _timerId(0),
      _pageSize(-1)
{
    setTitle("IRIX System Monitor");
    setIconName("IRIX Monitor");
    XtVaSetValues(mainWindowWidget(),
                  XmNwidth, 420,
                  XmNheight, 240,
                  NULL);

    Widget form = XtVaCreateManagedWidget(
        "form", xmFormWidgetClass, mainWindowWidget(),
        XmNfractionBase, 100,
        XmNhorizontalSpacing, 6,
        XmNverticalSpacing, 6,
        NULL);

    _infoLabel = XtVaCreateManagedWidget(
        "systemInfo", xmLabelWidgetClass, form,
        XmNalignment, XmALIGNMENT_BEGINNING,
        XmNtopAttachment, XmATTACH_FORM,
        XmNleftAttachment, XmATTACH_FORM,
        XmNrightAttachment, XmATTACH_FORM,
        XmNtopOffset, 12,
        XmNleftOffset, 12,
        XmNrightOffset, 12,
        XmNrecomputeSize, False,
        XmNwidth, 360,
        NULL);

    XmString refreshLabel = XmStringCreateLocalized((char*)"Refresh");

    _refreshButton = XtVaCreateManagedWidget(
        "refresh", xmPushButtonWidgetClass, form,
        XmNlabelString, refreshLabel,
        XmNtopAttachment, XmATTACH_WIDGET,
        XmNtopWidget, _infoLabel,
        XmNtopOffset, 18,
        XmNleftAttachment, XmATTACH_FORM,
        XmNleftOffset, 12,
        XmNbottomAttachment, XmATTACH_FORM,
        XmNbottomOffset, 12,
        XmNwidth, 120,
        NULL);

    XmStringFree(refreshLabel);

    XtAddCallback(_refreshButton, XmNactivateCallback, &SystemInfoWindow::refreshCB, (XtPointer)this);

    _pageSize = safeSysconf(_SC_PAGESIZE);
    if (_pageSize <= 0) {
        _pageSize = 4096;
    }

    updateInfo();
}

SystemInfoWindow::~SystemInfoWindow()
{
    if (_timerId) {
        XtRemoveTimeOut(_timerId);
        _timerId = 0;
    }
}

const char* SystemInfoWindow::className()
{
    return "SystemInfoWindow";
}

void SystemInfoWindow::show()
{
    VkSimpleWindow::show();

    if (!_timerId) {
        scheduleRefresh();
    }
}

void SystemInfoWindow::hide()
{
    if (_timerId) {
        XtRemoveTimeOut(_timerId);
        _timerId = 0;
    }

    VkSimpleWindow::hide();
}

void SystemInfoWindow::updateInfo()
{
    struct utsname uts;
    if (uname(&uts) != 0) {
        memset(&uts, 0, sizeof(uts));
    }

    char hostname[256];
    if (gethostname(hostname, sizeof(hostname)) != 0 || hostname[0] == '\0') {
        strncpy(hostname, uts.nodename, sizeof(hostname) - 1);
        hostname[sizeof(hostname) - 1] = '\0';
    }

    long cpuCount = safeSysconf(_SC_NPROC_ONLN);
#ifdef MP_NPROCS
    if (cpuCount <= 0) {
        cpuCount = safeSysmp(MP_NPROCS);
    }
#endif

    long physPages = -1;
#ifdef _SC_PHYS_PAGES
    physPages = safeSysconf(_SC_PHYS_PAGES);
#endif

    long availPages = -1;
#ifdef _SC_AVPHYS_PAGES
    availPages = safeSysconf(_SC_AVPHYS_PAGES);
#endif

    char cpuText[32];
    if (cpuCount > 0) {
        snprintf(cpuText, sizeof(cpuText), "%ld", cpuCount);
    } else {
        strncpy(cpuText, "unknown", sizeof(cpuText));
        cpuText[sizeof(cpuText) - 1] = '\0';
    }

    char memTotal[64];
    char memAvail[64];
    formatMemoryString(physPages, _pageSize, memTotal, sizeof(memTotal));
    formatMemoryString(availPages, _pageSize, memAvail, sizeof(memAvail));

    time_t now = time(0);
    char timeStamp[64];
    struct tm *local = localtime(&now);
    if (local) {
        strftime(timeStamp, sizeof(timeStamp), "%c", local);
    } else {
        strncpy(timeStamp, "unknown", sizeof(timeStamp));
        timeStamp[sizeof(timeStamp) - 1] = '\0';
    }

    char buffer[512];
    snprintf(buffer, sizeof(buffer),
             "Last update: %s\n"
             "Host: %s\n"
             "System: %s %s\n"
             "Hardware: %s\n"
             "CPUs online: %s\n"
             "Physical memory: %s\n"
             "Available memory: %s",
             timeStamp,
             hostname[0] ? hostname : "unknown",
             uts.sysname[0] ? uts.sysname : "unknown",
             uts.release[0] ? uts.release : "unknown",
             uts.machine[0] ? uts.machine : "unknown",
             cpuText,
             memTotal,
             memAvail);

    XmString text = XmStringCreateLtoR(buffer, XmFONTLIST_DEFAULT_TAG);
    XtVaSetValues(_infoLabel, XmNlabelString, text, NULL);
    XmStringFree(text);
}

void SystemInfoWindow::scheduleRefresh()
{
    XtAppContext context = XtWidgetToApplicationContext(baseWidget());
    if (!context) {
        return;
    }

    _timerId = XtAppAddTimeOut(context, 5000, &SystemInfoWindow::timerCB, (XtPointer)this);
}

long SystemInfoWindow::safeSysconf(int name) const
{
    errno = 0;
    long value = sysconf(name);
    if (value == -1 && errno != 0) {
        return -1;
    }
    return value;
}

long SystemInfoWindow::safeSysmp(int command) const
{
#ifdef __sgi
    errno = 0;
    long value = sysmp(command, 0);
    if (value < 0 && errno != 0) {
        return -1;
    }
    return value;
#else
    (void)command;
    return -1;
#endif
}

void SystemInfoWindow::formatMemoryString(long pages, long pageSize, char *buffer, size_t bufferSize) const
{
    if (bufferSize == 0) {
        return;
    }

    if (pages > 0 && pageSize > 0) {
        double totalMB = (double)pages * (double)pageSize / (1024.0 * 1024.0);
        if (totalMB >= 1024.0) {
            double totalGB = totalMB / 1024.0;
            snprintf(buffer, bufferSize, "%.2f GB", totalGB);
        } else {
            snprintf(buffer, bufferSize, "%.1f MB", totalMB);
        }
    } else {
        strncpy(buffer, "unknown", bufferSize);
        buffer[bufferSize - 1] = '\0';
    }
}

void SystemInfoWindow::refreshCB(Widget, XtPointer clientData, XtPointer)
{
    SystemInfoWindow *self = (SystemInfoWindow*)clientData;
    if (self) {
        self->updateInfo();
    }
}

void SystemInfoWindow::timerCB(XtPointer clientData, XtIntervalId *)
{
    SystemInfoWindow *self = (SystemInfoWindow*)clientData;
    if (!self) {
        return;
    }

    self->_timerId = 0;
    self->updateInfo();
    self->scheduleRefresh();
}
