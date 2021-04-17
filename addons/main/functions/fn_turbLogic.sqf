/*
 * Author: Seb
 * Should not be called by itself. See Plane_Turbulence_fnc_turbulence instead.
 *
 * Public: Yes
 */
params ["_vehicle", "_dimensions", "_surfaceArea", "_maxSpeed", "_oldForce", "_oldCentre"];

// if weather effect is enabled in settings, easeIn to windiness value so that lower windiness/gustiness values have less of an effect.
private _windiness = [0, [0, 1, (windStr+overcast)/2] call BIS_fnc_easeIn] select PLANE_TURBULENCE_ENABLE_WEATHEREFFECT;
// 30 = 30m/s max windspeed at max rain and overcast
private _maxWindSpeed = (_windiness*PLANE_TURBULENCE_MAX_TURBULENCE)+PLANE_TURBULENCE_MIN_TURBULENCE;
// easeIn is more likely to select a low value, so big gusts are rare
private _gustSpeed = [PLANE_TURBULENCE_MIN_TURBULENCE, _maxWindSpeed, random(1)] call BIS_fnc_lerp;

// as it gets windier, the minimum gust length decreases so you can get more short sharp jerks
private _minGustLength = [0.5, 0.3, _windiness] call BIS_fnc_lerp;
private _maxGustLength = [0.7, 0.6, _windiness] call BIS_fnc_lerp;
// easeInOut is more likely to pick middling values, so big and small gusts are slightly less common.
private _gustLength = [_minGustLength, _maxGustLength, random(1)] call BIS_fnc_easeInOut;

// wind pressure per m^2 = (0.5*density of air*airVelocity^2). This approximates air density as 1.2 when it does depend on the temp and altitude
private _gustPressure = 0.5*1.2*(_gustSpeed*_gustSpeed);
// The gust force scalar is the force applied per second per unit surface area, divided by timestep.
private _gustForceScalar = _gustPressure * 0.05 * _surfaceArea;
// SpeedCoef makes aircraft MORE stable at higher speeds.
private _speed = ((velocity _vehicle) call CBA_fnc_vect2Polar)#0;
private _quarterSpeed = _maxSpeed * 0.25;
if (_speed > _quarterSpeed) then {
    private _speedCoef = [0.2, 1, ([1-((_speed-_quarterSpeed) / (_maxSpeed-_quarterSpeed)), 0, 1] call BIS_fnc_clamp)] call BIS_fnc_lerp;
    _gustForceScalar = _gustForceScalar * _speedCoef;
}; 
// selects a point on the hull for force the force to be applied.
private _turbulenceCentre  = _dimensions apply {(random(_x)-(_x/2))};
// force direction. Pick random direction use gustforcescalar as magnitude.
private _force = [_gustForceScalar, random(360), random(360)] call CBA_fnc_polar2Vect;

// waitAndExecute queues all the physics updates based on t/gust length.
private _currentUnit = call CBA_fnc_currentUnit;
if (!isGamePaused && isEngineOn _vehicle && currentPilot _vehicle == _currentUnit) then {    
        for "_i" from 0 to _gustLength step 0.05 do {
        [{
            params ["_vehicle", "_force", "_turbulenceCentre", "_i", "_gustLength", "_oldForce", "_oldCentre"];
            if ((getPos _vehicle)#2 < 2) exitWith {};
            private _progress = _i/_gustLength;
            private _forceN = [_oldForce, _force, _progress] call BIS_fnc_easeInOutVector;
            private _turbulenceCentreN = [_oldCentre, _turbulenceCentre, _progress] call BIS_fnc_easeInOutVector;
            _vehicle addForce [
                (_vehicle vectorModelToWorld _forceN),
                _turbulenceCentreN
            ];
        }, [_vehicle, _force, _turbulenceCentre, _i, _gustLength, _oldForce, _oldCentre], _i] call CBA_fnc_waitAndExecute;
    };
};

// Old force to interpolate from next loop
_oldForce = _force;
_oldCentre = _turbulenceCentre;

[{
    params ["_vehicle", "_dimensions", "_surfaceArea", "_maxSpeed", "_oldForce", "_oldCentre"];
    private _currentUnit = call CBA_fnc_currentUnit;
    if (_currentUnit in _vehicle) then {
        [_vehicle, _dimensions, _surfaceArea, _maxSpeed, _oldForce, _oldCentre] call Plane_Turbulence_fnc_turbLogic;
    };
}, [_vehicle, _dimensions, _surfaceArea, _maxSpeed, _oldForce, _oldCentre], _gustLength] call CBA_fnc_waitandExecute;