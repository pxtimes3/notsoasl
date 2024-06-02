extends Node3D 

var _parametersPath = ""
var _missionUnitsPath = ""
var _typePath = ""

var missionpath : String = "res://resources/missions/basicmission/" # missionpath as reported by MainMenu
# var missionSelector = "res://gui/mainMenu/MissionSelector.gd" # debug
var missionSelector = MissionSelector.new() # .get_node("MainMenu") # debug
# var missionparams = missionSelector.loadMissions()
var missionParams = {}
var mapSize = [0,0] # [z, x]
var _player : int = 0

 #debug variables
var unitsCreated = 0
var missionUnits : Dictionary = {}
var definitions = ""
var currentDefinitions = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	# load params
	#missionparams = $MissionSelector.missionsDict
	processParams(JSON.parse_string(FileAccess.get_file_as_string(missionpath + "parameters.json")))
	# load map
	# place objects (houses, roads, vegetation etc)
	# create spawn areas
	# createSpawnAreas()
	# create units
	#$Unit.new()
	Unit.unitCreation(missionParams, "")
	# place units


	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Node2D/fps.text = "FPS " + str(Engine.get_frames_per_second())
	
func executeTurn():
	# execute turn
		# process each "order" async
		# timer 60s
	pass

func processParams(json, extra : String = ""): # as a json-formatted string 
	MissionParameters.MISSION_PARAMS = json
	missionParams = json
	
func createSpawnAreas():
	for x in missionParams.deployment.keys():
		var zone = MeshInstance3D.new()
		var imm = BoxMesh.new()
		var mat = StandardMaterial3D.new()
		
		mat.albedo_color = Color(0,0,1,0.1)
		imm.set_size(Vector3(200,1,50))
		zone.mesh = imm
		imm.material = mat
		zone.transparency = 0.9
		zone.cast_shadow = false
		zone.global_position = calcZonePosition(x)
		zone.name = str(x) + "_deploy"
		zone.hide()
		add_child(zone)
	
func calcZonePosition(player: String, z : int = 200, x : int = 50):
	var mapz = mapSize[0]
	var mapx = mapSize[1]
	var pos = Vector3(0,0,0)
	pos.z = (mapx / 2) - (x / 2)
	if player == "player2":
		pos.z -= mapx - x
	pos.y = 10
	
	return pos
