extends Node3D 

@export var Unit: PackedScene

var missionpath : String = "res://missions/basicmission/" # missionpath as reported by MainMenu
# var missionSelector = "res://gui/mainMenu/MissionSelector.gd" # debug
var missionSelector = MissionSelector.new() # .get_node("MainMenu") # debug
var missionparams = missionSelector.loadMissions()
var mapSize = [0,0] # [z, x]
 #debug variables
var unitsCreated = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# load params
	#missionparams = $MissionSelector.missionsDict
	processParams()
	# load map
	# place objects (houses, roads, vegetation etc)
	# create spawn areas
	# createSpawnAreas()
	# create units
	add_child(createUnits("rifle-platoon-1-hq", ["A","A-HQ"]))
	add_child(createUnits("rifle-platoon-1-squad-1", ["A","A-A"]))
	add_child(createUnits("rifle-platoon-1-squad-2", ["A","A-B"]))
	add_child(createUnits("rifle-platoon-1-squad-3", ["A","A-C"]))
	# place units
	print(get_groups())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Node2D/fps.text = "FPS " + str(Engine.get_frames_per_second())
	pass
	
func executeTurn():
	# execute turn
		# process each "order" async
		# timer 60s
	pass

func processParams(extra : String = ""): # as a json-formatted string 
	mapSize = missionparams.size
	print(mapSize)
	pass
	
func createSpawnAreas():
	for x in missionparams.deployment.keys():
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
	
func createUnits(id : String = "", unitName : Array = ["A", "B"], _player : int = 1):
	unitsCreated += 1
	var myUnit = Unit.instantiate()
	# TODO: for each in parameters.json -> player1 -> etcetc
	myUnit.createUnit(id, unitName,"",{"count": 1})
	var position = Vector3(1 + (unitsCreated * 10),10,100)
	myUnit.look_at_from_position(position, Vector3(1,0,-100), Vector3(0, 1, 0), true)
	
	return myUnit
