extends Node3D 

var _parametersPath = ""
var _missionUnitsPath = ""
var _typePath = ""

var missionpath : String = "res://resources/missions/basicmission/" # missionpath as reported by MainMenu
# var missionSelector = "res://gui/mainMenu/MissionSelector.gd" # debug
var missionSelector = MissionSelector.new() # .get_node("MainMenu") # debug
# var missionparams = missionSelector.loadMissions()
var missionParams = {}
var mapSize := []
var _player : int = 0

 #debug variables
var unitEntityCount := {"units": 0, "entities": 0}
var unitsCreated = 0
var missionUnits : Dictionary = {}
var definitions = ""
var currentDefinitions = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	## signals
	PubSub.executeTurn.connect(executeTurn)
	# load params
	#missionparams = $MissionSelector.missionsDict
	processParams(JSON.parse_string(FileAccess.get_file_as_string(missionpath + "parameters.json")))
	#self.position.z = mapSize[0] / 2
	#self.position.x = mapSize[1] / 2
	self.global_position = Vector3(mapSize[1] / 2,0,mapSize[0] / 2)
	# load map
	# place objects (houses, roads, vegetation etc)
	# create spawn areas
	createSpawnAreas()
	# create & place units
	Unit.unitCreation(missionParams, "")
	# removeSpawnAreas
	get_node("player1_deploy").free()
	get_node("player2_deploy").free()
	unitEntityCount = getNumUnitsInScene()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Node2D/Control/VBoxContainer/fps.text = str("FPS: ", "%.0f" % (1.0 / delta))
	$Node2D/Control/VBoxContainer/unitsInScene.text = str("Units in scene ", "%.0f" % (unitEntityCount.units), ", entities ", "%.0f" % (unitEntityCount.entities))
	$Node2D/Control/VBoxContainer/mode.text = str("Mode ", "%s" % (Mode.MODE))
	#Debug.log("Selected units: ", getSelectedUnits())
	pass
	
func getNumUnitsInScene() -> Dictionary:
	var unitCount = 0
	var entityCount = 0
	var units = get_node("Units").get_children(true)
	for i in units:
		unitCount += 1
		var unitChildren = i.get_children()
		for n in unitChildren:
			if n.is_class("CharacterBody3D"):
				entityCount += 1
		
	return {"units": unitCount, "entities": entityCount}
	
func executeTurn():
	prints("Turn executing!")
	# execute turn
		# process each "order" async
		# timer 60s
	pass

func processParams(json, extra : String = ""): # as a json-formatted string 
	MissionParameters.MISSION_PARAMS = json
	missionParams = json
	mapSize = MissionParameters.MISSION_PARAMS.size
	
func createSpawnAreas():
	var n = 0
	for x in missionParams.deployment.keys():
		var zone = MeshInstance3D.new()
		var imm = BoxMesh.new()
		var mat = StandardMaterial3D.new()
		
		if n == 0: 
			mat.albedo_color = Color(0,0,1,0.1)
			n += 1
		else: 
			mat.albedo_color = Color(1,0,0,0.1)
		imm.set_size(Vector3(200,1,50))
		zone.mesh = imm
		imm.material = mat
		zone.transparency = 0.9
		zone.cast_shadow = false
		zone.position = calcZonePosition(x)
		zone.name = str(x) + "_deploy"
		zone.hide()
		add_child(zone)
	
func calcZonePosition(player: String, z : int = 200, x : int = 50):
	var mapz = mapSize[0]
	var mapx = mapSize[1]
	
	# position utgår från mitten. x kan alltid vara 0 om zonen ska vara i mitten
	# är kartan 250x250 så är pos.z + 25
	var pos = Vector3(0,0,0)
	
	pos.y = 10
	pos.z = (mapz / 2) - (x / 2)
	if player == "player2":
		pos.z -= mapx - x
	
	return pos

func _on_ground_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and Input.get_mouse_button_mask() == 1:
		if Mode.MODE == 0:
			Selection.unselect()
