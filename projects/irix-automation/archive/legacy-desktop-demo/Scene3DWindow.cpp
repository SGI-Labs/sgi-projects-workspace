#include "Scene3DWindow.h"

#include <Xm/Form.h>
#include <Xm/Label.h>
#include <Xm/PushB.h>
#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/GLwMDrawA.h>

#include <cstring>

namespace {
    volatile int g_glxErrorFlag = 0;

    int glxErrorHandler(Display *, XErrorEvent *)
    {
        g_glxErrorFlag = 1;
        return 0;
    }
}

Scene3DWindow::Scene3DWindow(const char *name)
    : VkSimpleWindow(name),
      _glWidget(0),
      _toggleButton(0),
      _statusLabel(0),
      _context(0),
      _visualInfo(0),
      _spinTimer(0),
      _width(1),
      _height(1),
      _angle(0.0f),
      _stepDegrees(2.0f),
      _initialized(False),
      _spinning(True)
{
    setTitle("IRIX 3D Viewer");
    setIconName("3D Viewer");
    XtVaSetValues(mainWindowWidget(),
                  XmNwidth, 640,
                  XmNheight, 520,
                  NULL);

    Widget form = XtVaCreateManagedWidget(
        "form", xmFormWidgetClass, mainWindowWidget(),
        XmNfractionBase, 100,
        XmNhorizontalSpacing, 6,
        XmNverticalSpacing, 6,
        NULL);

    XmString pauseLabel = XmStringCreateLocalized((char*)"Pause Rotation");
    _toggleButton = XtVaCreateManagedWidget(
        "toggle", xmPushButtonWidgetClass, form,
        XmNlabelString, pauseLabel,
        XmNbottomAttachment, XmATTACH_FORM,
        XmNleftAttachment, XmATTACH_FORM,
        XmNbottomOffset, 10,
        XmNleftOffset, 12,
        XmNwidth, 160,
        NULL);
    XmStringFree(pauseLabel);

    XmString statusText = XmStringCreateLocalized((char*)"Spinning cube - click Pause to stop");
    _statusLabel = XtVaCreateManagedWidget(
        "status", xmLabelWidgetClass, form,
        XmNalignment, XmALIGNMENT_END,
        XmNlabelString, statusText,
        XmNbottomAttachment, XmATTACH_FORM,
        XmNrightAttachment, XmATTACH_FORM,
        XmNbottomOffset, 14,
        XmNrightOffset, 12,
        XmNrecomputeSize, True,
        NULL);
    XmStringFree(statusText);

    static int visualAttribs[] = {
        GLX_RGBA,
        GLX_DOUBLEBUFFER,
        GLX_DEPTH_SIZE, 16,
        None
    };

    Display *display = XtDisplay(mainWindowWidget());
    if (display) {
        _visualInfo = glXChooseVisual(display, DefaultScreen(display), visualAttribs);
    }

    _glWidget = XtVaCreateManagedWidget(
        "glArea", glwMDrawingAreaWidgetClass, form,
        XmNtopAttachment, XmATTACH_FORM,
        XmNleftAttachment, XmATTACH_FORM,
        XmNrightAttachment, XmATTACH_FORM,
        XmNbottomAttachment, XmATTACH_WIDGET,
        XmNbottomWidget, _toggleButton,
        XmNtopOffset, 10,
        XmNleftOffset, 10,
        XmNrightOffset, 10,
        XmNbottomOffset, 10,
        GLwNattribList, visualAttribs,
        GLwNvisualInfo, _visualInfo,
        NULL);

    XtAddCallback(_toggleButton, XmNactivateCallback, &Scene3DWindow::toggleCB, (XtPointer)this);

    XtAddCallback(_glWidget, GLwNginitCallback, &Scene3DWindow::ginitCB, (XtPointer)this);
    XtAddCallback(_glWidget, GLwNexposeCallback, &Scene3DWindow::exposeCB, (XtPointer)this);
    XtAddCallback(_glWidget, GLwNresizeCallback, &Scene3DWindow::resizeCB, (XtPointer)this);

    if (!_visualInfo) {
        showError("GLX visual unavailable; 3D disabled");
    }
}

