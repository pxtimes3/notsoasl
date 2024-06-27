## Mission Files

A mission is a single mission presenting a tactical problem for the player(s).

The mission can be part of a [campaign](../campaigns/index.md) or standalone. Click the link for further instructions on how a campaign is created and organized.

### File Structure

Missions should be located in `res://resources/missions` in a directory with the name of the mission in *lowercase letters and numbers only*. Custom missions should be located in `<userdata>/NotSoASL/resources/missions`. "My Basic Mission" becomes `/mybasicmission`, this is in order to facilitate for lazy developer(s).

The mission directory MUST contain the following:
```
..
mybasicmission/
|- parameters.json     # contains the parameters for the mission
|- world.json		   # contains positions for buildings, obstacles, forested areas etc.
|- mapmesh.obj/.glb    # the terrain
``` 

#### Parameters

The `parameters.json` defines the mission for the player(s). 
```JSON 
{
	"name": "My Basic Mission",			//-- User friendly name for the mission
	"campaign": true,					//-- true/false Lets the game know if it should add units from the campaign file or not
	"campaignPath": "",					//-- The path to the campaign, usually resources/campaigns/mybasiccampaign
	"path": "missions/mybasicmission",  //-- The path to the mission to let the game know where files are
	"mesh": "mapMesh.obj",				//-- The terrain mesh that will be imported. OBJ (preferred) or GLB
	"size": [							//-- The mesh will be transformed into these in game meters which corresponds to a meter in Blender.
		250,
		250
	],
	"datetime": "19441018@2100",		//-- Sets the date and time for the mission. The game uses this to place the sun/moon.
	"weather": "",						//-- Rain, fog, clear, overcast. See Weather for more information.
	"turns": 30,						//-- The total number of minutes until the mission ends
	"players": [
		"player1",						//-- Players on the map. Currently only 2 players with Player2 being the CPU is supported.
		"player2"
	],
	"player1": {						//-- This is where the units for the mission is defined
		"usarmyriflecompany": {			//-- Identifier for a *container* of units
			"definitions": "usarmyriflecompany1944.json",	//-- Where the TOE of the units is defined.
			"id": "riflecompany-1",		//-- Id for a company (full, reduced, augmented or such)
			"type": "riflecompany",		//-- Type. Currently not used
			"meta": false,				//-- Flag for CPU or player controlled
			"units": {		
										// -- See Units for more information
			}
		}
	},
	"player2": {
		"germanriflecompany": {
			"meta": true,
			"definitions": "",
			"units": {
				
			}
		}
	},
	"objectives": {						//-- Defines the objectives for the players as an array filled with dictionaries
		"player1": [
			{
				"id": "objective1",		//-- ID 
				"name": "Hold Able",	//-- User friendly name
				"conditions": {
										//-- TODO: Figure this out
				},
			},
		],
		"player2": []
	},
	"deployment": {						//-- Defines the deployment zones for the player(s) [width,depth, position-x, position-y]
		"player1": {					//-- A player can have more than one deployment zone so we can simulate ambushes
			"zone1": [200, 50],			//-- and other scenarios.
		},
		"player2": {
			"zone1": [200, 50, 0, -100],
		},
	}
}
```

#### Units

The mission units are (unless we are in a campaign) defined as follows:
```JSON
...
"units": {	
	"riflecompany-hq": {				//-- ID of the type of unit. Redundant but is included for readability.
		"id": "riflecompany-1-hq",		//-- ID of the unit itself. Useful if there is two depleted companies or similar.
		"name": [						//-- The name of the unit as displayed in the unit-icon .
			"A",						//-- Able Company
			"HQ",						//-- HQ / PLATOON
			""							//-- SQUAD (As long as the Coy HQ isn't divided into sections they have no squad-name)
		],
		"unitType": "company-hq",		//-- The type of unit as defined in scripts/json/toe/usarmyriflecompany1944.json
		"type": "unit"					//-- This is a unit and not a rock! TODO: Do we need this?
	},
	"rifleplatoon-1-hq": {				
		"id": "rifleplatoon-1-hq",
		"unitType": "rifleplatoon-hq",
		"type": "unit",
		"name": [						//--
			"A",						//-- Able Company
			"A",						//-- Able Platoon
			"HQ"						//-- Platoon HQ
		],
		"parent": "riflecompany-1-hq"	//-- This is so we can double click the Coy HQ and select every unit in the company.
	},
	"rifleplatoon-1-squad-A": {
		"id": "rifleplatoon-1-squad-A",
		"type": "unit",
		"unitType": "rifleplatoon-squad",
		"name": [
			"A",						//-- Able Company
			"A",						//-- Able Platoon
			"A"							//-- Able Squad. If the squad is divided into sections this mutates into A-A, A-B, etc...
		],
		"parent": "rifleplatoon-1-hq"
	},
``` 

#### World

Objects in the world are everything that is not the terrain (or units). This includes buildings, static obstacles such as large rocks, burnt out vehicles, livestock, fences etc.

Models for these are located either in `res://resources/models/world` in the format of a Godot 4 scene or in the corresponding `user://` directory.


```JSON
{
	"buildings": [					//-- Every world object is in an array so the game will know if it should create a navigation mesh for and what type of navigation mesh.
		{
			"model": "",			//-- Name of the model. Preferrably a Godot 4 scene if this is anything but water.
			"position": [0,0],		//-- X, Z coordinate of where the model should be placed on the map.
			"rotation": [0,0]		//-- Rotation, in degrees, on the X- & Z-axis. Z-axis is mostly there if anyone wants to make a Leaning tower in Pisa scenario.
		},
	],
	"obstacles": [					//-- Non passable structures. Large rocks or other obstructions that cannot be destroyed (or destroyed further...)
		{
			"model": "rock62",
			"position": [0,0,0],
			"rotation": [0,0,0]		//-- Also possible to use X,Y,Z for rotation and position. The game looks for the number of entries in the array. 2 = X,Y, 3=X,Y,Z
		}	
	],
	"water": [						//-- Locations for water. 
		
	],
	"areas": [						//-- Bridges can be 'areas' since they're not really buildings per se.
		{
			"type": "forest1",
			"model": "",			//-- Decided by the type, but is here for easy modification.
			"boundary": [
				[0,0],[0,1] ...		//-- Array of vertices for where the area should be placed.
			],
			"direction": 0,			//-- Not needed for areas such as forests. But can be used for fields of cereal etc.
			"start": [0,0],			//-- Ignored since this isn't a linear area such as a road.
			"length": 1, 			//-- Ignored since the length of the forest is defined by the boundary.
			"speed": 0,				//-- Multiplier for the unit speed if forest1 (dense forest w. undergrowth) isn't slow enough for any reason.
		},
		{
			"type": "road2",		//-- Road, foot paths, autobahns you name it. 
			"model": "",
			"boundary": [],			//-- Roads are defined in width by their model. So any value here is ignored.
			"direction": 0,			//-- Direction in degrees
			"start": [0,0],			//-- Start coordinates.
			"length": 100,			//-- How far before the road turns or ends or reaches a map edge.
			"speed": 0,				//-- Multiplier for the unit speed over this surface.
		}
	],
	"roaming": [					//-- The mission might be near a farmyard. Used to add some sort of 'life' to the mission
		{
			"type": "cow1-alive",
			"model": "",
			"position": [0,0]
		}
	]
}
```