#include "ui_shell.h"

#include <Xm/Xm.h>
#include <Xm/MainW.h>
#include <X11/Shell.h>

int main(int argc, char **argv) {
    XtAppContext app;
    Widget toplevel = XtVaAppInitialize(&app, "IRIXIDE", NULL, 0, &argc, argv, NULL, NULL);

    Display *display = XtDisplay(toplevel);
    Colormap colormap = DefaultColormapOfScreen(XtScreen(toplevel));
    Palette palette = ui_load_palette(display, colormap);

    XtVaSetValues(toplevel,
                  XmNtitle, "IRIX IDE",
                  XmNiconName, "IRIX IDE",
                  XmNbackground, palette.bg_base,
                  NULL);

    ui_build_shell(toplevel, &palette);

    XtRealizeWidget(toplevel);
    XtAppMainLoop(app);
    return 0;
}
