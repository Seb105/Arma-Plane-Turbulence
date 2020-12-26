#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = QUOTE(COMPONENT);
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"cba_main"};
        author = "Seb";
        VERSION_CONFIG;
    };
};

class CfgFunctions {
    class Plane_Turbulence {
        class Plane_Turbulence {
            file = "z\Plane_Turbulence\addons\main\functions";
            class turbulence {};
            class turbLogic {};
        };
    };
};

#include "CfgEventHandlers.hpp"
