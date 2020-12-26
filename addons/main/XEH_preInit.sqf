#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"
[
	"PLANE_TURBULENCE_ENABLE_MASTER",
	"CHECKBOX",
	["Enable Turbulence","Enables turbulence system. Requires getting in & out of aircraft for change to take effect."],
	["Aircraft Turbulence","Plane Turbulence"],
	true,
	0
] call CBA_fnc_addSetting;
[
	"PLANE_TURBULENCE_ENABLE_WEATHEREFFECT",
	"CHECKBOX",
	["Enable Weather Effects","Enables or disables whether weather has an effect on turbulence. When disabled, the minimum turbulence value is used."],
	["Aircraft Turbulence","Plane Turbulence"],
	true,
	0
] call CBA_fnc_addSetting;
[
	"PLANE_TURBULENCE_MIN_TURBULENCE",
	"SLIDER",
	["Minimum Turbulence","Set the minimum turbulence during calm weather. This number is also ADDED to the maximum turbulence"],
	["Aircraft Turbulence","Plane Turbulence"],
	[0,10,3,1],
	0
] call CBA_fnc_addSetting;
[
	"PLANE_TURBULENCE_MAX_TURBULENCE",
	"SLIDER",
	["Maximum Turbulence","Set the max turbulence during the most severe weather. The minimum turbulence value is also ADDED to this number."],
	["Aircraft Turbulence","Plane Turbulence"],
	[0,40,15,1],
	0
] call CBA_fnc_addSetting;
ADDON = true;