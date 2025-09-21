#include "ui_shell.h"

#include <Xm/Frame.h>
#include <Xm/Form.h>
#include <Xm/Label.h>
#include <Xm/List.h>
#include <Xm/MainW.h>
#include <Xm/PushB.h>
#include <Xm/RowColumn.h>
#include <Xm/ScrolledW.h>
#include <Xm/Text.h>

#include <X11/Xlib.h>

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    NavigationContext *context;
    int index;
} NavCallbackData;

static const char *SECTION_BUTTON_LABELS[WORKSPACE_SECTION_COUNT] = {
    "Project Dashboard",
    "Editor",
    "Remote Hosts",
    "Build & Logs",
    "Debugger",
    "Settings"
};

static const char *SECTION_CONTENT_STRINGS[WORKSPACE_SECTION_COUNT] = {
    "Dashboard\n\nReview sync health, build summaries, and recent activity for all IRIX hosts.",
    "Editor\n\nRemote editing surface integrates with sync service (upcoming story).",
    "Remote Hosts\n\nManage IRIX host connections, retry failed sessions, and inspect host metadata.",
    "Build & Logs\n\nQueue builds, stream live logs, and inspect diagnostics once pipeline hooks are wired.",
    "Debugger\n\nRemote debugger session layout placeholder.",
    "Settings\n\nConfigure workspace preferences, key bindings, and appearance when implemented."
};

static const char *SECTION_BANNER_STRINGS[WORKSPACE_SECTION_COUNT] = {
    "Dashboard overview",
    "Editor coming soon",
    "Remote host management",
    "Build queue overview",
    "Debugger placeholder",
    "Settings overview"
};

static void nav_button_activated(Widget widget, XtPointer clientData, XtPointer callData);
static void nav_select_section(NavigationContext *ctx, int index);

static Pixel allocate_color(Display *display, Colormap colormap, const char *hex, Pixel fallback) {
    XColor color;
    if (!XParseColor(display, colormap, hex, &color)) {
        fprintf(stderr, "[irix-ide] unable to parse color %s\n", hex);
        return fallback;
    }
    if (!XAllocColor(display, colormap, &color)) {
        fprintf(stderr, "[irix-ide] unable to allocate color %s\n", hex);
        return fallback;
    }
    return color.pixel;
}

Palette ui_load_palette(Display *display, Colormap colormap) {
    Palette palette;
    Pixel fallback = BlackPixel(display, DefaultScreen(display));

    palette.bg_base = allocate_color(display, colormap, "#4F5B66", fallback);
    palette.bg_surface = allocate_color(display, colormap, "#1E1E1E", palette.bg_base);
    palette.bg_panel = allocate_color(display, colormap, "#2C2C2E", palette.bg_base);
    palette.text_primary = allocate_color(display, colormap, "#F2F2F7", WhitePixel(display, DefaultScreen(display)));
    palette.text_secondary = allocate_color(display, colormap, "#8E8E93", palette.text_primary);
    palette.status_success = allocate_color(display, colormap, "#34C759", palette.text_primary);
    palette.status_warning = allocate_color(display, colormap, "#FFD60A", palette.text_primary);
    palette.status_danger = allocate_color(display, colormap, "#FF3B30", palette.text_primary);
    palette.status_offline = allocate_color(display, colormap, "#FF9500", palette.text_primary);
    palette.accent = allocate_color(display, colormap, "#6699CC", palette.text_primary);

    return palette;
}

static void set_widget_colors(Widget widget, const Palette *palette, Pixel background, Pixel foreground) {
    XtVaSetValues(widget,
                  XmNbackground, background,
                  XmNforeground, foreground,
                  NULL);
}

