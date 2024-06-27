## Builds the world.[br]
## Loads the map-mesh[br]
## Adds a navigationarea[br]
## Places static objects on the map (buildings etc.)[br]
## Creates deployment zones[br]
## Adds weather, time etc.

class_name GameWorld
extends Node

const MISSION_PARAMS = ["name", "path", "mesh", "size", "datetime", "weather", "turns", "players", "missingKey", "debug"]
const PLAYER_PARAMS = ["definitions", "units"]

## HHMM (ex: 1459)
@export var time : int = 1200		# time hhmm
## yymmdd (ex: 430219)
@export var date : int = 391022		# date yymmdd
## Ground conditions. Modified by precipitation.
@export var ground : Ground
## Meters per second.
@export var wind_speed : float = 1.0	# meters per second
## Clock. North = 12, South = 6, East = 3, West = 9
@export var wind_dir : int = 9			# clock, 12 is north, 6 south
## Sets precipitation type.
@export var season : Season
## RAIN/SNOW depending on season. Range from 1-10. 
@export var precipitation : int
## JSON-data from the mission editor
@export var missionParameters : Dictionary
## Path to the mission directory
@export var missionDirectory : String

enum Season {
	SPRING = 0,
	SUMMER = 1,
	AUTUMN = 2,
	WINTER = 4
}

enum Weather {
	CLEAR = 0,
	CLOUDY = 1,
	RAIN = 2,
	SNOW = 3
}

enum Ground {
	FIRM = 0,
	SOFT = 1,
	MUDDY = 2,
}


func _init(parameters : Dictionary):
	missionParameters = parameters
	checkParameters()
	loadMapMesh()
	addWorldObjects()
	createSpawnAreas()

func _ready():
	bakeNavigationmesh(self)
	

var error_counts : Dictionary = {
	"mission": 0,
	"player": 0
}

## Checks the provided dictionary for keys defined in the required.array [br]
func checkParameters():
	Log.info(self, "Checking mission parameters...")
	error_counts["mission"] = checkRequiredParams(missionParameters, MISSION_PARAMS, "Mission parameters")
	
	if missionParameters.has("players"):
		Log.info(self, "Checking player parameters...")
		error_counts["player"] = checkPlayerParameters()
	
	logResults()


## Main function for the parameter-checking.
func checkRequiredParams(params: Dictionary, required: Array, context: String) -> int:
	var missing_params := []
	var missing_values := []
	for r in required:
		if not params.has(r):
			missing_params.append(r)
		else:
			if not checkParamForValue(params[r], r):
				missing_values.append(r)
	
	for param in missing_params:
		Log.error(self, "%s is missing \"%s\"" % [context, param])
	for param in missing_values:
		Log.error(self, "%s: %s is missing values." % [context, param])
	
	return missing_params.size()


## Handles aaaaall the values!
func checkParamForValue(value, key : String = "") -> bool:
	if value == null:
		return false
	elif typeof(value) == TYPE_STRING and value.strip_edges() == "":
		return false
	elif typeof(value) == TYPE_ARRAY and value.size() < 1:
		return false
	elif typeof(value) == TYPE_DICTIONARY and value.size() < 1:
		return false
	else:
		return true


## Checks parameters for the player-entries.
func checkPlayerParameters() -> int:
	var total_errors = 0
	for p in missionParameters.players: #   var p		 var n            var x
		for n in missionParameters[p]:  # {"player1": { "companyName1" : { ... }, "companyName2": {... }, ...}
			#for x in PLAYER_PARAMS:
			total_errors += checkRequiredParams(missionParameters[p][n], PLAYER_PARAMS, "Player: %s" % p)
	return total_errors


## Logs the errors we found.
func logResults() -> void:
	for context in error_counts:
		## TODO: Saknade values rapporteras inte
		Log.info(self, "%s parameters checked. %d errors found." % [context.capitalize(), error_counts[context]])


## Loads a obj (preferred) or glb mesh representing the game area. [br]
## Adds collision shape and a navigation region.
func loadMapMesh() -> void:
	var mesh_resource = checkForMapMesh()
	var mesh : PackedScene
	if mesh_resource is PackedScene:  # glb
		mesh = mesh_resource
	else:  # obj
		mesh = mesh_resource
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	
	var texture : StandardMaterial3D = load("res://assets/textures/Rock Ground 02/4k/Rock Ground 02.tres")
	mesh_instance.material_override = texture
	
	var static_body = StaticBody3D.new()
	static_body.add_child(mesh_instance)
	
	var collision_shape = CollisionShape3D.new()
	var shape = mesh.create_trimesh_shape()
	
	collision_shape.shape = shape
	static_body.add_child(collision_shape)
	
	var nav_region = NavigationRegion3D.new()
		
	nav_region.add_child(static_body)
	
	var nav_mesh = NavigationMesh.new()
	nav_region.navigation_mesh = nav_mesh
	
	Log.debug(self, str("Map AABB: " + mesh.get_aabb().size))
	add_child(nav_region)
	

## Bake needs to be done when in the scene tree, so we call it from Main after adding it.
func bakeNavigationmesh(nav : GameWorld) -> void: 
	nav.get_child(0).bake_navigation_mesh(true)


## Checks the res:// and user:// directory for a file with the name as defined in missionParameters dictionary.
## Returns false and a fatal error if not found. 
## TODO: Make sure this shuts down the loading.
func checkForMapMesh() -> Resource:
	var paths = [
		"res://resources".path_join(missionParameters.path).path_join(missionParameters.mesh),
		"user://resources".path_join(missionParameters.path).path_join(missionParameters.mesh),
	]

	for path in paths:
		if FileAccess.file_exists(path):
			var resource = load(path)
			if resource:
				Log.info(self, "Map mesh loaded successfully from %s" % path)
				return resource
			else:
				Log.error(self, "Failed to load map mesh from %s" % path)

	Log.fatal(self, "No map mesh found in any of the expected locations")
	return null


## Creates the deployment-zones. Projects 
func createSpawnAreas():
	var map_width = missionParameters.size[0]
	var map_depth = missionParameters.size[1]
	
	for player in missionParameters.deployment.keys():
		for zone_name in missionParameters.deployment[player]:
			var zone = missionParameters.deployment[player][zone_name]
			var decal = Decal.new()
			
			var zone_width = zone[0]
			var zone_depth = zone[1]
			
			var position_x
			var position_z
			
			if len(zone) == 4:  # If x,y coordinates are provided
				position_x = zone[2]
				position_z = zone[3]
			else:  # If x,y coordinates are omitted
				if player == "player1":
					position_z = (map_depth / 2) - (zone_depth / 2) # Place at left edge
					position_x = 0
				else:
					position_x = 0
					position_z = -(map_depth / 2) + (zone_depth / 2) # Place at left edge
				#else:
					# TODO: NPCs?
					#position_x = map_width / 2  # Default to center
			
			decal.size = Vector3(zone_width, zone_depth, 10)
			decal.position = Vector3(position_x, 5, position_z)
			decal.rotation_degrees.x = 90  # Project downwards
			
			var texture : Resource
			var image : Image
			if player == "player1":
				texture =  load("res://resources/materials/deployment_blue.png")
			else:
				texture = load("res://resources/materials/deployment_red.png")
			
			image = texture.get_image()
			
			decal.texture_albedo = texture
						
			add_child(decal)


## Adds objects to the world
func addWorldObjects():
	if not missionParameters.is_empty():
		var objects = WorldObjects.new(missionParameters)
		for obj in objects.buildings:
			self.add_child(obj.duplicate())
