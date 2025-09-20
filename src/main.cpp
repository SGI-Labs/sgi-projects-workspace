#include <Vk/VkApp.h>

#include "SystemInfoWindow.h"
#include "Scene3DWindow.h"

int main(int argc, char **argv)
{
    VkApp *app = new VkApp("irixSystemMonitor", &argc, argv);

    Scene3DWindow *sceneWindow = new Scene3DWindow("scene3DWindow");
    sceneWindow->show();

    SystemInfoWindow *infoWindow = new SystemInfoWindow("systemInfoWindow");
    infoWindow->show();

    app->run();

    delete infoWindow;
    delete sceneWindow;
    delete app;
    return 0;
}