Scene3DWindow::~Scene3DWindow()
{
    stopSpin();

    if (_context && _glWidget) {
        Display *display = XtDisplay(_glWidget);
        if (display) {
            glXMakeCurrent(display, None, 0);
            glXDestroyContext(display, _context);
        }
        _context = 0;
    }

    if (_visualInfo) {
        XFree(_visualInfo);
        _visualInfo = 0;
    }
}

const char* Scene3DWindow::className()
{
    return "Scene3DWindow";
}

void Scene3DWindow::show()
{
    VkSimpleWindow::show();

    if (_spinning && !_spinTimer) {
        scheduleSpin();
    }
}

void Scene3DWindow::hide()
{
    stopSpin();
    VkSimpleWindow::hide();
}

void Scene3DWindow::initializeGL()
{
    if (!_glWidget || !_context) {
        return;
    }

    GLwDrawingAreaMakeCurrent(_glWidget, _context);

    glEnable(GL_DEPTH_TEST);
    glShadeModel(GL_SMOOTH);
    glClearColor(0.05f, 0.07f, 0.12f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    _initialized = True;
}

void Scene3DWindow::renderScene()
{
    if (!_glWidget || !_context || !_initialized) {
        return;
    }

    Display *display = XtDisplay(_glWidget);
    Window window = XtWindow(_glWidget);
    if (!display || !window) {
        return;
    }

    GLwDrawingAreaMakeCurrent(_glWidget, _context);

    int w = (_width > 0) ? _width : 1;
    int h = (_height > 0) ? _height : 1;

    glViewport(0, 0, w, h);

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    double aspect = (h != 0) ? (double)w / (double)h : 1.0;
    gluPerspective(45.0, aspect, 1.0, 40.0);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glTranslatef(0.0f, 0.0f, -6.0f);
    glRotatef(_angle, 1.0f, 1.0f, 0.0f);

    glBegin(GL_QUADS);

    glColor3f(0.9f, 0.3f, 0.3f);
    glVertex3f(-1.0f, -1.0f,  1.0f);
    glVertex3f( 1.0f, -1.0f,  1.0f);
    glVertex3f( 1.0f,  1.0f,  1.0f);
    glVertex3f(-1.0f,  1.0f,  1.0f);

    glColor3f(0.3f, 0.9f, 0.3f);
    glVertex3f(-1.0f, -1.0f, -1.0f);
    glVertex3f(-1.0f,  1.0f, -1.0f);
    glVertex3f( 1.0f,  1.0f, -1.0f);
    glVertex3f( 1.0f, -1.0f, -1.0f);

    glColor3f(0.3f, 0.3f, 0.9f);
    glVertex3f(-1.0f,  1.0f, -1.0f);
    glVertex3f(-1.0f,  1.0f,  1.0f);
    glVertex3f( 1.0f,  1.0f,  1.0f);
    glVertex3f( 1.0f,  1.0f, -1.0f);

    glColor3f(0.9f, 0.9f, 0.3f);
    glVertex3f(-1.0f, -1.0f, -1.0f);
    glVertex3f( 1.0f, -1.0f, -1.0f);
    glVertex3f( 1.0f, -1.0f,  1.0f);
    glVertex3f(-1.0f, -1.0f,  1.0f);

    glColor3f(0.3f, 0.9f, 0.9f);
    glVertex3f( 1.0f, -1.0f, -1.0f);
    glVertex3f( 1.0f,  1.0f, -1.0f);
    glVertex3f( 1.0f,  1.0f,  1.0f);
    glVertex3f( 1.0f, -1.0f,  1.0f);

    glColor3f(0.9f, 0.3f, 0.9f);
    glVertex3f(-1.0f, -1.0f, -1.0f);
    glVertex3f(-1.0f, -1.0f,  1.0f);
    glVertex3f(-1.0f,  1.0f,  1.0f);
    glVertex3f(-1.0f,  1.0f, -1.0f);

    glEnd();

    glXSwapBuffers(display, window);
}

void Scene3DWindow::scheduleSpin()
{
    if (!_spinning) {
        return;
    }

    XtAppContext context = XtWidgetToApplicationContext(baseWidget());
    if (!context) {
        return;
    }

    if (_spinTimer) {
        XtRemoveTimeOut(_spinTimer);
    }

    _spinTimer = XtAppAddTimeOut(context, 33, &Scene3DWindow::timerCB, (XtPointer)this);
}

void Scene3DWindow::stopSpin()
{
    if (_spinTimer) {
        XtRemoveTimeOut(_spinTimer);
        _spinTimer = 0;
    }
}

void Scene3DWindow::updateStatusLabel()
{
    if (!_toggleButton || !_statusLabel) {
        return;
    }

    const char *buttonLabel = _spinning ? "Pause Rotation" : "Resume Rotation";
    const char *status = _spinning
        ? "Spinning cube - click Pause to stop"
        : "Rotation paused - click Resume to start";

    XmString btn = XmStringCreateLocalized((char*)buttonLabel);
    XmString statusText = XmStringCreateLocalized((char*)status);

    XtVaSetValues(_toggleButton, XmNlabelString, btn, NULL);
    XtVaSetValues(_statusLabel, XmNlabelString, statusText, NULL);

    XmStringFree(btn);
    XmStringFree(statusText);
}

void Scene3DWindow::showError(const char *message)
{
    _spinning = False;
    stopSpin();

    if (_toggleButton) {
        XtSetSensitive(_toggleButton, False);
    }

    if (_statusLabel && message) {
        XmString text = XmStringCreateLocalized((char*)message);
        XtVaSetValues(_statusLabel, XmNlabelString, text, NULL);
        XmStringFree(text);
    }
}

void Scene3DWindow::toggleSpin()
{
    if (_spinning) {
        _spinning = False;
        stopSpin();
    } else {
        _spinning = True;
        scheduleSpin();
    }

    updateStatusLabel();
}

void Scene3DWindow::ginitCB(Widget widget, XtPointer clientData, XtPointer callData)
{
    Scene3DWindow *self = static_cast<Scene3DWindow*>(clientData);
    if (!self || !widget) {
        return;
    }

    GLwDrawingAreaCallbackStruct *cb = static_cast<GLwDrawingAreaCallbackStruct*>(callData);
    if (cb) {
        self->_width = cb->width;
        self->_height = cb->height;
    }

    Display *display = XtDisplay(widget);
    XVisualInfo *vis = self->_visualInfo;
    if (!vis) {
        XtVaGetValues(widget, GLwNvisualInfo, &vis, NULL);
    }

    if (!display || !vis) {
        self->showError("GLX visual unavailable; 3D disabled");
        return;
    }

    if (!self->_context) {
        g_glxErrorFlag = 0;
        int (*oldHandler)(Display*, XErrorEvent*) = XSetErrorHandler(glxErrorHandler);
        self->_context = glXCreateContext(display, vis, 0, False);
        XSync(display, False);
        XSetErrorHandler(oldHandler);

        if (!self->_context || g_glxErrorFlag) {
            self->_context = 0;
            self->showError("GLX context creation failed; 3D disabled");
            return;
        }
    }

    GLwDrawingAreaMakeCurrent(widget, self->_context);
    self->initializeGL();
    self->renderScene();
}

void Scene3DWindow::exposeCB(Widget widget, XtPointer clientData, XtPointer)
{
    Scene3DWindow *self = static_cast<Scene3DWindow*>(clientData);
    if (!self || widget != self->_glWidget) {
        return;
    }

    self->renderScene();
}

void Scene3DWindow::resizeCB(Widget widget, XtPointer clientData, XtPointer callData)
{
    Scene3DWindow *self = static_cast<Scene3DWindow*>(clientData);
    if (!self || widget != self->_glWidget) {
        return;
    }

    GLwDrawingAreaCallbackStruct *cb = static_cast<GLwDrawingAreaCallbackStruct*>(callData);
    if (!cb) {
        return;
    }

    self->_width = cb->width;
    self->_height = cb->height;

    if (self->_initialized) {
        self->renderScene();
    }
}

void Scene3DWindow::toggleCB(Widget, XtPointer clientData, XtPointer)
{
    Scene3DWindow *self = static_cast<Scene3DWindow*>(clientData);
    if (!self) {
        return;
    }

    self->toggleSpin();
}

void Scene3DWindow::timerCB(XtPointer clientData, XtIntervalId *)
{
    Scene3DWindow *self = static_cast<Scene3DWindow*>(clientData);
    if (!self) {
        return;
    }

    self->_spinTimer = 0;

    if (self->_spinning) {
        self->_angle += self->_stepDegrees;
        if (self->_angle >= 360.0f) {
            self->_angle -= 360.0f;
        }

        self->renderScene();
        self->scheduleSpin();
    }
}