static Widget create_navigation_panel(Widget parent, const Palette *palette, NavigationContext *navCtx) {
    Widget frame;
    Widget column;
    Arg args[6];
    int n;
    XmString title;
    Widget titleLabel;
    int i;
    XmString label;
    Widget button;
    XmString hostTitle;
    Widget hostHeader;
    const char *hostDetail = "octane-01 (Connected)";
    XmString hostInfo;
    Widget hostLabel;
    XmString queueTitle;
    Widget queueHeader;
    XmString queueItems[3];
    Widget queueList;

    navCtx->palette = palette;
    navCtx->selectedIndex = -1;

    frame = XmCreateFrame(parent, "navFrame", NULL, 0);
    XtVaSetValues(frame,
                  XmNshadowType, XmSHADOW_IN,
                  XmNbackground, palette->bg_panel,
                  NULL);

    n = 0;
    XtSetArg(args[n], XmNorientation, XmVERTICAL); n++;
    XtSetArg(args[n], XmNspacing, 8); n++;
    XtSetArg(args[n], XmNpacking, XmPACK_TIGHT); n++;
    XtSetArg(args[n], XmNmarginWidth, 12); n++;
    XtSetArg(args[n], XmNmarginHeight, 12); n++;
    XtSetArg(args[n], XmNbackground, palette->bg_panel); n++;
    column = XmCreateRowColumn(frame, "navColumn", args, n);
    XtManageChild(column);

    title = XmStringCreateLocalized("Workspace Shell");
    titleLabel = XmCreateLabel(column, "navTitle", NULL, 0);
    set_widget_colors(titleLabel, palette, palette->bg_panel, palette->text_primary);
    XtVaSetValues(titleLabel, XmNlabelString, title, NULL);
    XmStringFree(title);
    XtManageChild(titleLabel);

    for (i = 0; i < WORKSPACE_SECTION_COUNT; ++i) {
        NavCallbackData *info;

        label = XmStringCreateLocalized((char *)SECTION_BUTTON_LABELS[i]);
        button = XmCreatePushButton(column, (char *)SECTION_BUTTON_LABELS[i], NULL, 0);
        set_widget_colors(button, palette, palette->bg_panel, palette->text_secondary);
        XtVaSetValues(button,
                      XmNlabelString, label,
                      XmNhighlightThickness, 0,
                      XmNarmColor, palette->accent,
                      NULL);
        XmStringFree(label);
        XtManageChild(button);
        navCtx->buttons[i] = button;

        info = (NavCallbackData *)malloc(sizeof(NavCallbackData));
        if (info != NULL) {
            info->context = navCtx;
            info->index = i;
            XtAddCallback(button, XmNactivateCallback, nav_button_activated, (XtPointer)info);
        }
    }

    hostTitle = XmStringCreateLocalized("Remote Host");
    hostHeader = XmCreateLabel(column, "hostHeader", NULL, 0);
    set_widget_colors(hostHeader, palette, palette->bg_panel, palette->text_primary);
    XtVaSetValues(hostHeader, XmNlabelString, hostTitle, NULL);
    XmStringFree(hostTitle);
    XtManageChild(hostHeader);

    hostInfo = XmStringCreateLocalized((char *)hostDetail);
    hostLabel = XmCreateLabel(column, "hostLabel", NULL, 0);
    set_widget_colors(hostLabel, palette, palette->bg_panel, palette->text_secondary);
    XtVaSetValues(hostLabel, XmNlabelString, hostInfo, NULL);
    XmStringFree(hostInfo);
    XtManageChild(hostLabel);

    queueTitle = XmStringCreateLocalized("Offline Queue");
    queueHeader = XmCreateLabel(column, "queueHeader", NULL, 0);
    set_widget_colors(queueHeader, palette, palette->bg_panel, palette->text_primary);
    XtVaSetValues(queueHeader, XmNlabelString, queueTitle, NULL);
    XmStringFree(queueTitle);
    XtManageChild(queueHeader);

    queueItems[0] = XmStringCreateLocalized("deploy.sh - pending sync");
    queueItems[1] = XmStringCreateLocalized("README.md - awaiting review");
    queueItems[2] = XmStringCreateLocalized("scripts/restart.sh - retry queued");

    queueList = XmCreateScrolledList(column, "queueList", NULL, 0);
    set_widget_colors(queueList, palette, palette->bg_surface, palette->text_secondary);
    XtManageChild(queueList);
    XtVaSetValues(queueList,
                  XmNselectionPolicy, XmSINGLE_SELECT,
                  XmNvisibleItemCount, 4,
                  XmNlistMarginWidth, 4,
                  XmNlistSpacing, 2,
                  NULL);
    XmListAddItems(queueList, queueItems, 3, 0);
    for (i = 0; i < 3; ++i) {
        XmStringFree(queueItems[i]);
    }

    XtManageChild(frame);
    return frame;
}

