#ifndef IRIX_IDE_UI_SHELL_H
#define IRIX_IDE_UI_SHELL_H

#include <Xm/Xm.h>

#define WORKSPACE_SECTION_COUNT 6

typedef struct {
    Pixel bg_base;
    Pixel bg_surface;
    Pixel bg_panel;
    Pixel text_primary;
    Pixel text_secondary;
    Pixel status_success;
    Pixel status_warning;
    Pixel status_danger;
    Pixel status_offline;
    Pixel accent;
} Palette;

typedef struct {
    const Palette *palette;
    Widget buttons[WORKSPACE_SECTION_COUNT];
    Widget contentText;
    Widget banner;
    int selectedIndex;
} NavigationContext;

void ui_build_shell(Widget toplevel, const Palette *palette);
Palette ui_load_palette(Display *display, Colormap colormap);


#endif /* IRIX_IDE_UI_SHELL_H */
