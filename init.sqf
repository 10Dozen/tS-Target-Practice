enableSaving [false, false]; 

// Common Script Stuff
[] spawn {
	player allowDamage false;
	
	call compile preProcessFileLineNumbers "targetingFunctions.sqf";	
};