static Widget create_banner(Widget parent, const Palette *palette, const char *message, Pixel fill) {
    Widget banner;
    XmString text;

    banner = XmCreateLabel(parent, "statusBanner", NULL, 0);
    XtVaSetValues(banner,
                  XmNbackground, fill,
                  XmNforeground, palette->bg_base,
                  XmNalignment, XmALIGNMENT_BEGINNING,
                  XmNmarginWidth, 8,
                  XmNmarginHeight, 6,
                  NULL);
    text = XmStringCreateLocalized((char *)message);
    XtVaSetValues(banner, XmNlabelString, text, NULL);
    XmStringFree(text);
    XtManageChild(banner);
    return banner;
}

static Widget create_content_panel(Widget parent, const Palette *palette, NavigationContext *navCtx) {
    Widget form;
    Widget banner;
    Widget editorFrame;
    Widget scrolled;
    Widget activityFrame;
    Arg args[6];
    int n;
    Widget activityColumn;
    XmString sectionTitle;
    Widget sectionLabel;
    XmString logLines[3];
    Widget logList;
    int i;

    form = XmCreateForm(parent, "contentForm", NULL, 0);
    XtVaSetValues(form,
                  XmNbackground, palette->bg_surface,
                  XmNmarginWidth, 16,
                  XmNmarginHeight, 16,
                  NULL);

    banner = create_banner(form, palette, SECTION_BANNER_STRINGS[0], palette->status_success);
    XtVaSetValues(banner,
                  XmNtopAttachment, XmATTACH_FORM,
                  XmNleftAttachment, XmATTACH_FORM,
                  XmNrightAttachment, XmATTACH_FORM,
                  NULL);

    editorFrame = XmCreateFrame(form, "editorFrame", NULL, 0);
    XtVaSetValues(editorFrame,
                  XmNbackground, palette->bg_panel,
                  XmNshadowType, XmSHADOW_IN,
                  XmNtopAttachment, XmATTACH_WIDGET,
                  XmNtopWidget, banner,
                  XmNtopOffset, 12,
                  XmNleftAttachment, XmATTACH_FORM,
                  XmNrightAttachment, XmATTACH_FORM,
                  XmNbottomAttachment, XmATTACH_POSITION,
                  XmNbottomPosition, 60,
                  NULL);

    scrolled = XmCreateScrolledText(editorFrame, "editorView", NULL, 0);
    XtVaSetValues(scrolled,
                  XmNbackground, palette->bg_surface,
                  XmNforeground, palette->text_primary,
                  XmNeditable, False,
                  XmNcursorPositionVisible, False,
                  XmNwordWrap, True,
                  NULL);
    XmTextSetString(scrolled, (char *)SECTION_CONTENT_STRINGS[0]);
    XtManageChild(scrolled);
    navCtx->contentText = scrolled;
    navCtx->banner = banner;

    activityFrame = XmCreateFrame(form, "activityFrame", NULL, 0);
    XtVaSetValues(activityFrame,
                  XmNbackground, palette->bg_panel,
                  XmNshadowType, XmSHADOW_IN,
                  XmNtopAttachment, XmATTACH_WIDGET,
                  XmNtopWidget, editorFrame,
                  XmNtopOffset, 12,
                  XmNleftAttachment, XmATTACH_FORM,
                  XmNrightAttachment, XmATTACH_FORM,
                  XmNbottomAttachment, XmATTACH_FORM,
                  NULL);

    n = 0;
    XtSetArg(args[n], XmNorientation, XmVERTICAL); n++;
    XtSetArg(args[n], XmNspacing, 6); n++;
    XtSetArg(args[n], XmNmarginWidth, 12); n++;
    XtSetArg(args[n], XmNmarginHeight, 12); n++;
    XtSetArg(args[n], XmNbackground, palette->bg_panel); n++;
    activityColumn = XmCreateRowColumn(activityFrame, "activityColumn", args, n);
    XtManageChild(activityColumn);

    sectionTitle = XmStringCreateLocalized("Build & Log Activity");
    sectionLabel = XmCreateLabel(activityColumn, "activityTitle", NULL, 0);
    set_widget_colors(sectionLabel, palette, palette->bg_panel, palette->text_primary);
    XtVaSetValues(sectionLabel, XmNlabelString, sectionTitle, NULL);
    XmStringFree(sectionTitle);
    XtManageChild(sectionLabel);

    logLines[0] = XmStringCreateLocalized("[OK] Build 1842 - 00:22 - Success");
    logLines[1] = XmStringCreateLocalized("[WARN] Build 1841 - 00:19 - Warnings (3)");
    logLines[2] = XmStringCreateLocalized("[FAIL] Build 1840 - 00:18 - Failure (link)");

    logList = XmCreateScrolledList(activityColumn, "logList", NULL, 0);
    set_widget_colors(logList, palette, palette->bg_surface, palette->text_secondary);
    XtManageChild(logList);
    XmListAddItems(logList, logLines, 3, 0);
    for (i = 0; i < 3; ++i) {
        XmStringFree(logLines[i]);
    }

    XtManageChild(form);
    return form;
}

