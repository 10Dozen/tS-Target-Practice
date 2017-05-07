
dzn_fnc_onKeyPress = {
	if (!alive player || dzn_keyIsDown) exitWith {};
	private["_key","_shift","_crtl","_alt","_handled"];	
	_key = _this select 1; 
	_crtl = _this select 3;
	_handled = false;
	
	switch _key do {
		case 59: {
			[] spawn dzn_fnc_showMenu;		
			dzn_keyIsDown = true;
			_handled = true;
		};
		case 60: {
			["Open", true] call BIS_fnc_arsenal; 
			dzn_keyIsDown = true;
			_handled = true;
		};
		case 61: {
			call dzn_fnc_markUp;
			dzn_keyIsDown = true;
			_handled = true;
		};
		case 62: {
			[] spawn dzn_fnc_spawnPlayerVehicle;
			dzn_keyIsDown = true;
			_handled = true;
		};		
		case 63: {
			[] spawn dzn_fnc_removeTargets;
			dzn_keyIsDown = true;
			_handled = true;
		};
		case 64: {
			[] spawn dzn_fnc_showAddMagazines;
			dzn_keyIsDown = true;
			_handled = true;
		};
		case 33: {
			if (_crtl) then { 
				call dzn_fnc_loadSingleRound;
				dzn_keyIsDown = true;
				_handled = true;
			};
		};
	};
	
	[] spawn { sleep 1; dzn_keyIsDown = false; };
	
	_handled
};

dzn_fnc_loadSingleRound = {
	player setAmmo [currentWeapon player, 1]; 
	[
		parseText "<t shadow='2' align='center' font='PuristaBold' size='1.25'>ROUND LOADED</t>"
		, [.5,.85,1,1], nil, 7, 0.2, 0 
	] spawn BIS_fnc_textTiles;
};

dzn_fnc_showMenu = {
	[
		[0, "HEADER", "NEW TARGET"]
		
		, [1, "LABEL", "Do you want to change location?"]
		, [1, "CHECKBOX"]
		
		, [2, "LABEL", ""]
		, [3, "LABEL", "Target"]
		, [3, "LISTBOX", ["INFANTRY", "VEHICLE", "AERIAL"], [0,1,2]]
		
		, [4, "LABEL", "Vehicle type"]
		, [4, "DROPDOWN", targetVehiclesNames + [""], targetVehicles + [""]]
		
		, [5, "LABEL", "Target range"]
		, [6, "SLIDER", [50,5000, lastRange]]
		
		, [7, "LABEL", "Allow target moving"]
		, [7, "CHECKBOX"]
		
		, [8, "LABEL", "Mark target"]
		, [8, "CHECKBOX"]
		
		, [9, "LABEL", ""]
		
		, [10, "BUTTON", "CANCEL", { closeDialog 2; }]
		, [10, "LABEL", ""]
		, [10, "LABEL", ""]
		, [10, "BUTTON", "OK", { 
			_this spawn dzn_fnc_createTarget;
			closeDIalog 2;
		}]
	] call dzn_fnc_ShowAdvDialog;
};

