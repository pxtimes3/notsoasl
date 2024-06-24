## Builds the world.[br]
## Loads the map-mesh[br]
## Adds a navigationarea[br]
## Places static objects on the map (buildings etc.)[br]
## Creates deployment zones[br]
## Adds weather, time etc.[br]

class_name GameWorld
extends Node

const MISSION_PARAMS = ["name", "path", "mesh", "size", "datetime", "weather", "turns", "players"]
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
	createSpawnAreas()
	
	
## Checks the provided dictionary for parameters in the required.array
## Dives deeper into the players section.
var error_counts = {
	"mission": 0,
	"player": 0
}

func checkParameters():
	Log.info(self, "Checking mission parameters...")
	error_counts["mission"] = checkRequiredParams(missionParameters, MISSION_PARAMS, "Mission")
	
	if missionParameters.has("players"):
		Log.info(self, "Checking player parameters...")
		error_counts["player"] = checkPlayerParameters()
	
	logResults()

func checkRequiredParams(params: Dictionary, required: Array, context: String) -> int:
	var missing_params = []
	for r in required:
		if not params.has(r):
			missing_params.append(r)
	
	for param in missing_params:
		Log.error(self, "%s parameters is missing \"%s\"" % [context, param])
	
	return missing_params.size()

func checkPlayerParameters() -> int:
	var total_errors = 0
	for p in missionParameters.players: #   var p		 var n            var x
		for n in missionParameters[p]:  # {"player1": { "companyName1" : { ... }, "companyName2": {... }, ...}
			for x in missionParameters[p][n]:
				total_errors += checkRequiredParams(missionParameters[p][n], PLAYER_PARAMS, "Player: %s" % p)
	return total_errors

func logResults():
	for context in error_counts:
		Log.info(self, "%s parameters checked. %d errors found." % [context.capitalize(), error_counts[context]])


## Loads a obj (preferred) or glb mesh
func loadMapMesh():
	var mesh_resource = checkForMapMesh()
	var mesh
	if mesh_resource is PackedScene:  # glb
		mesh = mesh_resource.get_scene().get_node("YourMeshNodeName").mesh
	else:  # obj
		mesh = mesh_resource
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	
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
	
	add_child(nav_region)
	
func bakeNavigationmesh(nav): # when we're in the scene tree
	nav.get_child(0).bake_navigation_mesh(true)
	
	
	
## Checks the res:// and user:// directory for a file with the name as defined in missionParameters dictionary.[br]
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
					position_x = zone_width / 2  # Place at left edge
				else:
					position_x = map_width - (zone_width / 2)  # Place at right edge
				#else:
					# TODO: NPCs?
					#position_x = map_width / 2  # Default to center
				
				position_z = map_depth / 2  # Center on z-axis
			
			decal.size = Vector3(zone_width, zone_depth, 10)
			decal.position = Vector3(position_x, 5, position_z)
			decal.rotation_degrees.x = 90  # Project downwards
			
			# Create a texture for the decal
			var texture = GradientTexture2D.new()
			var gradient = Gradient.new()
			if player == "player1":
				#texture.albedo_color = Color(0, 0, 1, 1)
				gradient.add_point(0.0, Color(0, 0, 1, 1))  # Semi-transparent blue
				gradient.add_point(1.0, Color(0, 0, 1, 1))  # Transparent blue at the edges
			else:
				#texture.albedo_color = Color(1, 0, 0, 1)
				gradient.add_point(0.0, Color(1, 0, 0, 1))  # Semi-transparent red
				gradient.add_point(1.0, Color(1, 0, 0, 1))  # Transparent red at the edges
			
			texture.gradient = gradient
			texture.width = 256
			texture.height = 256
			texture.fill = GradientTexture2D.FILL_RADIAL
			#texture.fill_from = Vector2(0.5, 0.5)
			#texture.fill_to = Vector2(1, 0.5)
			texture.fill_from = Vector2(1, 1)
			texture.fill_to = Vector2(1, 1)
			#
			## Set the texture to the decal
			decal.texture_albedo = texture
			
			add_child(decal)
			
#func createSpawnAreas():
	#pass
	#var n = 0
	#for x in missionParameters.deployment.keys():
		#var zone = MeshInstance3D.new()
		#var imm = BoxMesh.new()
		#var mat = StandardMaterial3D.new()
		#
		#if n == 0: 
			#mat.albedo_color = Color(0,0,1,0.1)
			#n += 1
		#else: 
			#mat.albedo_color = Color(1,0,0,0.1)
		#imm.set_size(Vector3(200,1,50))
		#zone.mesh = imm
		#imm.material = mat
		#zone.transparency = 0.9
		#zone.cast_shadow = false
		#zone.position = calcZonePosition(x)
		#zone.name = str(x) + "_deploy"
		#zone.hide()
		#add_child(zone)
	#
#func calcZonePosition(player: String, z : int = 200, x : int = 50):
	#var mapz = mapSize[0]
	#var mapx = mapSize[1]
	#
	#var pos = Vector3(0,0,0)
	#
	#pos.y = 10
	#pos.z = (mapz / 2.0) - (x / 2.0)
	#if player == "player2":
		#pos.z -= mapx - x
	#
	#return pos
