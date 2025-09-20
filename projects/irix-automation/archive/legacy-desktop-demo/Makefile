APP = irix_system_monitor
SRCS = src/main.cpp \
        src/SystemInfoWindow.cpp \
        src/Scene3DWindow.cpp
OBJS = $(SRCS:.cpp=.o)

CXX = CC
CXXFLAGS = -O2 -n32 -LANG:std
INCLUDES = -I/Volumes/irix-include
LIBPATHS =
LIBS = -lvk -lvkmsg -lvkhelp -lvkSGI -lGLw -lXm -lXt -lXmu -lGL -lGLU -lXext -lX11

.SUFFIXES: .o .cpp

all: $(APP)

$(APP): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $(OBJS) $(LIBPATHS) $(LIBS)

.cpp.o:
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

clean:
	rm -f $(APP) $(OBJS)

.PHONY: all clean