dzn_fnc_showAddMagazines = {
	private _menu = [[0, "HEADER", "ADD MAGAZINES"]];	
	private _menuLine = 1;
	addMagazineTypes = [false,false,false];
	
	if (primaryWeapon player != "") then {
		private _listOfMags = getArray(configFile >> "CfgWeapons" >> primaryWeapon player >> "magazines");
	
		_menu = _menu + [
			[_menuLine, "LABEL", format["PRIMARY (%1)", (primaryWeapon player) call dzn_fnc_getItemDisplayName]]
			,[_menuLine + 1, "LABEL", ""]
			,[_menuLine + 1, "DROPDOWN", _listOfMags apply { _x call dzn_fnc_getItemDisplayName }, _listOfMags]
			,[_menuLine + 1, "SLIDER", [0,10,0]]
			,[_menuLine + 2, "LABEL", ""]
		];	
		
		_menuLine = _menuLine + 3;
		addMagazineTypes set [0, true];
	};
	
	if (secondaryWeapon player != "") then {
		private _listOfMags = getArray(configFile >> "CfgWeapons" >> secondaryWeapon player >> "magazines");
	
		_menu = _menu + [
			[_menuLine, "LABEL", format["SECONDARY (%1)", (secondaryWeapon player) call dzn_fnc_getItemDisplayName]]
			,[_menuLine + 1, "LABEL", ""]
			,[_menuLine + 1, "DROPDOWN", _listOfMags apply { _x call dzn_fnc_getItemDisplayName }, _listOfMags]
			,[_menuLine + 1, "SLIDER", [0,10,0]]
			,[_menuLine + 2, "LABEL", ""]
		];	
		
		_menuLine = _menuLine + 3;
		addMagazineTypes set [1, true];
	};
	
	if (handgunWeapon player != "") then {
		private _listOfMags = getArray(configFile >> "CfgWeapons" >> handgunWeapon player >> "magazines");
	
		_menu = _menu + [
			[_menuLine, "LABEL", format["HANDGUN (%1)", (handgunWeapon player) call dzn_fnc_getItemDisplayName]]
			,[_menuLine + 1, "LABEL", ""]
			,[_menuLine + 1, "DROPDOWN", _listOfMags apply { _x call dzn_fnc_getItemDisplayName }, _listOfMags]
			,[_menuLine + 1, "SLIDER", [0,10,0]]
			,[_menuLine + 2, "LABEL", ""]
		];	
		
		_menuLine = _menuLine + 3;
		addMagazineTypes set [2, true];
	};
	
	_menu = _menu + [
		[_menuLine,"LABEL", ""]
		,[_menuLine + 1,"BUTTON", "CANCEL", { closeDialog 2; }]
		,[_menuLine + 1,"LABEL", ""]
		,[_menuLine + 1,"LABEL", ""]
		,[_menuLine + 1,"BUTTON", "ADD", { 
			_this spawn dzn_fnc_addMagazines;
			closeDIalog 2; 
		}]
	];
	
	if (_menuLine == 1) then { 
		_menu set [1, [_menuLine, "LABEL", "<t align='center'>NO WEAPONS</t>"]];
		_menu set [5, [_menuLine + 1, "LABEL", ""]];
	};
	_menu call dzn_fnc_ShowAdvDialog;
};

dzn_fnc_addMagazines = {
	private _priMagId = 0;
	private _secMagId = if (addMagazineTypes select 0) then { 2 } else { 0 };
	private _handMagId = if (addMagazineTypes select 0 && addMagazineTypes select 1) then { 4 } else { 2 };
	
	private _id = 0;
	if (addMagazineTypes select 0) then {		
		private _mag = ((_this select _id) select 2) select ((_this select _id) select 0);
		private _count = ((_this select (_id + 1)) select 0);
		
		player addMagazines [_mag, _count];
		_id = _id + 2;
	};
	
	if (addMagazineTypes select 1) then {		
		private _mag = ((_this select _id) select 2) select ((_this select _id) select 0);
		private _count = ((_this select (_id+1)) select 0);
		
		player addMagazines [_mag, _count];
		_id = _id + 2;
	};
	
	if (addMagazineTypes select 2) then {		
		private _mag = ((_this select _id) select 2) select ((_this select _id) select 0);
		private _count = ((_this select (_id+1)) select 0);
		
		player addMagazines [_mag, _count];
	};
	
	[
		parseText "<t shadow='2' align='center' font='PuristaBold' size='1.25'>MAGAZINES ADDED</t>"
		, [.5,.85,1,1], nil, 7, 0.2, 0 
	] spawn BIS_fnc_textTiles;
};


