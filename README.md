IRIX System Monitor
===================

This sample ViewKit application provides a minimalist IRIX system monitor window implemented with Motif widgets. It refreshes every five seconds (or on demand via the Refresh button) to display the hostname, OS release, hardware type, CPU count, and total/available physical memory.

Project layout
--------------
- `src/SystemInfoWindow.h` and `src/SystemInfoWindow.cpp` implement a `VkSimpleWindow` subclass that builds the UI, fetches system information, and manages the periodic update timer.
- `src/main.cpp` wires up the ViewKit application object and shows the window.
- `Makefile` targets the IRIX MIPSpro `CC` compiler by default and links against ViewKit/Motif/X11.

Building on IRIX
----------------
1. Ensure the ViewKit (`libVk`), Motif (`libXm`), and X11 development headers/libraries are installed. The default install on IRIX 6.5 already provides these under `/usr/include` and `/usr/lib32`.
2. Adjust the `INCLUDES`/`LIBPATHS` variables in the Makefile if your headers and libraries live outside the defaults (the placeholder `/Volumes/irix-include` mirrors the development headers in this workspace).
3. Run `make` to produce the `irix_system_monitor` executable.

Runtime notes
-------------
- The window schedules periodic refreshes only while it is visible; hiding or closing it stops the timer cleanly.
- CPU and memory statistics now try multiple kernel queries (`sysconf`, `sysmp`) and always fail gracefully. Values are formatted automatically in MB or GB depending on size.
