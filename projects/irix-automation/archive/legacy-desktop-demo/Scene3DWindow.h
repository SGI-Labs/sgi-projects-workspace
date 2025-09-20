#ifndef SCENE3DWINDOW_H
#define SCENE3DWINDOW_H

#include <Vk/VkSimpleWindow.h>
#include <Xm/Xm.h>
#include <GL/glx.h>
#include <X11/Xlib.h>

class Scene3DWindow : public VkSimpleWindow {
public:
    explicit Scene3DWindow(const char *name);
    virtual ~Scene3DWindow();

    virtual const char* className();
    virtual void show();
    virtual void hide();

private:
    Widget       _glWidget;
    Widget       _toggleButton;
    Widget       _statusLabel;
    GLXContext   _context;
    XVisualInfo *_visualInfo;
    XtIntervalId _spinTimer;
    int          _width;
    int          _height;
    float        _angle;
    float        _stepDegrees;
    Boolean      _initialized;
    Boolean      _spinning;

    void initializeGL();
    void renderScene();
    void scheduleSpin();
    void stopSpin();
    void updateStatusLabel();
    void toggleSpin();
    void showError(const char *message);

    static void ginitCB(Widget widget, XtPointer clientData, XtPointer callData);
    static void exposeCB(Widget widget, XtPointer clientData, XtPointer callData);
    static void resizeCB(Widget widget, XtPointer clientData, XtPointer callData);
    static void toggleCB(Widget widget, XtPointer clientData, XtPointer callData);
    static void timerCB(XtPointer clientData, XtIntervalId *id);
};

#endif