static Widget create_status_bar(Widget parent, const Palette *palette) {
    Arg args[6];
    int n = 0;
    Widget bar;
    const char *labels[3] = {
        "Connected - octane-01",
        "Sync: 3 files pending",
        "Build Queue: 1 failing"
    };
    Pixel colors[3];
    XmString text;
    Widget tag;
    int i;

    colors[0] = palette->status_success;
    colors[1] = palette->status_warning;
    colors[2] = palette->status_danger;

    XtSetArg(args[n], XmNorientation, XmHORIZONTAL); n++;
    XtSetArg(args[n], XmNspacing, 16); n++;
    XtSetArg(args[n], XmNmarginWidth, 12); n++;
    XtSetArg(args[n], XmNmarginHeight, 8); n++;
    XtSetArg(args[n], XmNbackground, palette->bg_panel); n++;
    bar = XmCreateRowColumn(parent, "statusBar", args, n);

    for (i = 0; i < 3; ++i) {
        text = XmStringCreateLocalized((char *)labels[i]);
        tag = XmCreateLabel(bar, "statusEntry", NULL, 0);
        XtVaSetValues(tag,
                      XmNlabelString, text,
                      XmNbackground, colors[i],
                      XmNforeground, palette->bg_base,
                      XmNalignment, XmALIGNMENT_BEGINNING,
                      XmNmarginWidth, 8,
                      XmNmarginHeight, 4,
                      NULL);
        XmStringFree(text);
        XtManageChild(tag);
    }

    XtManageChild(bar);
    return bar;
}

static Pixel banner_color_for_section(const Palette *palette, int index) {
    switch (index) {
    case 0:
        return palette->status_success;
    case 1:
        return palette->accent;
    case 2:
        return palette->status_warning;
    case 3:
        return palette->status_warning;
    case 4:
        return palette->status_danger;
    case 5:
        return palette->status_offline;
    default:
        return palette->status_success;
    }
}