dzn_fnc_createTarget = {	
	private _changeLocation 	= (_this select 0) select 0;
	private _tgtType 		= ((_this select 1) select 2) select ((_this select 1) select 0);
	private _vehClass 		= ((_this select 2) select 2) select ((_this select 2) select 0);
	private _range 		= (_this select 3) select 0;	
	private _allowMove 		= (_this select 4) select 0;
	private _markTarget 		= (_this select 5) select 0;
	
	lastRange = _range;
	
	hint "Generating new target...";
	if (_changeLocation) then {
		private _newPos = call dzn_fnc_getNewPosition;
		firingPos = _newPos select 0;
		firingDir = _newPos select 1;		
	} else {
		firingPos = getPosASL player;
		firingDir = getDir player;
	};
	
	tgtPos = [firingPos, firingDir, _range] call dzn_fnc_getPosOnGivenDir;
	tgtPos set [2,0];	
	
	private _tgt = objNull;
	private _grp = grpNull;
	if (_tgtType > 0) then {
		_tgt = createVehicle [
			_vehClass
			, tgtPos, [], 0
			, if (_tgtType == 2) then { "FLY" } else { "NONE" }
		];
		
		_tgt allowDamage false;
		_tgt setDir (round(random 350));
		
		if (_allowMove || _tgtType == 2) then {			
			_grp = [_tgt, east,  ["driver"]] call dzn_fnc_createVehicleCrew;		 
		}
	} else {
		_grp = createGroup east;
		_tgt = _grp createUnit ["O_Soldier_F", tgtPos, [], 0, "FORM"];
	};
	
	if (_allowMove) then {
		private _points = [];
		for "_i" from 0 to 4 do {
			_points pushBack ([tgtPos, if (_tgtType == 2) then { 800 } else { 100 }] call dzn_fnc_getRandomPoint)
		};
		[_grp, _points, 4, true, [1,3,6]] call dzn_fnc_createPathFromKeypoints;
		
		{ _tgt disableAI _x } forEach ["TARGET","AUTOTARGET"];	
	} else {
		{ _tgt disableAI _x } forEach ["MOVE","TARGET","AUTOTARGET","FSM","COVER"];	
	};
	
	[_tgt] spawn {
		
		sleep 2;
		_tgtEH = (_this select 0) addEventHandler ["Hit", {		
			(_this select 0) setVariable [
				"hits"
				, ((_this select 0) getVariable "hits") + 1
			];	
			
			if (alive (_this select 0)) then {
				hint parseText format ["<t size='1.3' color='#f9b727'>Target Hit!</t><br/><br/><t size='1.7'>x%1</t>", (_this select 0) getVariable "hits"]; 
			
				[
					parseText (format [
						"<t shadow='2'color='#e6c300' align='center' font='PuristaBold' size='1.5'>H I T! x%1</t>"
						, (_this select 0) getVariable "hits"
					])
					, [0,.7,1,1], nil, 7, 0.2, 0
				] spawn BIS_fnc_textTiles;
			};		
		}];
		
		(_this select 0) allowDamage true;
		
		waitUntil {sleep 0.5; !alive (_this select 0)};
		hint parseText format ["<t size='1.3' color='#f9b727'>Target Killed!</t><br/><br/><t size='1.2'>%1 hits total</t>", (_this select 0) getVariable "hits"];
		[
			parseText "<t shadow='2'color='#e6c300' align='center' font='PuristaBold' size='1.5'>KILLED</t>"
			, [0,.7,1,1], nil, 7, 0.2, 0
		] spawn BIS_fnc_textTiles;
	};
	_tgt setVariable ["hits", 0];
	missionNamespace setVariable ["tgt", _tgt];
	
	if (_changeLocation) then { 
		1000 cutText ["","Black out",1];
		sleep 2; 
		1000 cutText ["","Black In", 1];	
		player setPos [firingPos select 0, firingPos select 1, 0];
		player setDir firingDir;
	};
	
	hint format [
		"New target generated!\nType: %1\nRange: %2"
		, switch (_tgtType) do {
			case 0: { "Infantry" };
			case 1: { "Vehicle" };
			case 2: { "Aerial" };
		}
		, str(_range) + " m"		
	];
	
	isMarkOn = _markTarget;
	createdTargets pushBack [_tgt, _grp];
};

dzn_fnc_getNewPosition = {
	// Return position from list
	selectRandom [
		[ [11748.6,12018.3,2.71929],37]
		,[ [10642.2,14152.2,2.24686],67]
		,[ [9467.73,14870.6,2.52682],267]
		,[ [7649.55,11256.9,1.43628],313]
		,[ [4392.94,17539.5,2.52745],303]
		,[ [10622.3,18683.2,3.27674],142]
	]
};

