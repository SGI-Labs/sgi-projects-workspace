#ifndef SYSTEMINFOWINDOW_H
#define SYSTEMINFOWINDOW_H

#include <Vk/VkSimpleWindow.h>
#include <Xm/Xm.h>
#include <stddef.h>

class SystemInfoWindow : public VkSimpleWindow {
public:
    explicit SystemInfoWindow(const char *name);
    virtual ~SystemInfoWindow();

    virtual const char* className();
    virtual void show();
    virtual void hide();

private:
    Widget       _infoLabel;
    Widget       _refreshButton;
    XtIntervalId _timerId;
    long         _pageSize;

    void updateInfo();
    void scheduleRefresh();

    static void refreshCB(Widget widget, XtPointer clientData, XtPointer callData);
    static void timerCB(XtPointer clientData, XtIntervalId *id);

    long safeSysconf(int name) const;
    long safeSysmp(int command) const;
    void formatMemoryString(long pages, long pageSize, char *buffer, size_t bufferSize) const;
};

#endif
