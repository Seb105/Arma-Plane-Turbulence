#include "script_component.hpp"
/*
 * Author: Seb
 * Plane_Turbulence_fnc_turbulence adds dynamic turbulence based on weather (overcast and windstrenght) to any vehicle (although it is designed for air vehicles).
 * Units are in metric unless specified, ass addForce command seems to be in Newtons.
 *
 * Arguments:
 * 0: The vehicle to which turbulence effect should be applied <OBJECT, VEHICLE>
 *
 * Return Value:
 * NONE
 *
 * Example:
 * vehicle call Plane_Turbulence_fnc_turbulence;
 *
 * Public: No
 */
params ["_vehicle"];
if !(PLANE_TURBULENCE_ENABLE_MASTER) exitWith{};
// init some vars that need to be interpolated from.
_vehicle setVariable ["PLANE_TURBULENCE_READY", true];
_vehicle setVariable ["PLANE_TURBULENCE_OLD_FORCE", [0, 0, 0]];
_vehicle setVariable ["PLANE_TURBULENCE_OLD_CENTRE", [0, 0, 0]];

// get vehicle max speed from cfg. maxSpeed is in kph to divide by 3.6 to get m/s
private _maxSpeed = ([configOf _vehicle, "maxSpeed"] call BIS_fnc_returnConfigEntry)/3.6;

// boundingBoxReal approximates the xyz dimensions of aircraft. Generally returns much larger than actual dimensions
private _bbr = 2 boundingBoxReal _vehicle;
private _p1 = _bbr select 0;
private _p2 = _bbr select 1;
private _maxWidth = 	abs ((_p2 select 0) - (_p1 select 0));
private _maxLength = 	abs ((_p2 select 1) - (_p1 select 1));
private _maxHeight = 	abs ((_p2 select 2) - (_p1 select 2));
private _dimensions = [_maxWidth, _maxLength, _maxHeight];	

// assume a spherical cow in a vacuum
// Approximates aircraft surface area as a cylinder. Then divides by two, as only 1/2 of the face will ever be facing the wind vector. (2πrh+2πr2)/2
private _surfaceArea = (2*pi*(_maxHeight/2)*_maxLength + 2*pi*(_maxHeight/2)^2)/2;

[{
	_this#0 params ["_vehicle", "_dimensions", "_surfaceArea", "_maxSpeed"];
	private _currentUnit = call CBA_fnc_currentUnit;
	// if player is no longer in vehicle, remove per frame event handler and undeclare variables
	if (vehicle _currentUnit == _vehicle) then {
		// if player is the Pilot and  game is not paused and Rotorlib Advanced Flight Model is NOT enabled and vehicle engine is on, cause turbulence.
		if (currentPilot _vehicle == _currentUnit && _vehicle getVariable "PLANE_TURBULENCE_READY") then {
			[_vehicle, _dimensions, _surfaceArea, _maxSpeed] call Plane_Turbulence_fnc_turbLogic;
		};
	} else {
		[_handle] call CBA_fnc_removePerFrameHandler;
		_vehicle setVariable ["PLANE_TURBULENCE_READY", nil];
		_vehicle setVariable ["PLANE_TURBULENCE_OLD_FORCE", nil];
		_vehicle setVariable ["PLANE_TURBULENCE_OLD_CENTRE", nil];
	};
},  
0
, [_vehicle, _dimensions, _surfaceArea, _maxSpeed]] call CBA_fnc_addPerFrameHandler;