dzn_fnc_markUp = {
	if (isMarkOn) then { 
		isMarkOn = false;	
	} else {
		isMarkOn = true;		
	};
};

dzn_fnc_showMark = {
	if !(isMarkOn) exitWith {};
	private["_posV","_textPos","_text"];
	_posV = [visiblePosition tgt select 0, visiblePosition tgt select 1, if (tgt isKindOf "Air") then { visiblePosition tgt select 2 } else { -1.5 } ];
	_textPos = [visiblePosition tgt select 0, visiblePosition tgt select 1, if (tgt isKindOf "Air") then { (visiblePosition tgt select 2) - 0.025*(player distance tgt)  } else { -0.025*(player distance tgt) }];
	_text = str(round(player distance tgt)) + "m";
	
	drawIcon3D ['', [1,0,0,1], _posV, 0, 0, 0, "+", 2, 0.035, 'puristaMedium'];
	drawIcon3D ['', [1,0,0,1], _textPos, 0, 0, 0, _text , 2, 0.025, 'puristaMedium'];
};

dzn_fnc_spawnPlayerVehicle = {
	private["_dialogResult","_vehicleClass","_veh","_driver"];

	_dialogResult =	[
		"Vehicle Request",
		[
			["Vehicle Type", allowedPlayerVehicleNames]
			,["AI Driver", [ "No","Yes" ]]			
		]			
	] call dzn_fnc_ShowChooseDialog;	
	if (count _dialogResult == 0) exitWith { };

	_vehicleClass = allowedPlayerVehicles select (_dialogResult select 0);
	_veh = createVehicle [ _vehicleClass , (getPos player), [], 0, "NONE"];
	_veh setDir firingDir;
	if !(isNull pVeh) then { 
		{ 
			moveOut _x; 
			if (isPlayer _x) then { deleteVehicle _x; };
		} forEach (crew pVeh);
		if !(isNull pVehDriver) then { deleteVehicle pVehDriver };
		deleteVehicle pVeh;
	};
	pVeh = _veh;
	
	player moveInGunner _veh;
	if !(vehicle player == player) then { player moveInCommander _veh };
	
	if (_dialogResult select 1 > 0) then {
		_driver = (group player) createUnit ["B_crew_F", getPos player, [], 0, "NONE"];
		_driver disableConversation true;
		_driver moveInDriver _veh;
		pVehDriver = _driver;
		
		_driver spawn {
			sleep 2;
			if (vehicle _this == _this) then { deleteVehicle _this }
		};		
	};
};

dzn_fnc_removeTargets = {
	{
		deleteVehicle (_x select 0);
		{
			deleteVehicle _x;
		} forEach (units (_x select 1));
		
		deleteGroup (_x select 1);
	} forEach createdTargets;
	
};

/*
 *	
 */
 
tgtPos = [];
firingPos = [];
firingDir = 0;
pVeh = objNull;
pVehDriver = objNull;
tgt = objNull;
vehListInitDone = false;
isMarkOn = false;
keyEH = 0;

dzn_keyIsDown = false;
lastRange = 50;
createdTargets = [];

