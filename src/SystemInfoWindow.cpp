#include "SystemInfoWindow.h"

#include <Xm/Form.h>
#include <Xm/Label.h>
#include <Xm/PushB.h>

#include <sys/utsname.h>
#include <unistd.h>
#include <time.h>
#include <stdio.h>
#include <string.h>

SystemInfoWindow::SystemInfoWindow(const char *name)
    : VkSimpleWindow(name),
      _infoLabel(0),
      _refreshButton(0),
      _timerId(0)
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

    long cpuCount = sysconf(_SC_NPROC_ONLN);
    long physPages = -1;
    long availPages = -1;

#ifdef _SC_PHYS_PAGES
    physPages = sysconf(_SC_PHYS_PAGES);
#endif
#ifdef _SC_AVPHYS_PAGES
    availPages = sysconf(_SC_AVPHYS_PAGES);
#endif
    long pageSize = sysconf(_SC_PAGESIZE);

    char cpuText[32];
    if (cpuCount > 0) {
        sprintf(cpuText, "%ld", cpuCount);
    } else {
        strcpy(cpuText, "unknown");
    }

    char memTotal[64];
    char memAvail[64];
    if (physPages > 0 && pageSize > 0) {
        double total = (double)physPages * (double)pageSize / (1024.0 * 1024.0);
        sprintf(memTotal, "%.1f MB", total);
    } else {
        strcpy(memTotal, "unknown");
    }

    if (availPages > 0 && pageSize > 0) {
        double avail = (double)availPages * (double)pageSize / (1024.0 * 1024.0);
        sprintf(memAvail, "%.1f MB", avail);
    } else {
        strcpy(memAvail, "unknown");
    }

    time_t now = time(0);
    char timeStamp[64];
    struct tm *local = localtime(&now);
    if (local) {
        strftime(timeStamp, sizeof(timeStamp), "%c", local);
    } else {
        strcpy(timeStamp, "unknown");
    }

    char buffer[512];
    sprintf(buffer,
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