static void nav_select_section(NavigationContext *ctx, int index) {
    int i;
    XmString bannerText;
    Pixel defaultBg;
    Pixel defaultFg;
    Pixel selectedBg;
    Pixel selectedFg;

    if (ctx == NULL || index < 0 || index >= WORKSPACE_SECTION_COUNT) {
        return;
    }

    defaultBg = ctx->palette->bg_panel;
    defaultFg = ctx->palette->text_secondary;
    selectedBg = ctx->palette->accent;
    selectedFg = ctx->palette->bg_base;

    for (i = 0; i < WORKSPACE_SECTION_COUNT; ++i) {
        if (ctx->buttons[i] != NULL) {
            Pixel bg = (i == index) ? selectedBg : defaultBg;
            Pixel fg = (i == index) ? selectedFg : defaultFg;
            XtVaSetValues(ctx->buttons[i],
                          XmNbackground, bg,
                          XmNforeground, fg,
                          NULL);
        }
    }

    if (ctx->contentText != NULL) {
        XmTextSetString(ctx->contentText, (char *)SECTION_CONTENT_STRINGS[index]);
    }

    if (ctx->banner != NULL) {
        bannerText = XmStringCreateLocalized((char *)SECTION_BANNER_STRINGS[index]);
        XtVaSetValues(ctx->banner,
                      XmNlabelString, bannerText,
                      XmNbackground, banner_color_for_section(ctx->palette, index),
                      NULL);
        XmStringFree(bannerText);
    }

    ctx->selectedIndex = index;
}

static void nav_button_activated(Widget widget, XtPointer clientData, XtPointer callData) {
    NavCallbackData *info = (NavCallbackData *)clientData;
    if (info != NULL && info->context != NULL) {
        nav_select_section(info->context, info->index);
    }
}

void ui_build_shell(Widget toplevel, const Palette *palette) {
    Widget mainWindow;
    Widget form;
    Widget statusBar;
    Widget navPanel;
    Widget contentPanel;
    NavigationContext *navCtx;

    navCtx = (NavigationContext *)calloc(1, sizeof(NavigationContext));
    if (navCtx == NULL) {
        return;
    }
    navCtx->palette = palette;
    navCtx->selectedIndex = -1;

    mainWindow = XmCreateMainWindow(toplevel, "mainWindow", NULL, 0);
    XtVaSetValues(mainWindow,
                  XmNbackground, palette->bg_base,
                  NULL);

    form = XmCreateForm(mainWindow, "rootForm", NULL, 0);
    XtVaSetValues(form,
                  XmNbackground, palette->bg_base,
                  NULL);

    statusBar = create_status_bar(form, palette);
    XtVaSetValues(statusBar,
                  XmNbottomAttachment, XmATTACH_FORM,
                  XmNleftAttachment, XmATTACH_FORM,
                  XmNrightAttachment, XmATTACH_FORM,
                  NULL);

    navPanel = create_navigation_panel(form, palette, navCtx);
    XtVaSetValues(navPanel,
                  XmNtopAttachment, XmATTACH_FORM,
                  XmNleftAttachment, XmATTACH_FORM,
                  XmNrightAttachment, XmATTACH_POSITION,
                  XmNrightPosition, 28,
                  XmNbottomAttachment, XmATTACH_WIDGET,
                  XmNbottomWidget, statusBar,
                  XmNbottomOffset, 8,
                  XmNtopOffset, 8,
                  XmNleftOffset, 8,
                  NULL);

    contentPanel = create_content_panel(form, palette, navCtx);
    XtVaSetValues(contentPanel,
                  XmNtopAttachment, XmATTACH_FORM,
                  XmNleftAttachment, XmATTACH_WIDGET,
                  XmNleftWidget, navPanel,
                  XmNleftOffset, 12,
                  XmNrightAttachment, XmATTACH_FORM,
                  XmNrightOffset, 8,
                  XmNbottomAttachment, XmATTACH_WIDGET,
                  XmNbottomWidget, statusBar,
                  XmNbottomOffset, 8,
                  XmNtopOffset, 8,
                  NULL);

    XtManageChild(navPanel);
    XtManageChild(contentPanel);
    XtManageChild(statusBar);
    XtManageChild(form);

    XmMainWindowSetAreas(mainWindow, NULL, NULL, NULL, NULL, form);
    XtManageChild(mainWindow);

    nav_select_section(navCtx, 0);
}