targetVehicles = [];
targetVehiclesNames = [];
allowedPlayerVehicles = [];
allowedPlayerVehicleNames = [];
	
	
[] spawn {
	private ["_allVehs", "_i", "_name", "_class","_dlcName"];
	
	private _getList = {
		private ["_list", "_resultedListName", "_resultedListClassesName"];
		_list = _this;
		
		_resultedListName = [];
		_resultedListClassesName = [];
		
		for "_i" from 0 to (count _list) - 1 do {
			private _class = configName(_list select _i);
			private _name = _class call dzn_fnc_getVehicleDisplayName;		
			private _dlcName =  getText (configFile >> "CfgVehicles" >> _class >> "dlc") ;
			if ( _dlcName == "" ) then { _dlcName = _class };
			
			if !(_name in _resultedListName) then {
				_resultedListClassesName  pushBack _class;
				_resultedListName pushBack format ["%1   (%2)", _name, _dlcName];
			};
		};
		
		[_resultedListClassesName, _resultedListName]
	};
	
	_toSpawnVehs = (
		"isclass _x && getnumber (_x >> 'scope') == 2 
		&& !(getNumber (_x >> 'side') in [3,4]) 
		&& getText (_x >> 'vehicleClass') in [
			'Car'
			,'Armored'
			, 'Air'
			,'LOP_Wheeled'
			,'LOP_Armored'
			,'rhs_vehclass_ifv'
			,'rhs_vehclass_truck'
			,'rhs_vehclass_apc'
			,'rhs_vehclass_tank'
			,'rhs_vehclass_car'
		]"
	) configclasses (configfile >> "CfgVehicles");
	
	private _list = _toSpawnVehs call _getList;
	targetVehicles = _list select 0;
	targetVehiclesNames = _list select 1;
	
	_allVehs =  (
		"isclass _x && getnumber (_x >> 'scope') == 2 
		&& !(getNumber (_x >> 'side') in [3,4]) 
		&& getText (_x >> 'vehicleClass') in [
			'Car'
			,'Armored'
			,'Air'
			,'Static'
			,'LOP_Wheeled'
			,'LOP_Armored'
			,'LOP_Static'
			,'rhs_vehclass_ifv'
			,'rhs_vehclass_truck'
			,'rhs_vehclass_apc'
			,'rhs_vehclass_tank'
			,'rhs_vehclass_car'
		]"
	) configclasses (configfile >> "CfgVehicles");
	
	_list = _allVehs call _getList;
	allowedPlayerVehicles = _list select 0;
	allowedPlayerVehicleNames = _list select 1;
	
	vehListInitDone = true;
};


[] spawn {	
	player createDiaryRecord [
		"Diary"
		,[
			"Hotkeys"
			, "F1 : New target menu (to select new infantry/vehicle target)
			<br />F2 : Open Virtual Arsenal
			<br />F3 : Mark Up target with 3d marker
			<br />F4 : Spawn vehicle for player (optional AI driver is available)
			<br />F5 : Delete all targets
			<br />F6 : Add Magazines menu (to re-add some weapon magazines)
			<br />Ctrl + F : Load single round to current weapon (useful to practice with bolt-action rifles)"
		]
	];
	
	sleep 2;
	waitUntil { !isNull  (findDisplay 46) };
	
	bis_fnc_arsenal_fullArsenal = true;
	["dzn_tgtMarkUp", "onEachFrame", { call dzn_fnc_showMark }] call BIS_fnc_addStackedEventHandler;	
	
	keyEH = (findDisplay 46) displayAddEventHandler ["KeyDown", "_handled = _this call dzn_fnc_onKeyPress"];
	
	if (isClass (configfile >> "CfgWeapons" >> "ACE_EarPlugs")) then { player addItem "ACE_EarPlugs"; };	
	
	player addAction [
		"<t color='#f9b727'>(F1) New Target</t>"
		, { [] spawn dzn_fnc_showMenu; }
	];
	player addAction [
		"<t color='#7193e2'>(F2) Open Arsenal</t>"
		, { ["Open", true] call BIS_fnc_arsenal; }
	];
	player addAction [
		"<t color='#c10000'>(F3) Mark Up Target</t>"
		, { if (isNull tgt) exitWith {}; call dzn_fnc_markUp; }
	];
	waitUntil { vehListInitDone };
	player addAction [
		"<t color='#5ac100'>(F4) Spawn Vehicle</t>"
		, { [] spawn dzn_fnc_spawnPlayerVehicle; }
	];
	player addAction [
		"<t color='#484f42'>(F5) Delete all targets</t>"
		, { [] spawn dzn_fnc_removeTargets; }
	];
	player addAction [
		"<t color='#f7a413'>(F6) Add Magazines</t>"
		, { [] spawn dzn_fnc_showAddMagazines; }
	];
	player addAction [
		"<t color='#126387'>(Ctrl+F) Single round</t>"
		, { [] spawn dzn_fnc_loadSingleRound; }
	];
	player addAction [
		"<t color='#878787'>Re-add hotkeys</t>"
		, { 			
			(findDisplay 46) displayRemoveEventHandler ["KeyDown", keyEH];
			(findDisplay 46) displayAddEventHandler [
				"KeyDown"
				, "_handled = _this call dzn_fnc_onKeyPress"
			]; 
		}
	];
};