extends Node3D 

@export var speed = 1

@export var missionpath : String = "res://resources/missions/basicmission/" # missionpath as reported by MainMenu
# var missionSelector = "res://gui/mainMenu/MissionSelector.gd" # debug
@export var missionSelector = MissionSelector.new() # .get_node("MainMenu") # debug
# var missionparams = missionSelector.loadMissions()
@export var missionParams = {}
@export var mapSize := []

@onready var currentStateControl = get_node("Control")
@onready var currentStateNode    = get_node("Control/Y/SubViewport/X/SubViewport/CurrentState")

 #debug variables
var unitEntityCount := {"units": 0, "entities": 0}
var unitsCreated = 0
var missionUnits : Dictionary = {}
var definitions = ""
var currentDefinitions = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	var start = Time.get_ticks_msec()
	# subscribe to signals
	PubSub.executeTurn.connect(executeTurn.bind())
	PubSub.turnPlayStart.connect(playTurnStart.bind())
	# load params
	#missionparams = $MissionSelector.missionsDict
	processParams(JSON.parse_string(FileAccess.get_file_as_string(missionpath + "parameters.json")))
	Log.info(self, "Processing mission parameters " + str(Time.get_ticks_msec() - start))
	
	# save params to usr://tmp/epoch-missionname
	saveUsrGameData()
	Log.info(self, "Saved user gamedata " + str(Time.get_ticks_msec() - start))
	# self.global_position = Vector3(mapSize[1] / 2,0,mapSize[0] / 2)
	Log.info(self, "Creating world " + str(Time.get_ticks_msec() - start))
	var world = GameWorld.new(missionParams)
	if world:
		add_child(world)
		world.bakeNavigationmesh(world)
	# load map
	# place objects (houses, roads, vegetation etc)
	# create spawn areas
	# createSpawnAreas()
	Log.info(self, "Placing start areas " + str(Time.get_ticks_msec() - start))
	# create & place units
	# Unit.unitCreation(missionParams)
	Log.info(self, "Adding units " + str(Time.get_ticks_msec() - start))
	# removeSpawnAreas
	#get_node("player1_deploy").free()
	# get_node("player2_deploy").free()
	# unitEntityCount = getNumUnitsInScene()
	PubSub.game_loaded.emit()
	Log.info(self, "Done! " + str(Time.get_ticks_msec() - start) + " msec")
	Log.info(self, "------------")

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Node2D/Control/VBoxContainer/fps.text = str("FPS: ", "%.0f" % (1.0 / delta))
	$Node2D/Control/VBoxContainer/unitsInScene.text = str("Units in scene ", "%.0f" % (unitEntityCount.units), ", entities ", "%.0f" % (unitEntityCount.entities))
	$Node2D/Control/VBoxContainer/mode.text = str("Mode: ", "%s" % (Mode.MODE), " Speed: ", "%s" % (getTurnSpeed()))
	#Debug.log("Selected units: ", getSelectedUnits())
	pass
	
	
func saveUsrGameData() -> void:
	var data = JSON.stringify({
		"missionParams": missionParams,
		"units": {
			"player1": {},
			"player2": {}
		}
	}, "\t")
	
	GameDataHandler.writeToGameDataFile(data)
	
	
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
	
	
## Main conductor of the turn execution and replay.
func executeTurn():
	prints("Turn executing!")
	# take screenshot and then process all orders
	screenShotCurrentViewport()
	# if await processTurn():
	await processTurn()
	# reset to start positions
	prints("Resetting entities in order to play turn for player")
	currentStateControl.hide()
	# set progressbar to 0
	var progressBar = $Control/TurnCalcProgressModal/ProgressBar
	progressBar.set_value_no_signal(0)
	
	# start turn replay
	playTurnStart()
		
## Emits the start of the replay.
func playTurnStart() -> void:
	prints("main.gd PubSub.turnPlaying.emit()")
	PubSub.turnPlayStart.emit()
	PubSub.turnPlaying.emit()
	
## Emits the end of the replay.
func playTurnEnd() -> void:
	prints("main.gd PubSub.turnPlayEnd.emit()")
	PubSub.turnPlayEnd.emit()

## Processes the turn events before replaying them for the player.[br]
## Increases turn speed to 100 in order to speed things up. :P [br]
## [br]
func processTurn() -> bool:
	# increase speed 
	setTurnSpeed(1) # set this to a reasonable value
	# do everything and "record it" to log.
	var progressBar = $Control/TurnCalcProgressModal/ProgressBar
	progressBar.value = 100
	await get_tree().create_timer(0.3).timeout
	# set normal speed
	setTurnSpeed()
	return true

## Sets the speed of how fast events happen in a turn.[br][br]
## [paran val] = [int] Default: 1
func setTurnSpeed(val : int = 1) -> void:
	prints("Turnspeed changed to:", val)
	speed = val
	
## Returns current turn speed.
func getTurnSpeed() -> int:
	return speed


func screenShotCurrentViewport() -> void:
	await RenderingServer.frame_post_draw

	# Retrieve the captured image.
	var img = get_viewport().get_texture().get_image()
	img.save_png("res://screencapture.png")

	var imgtex = ImageTexture.create_from_image(img)
	currentStateNode.texture = imgtex
	currentStateControl.show()
	#currentStateNode.mouse_filter = 0

func processParams(json): 
	MissionParameters.MISSION_PARAMS = json
	missionParams = json
	mapSize = MissionParameters.MISSION_PARAMS.size
	



###################################################################################################
##     RAYCASTING
###################################################################################################
