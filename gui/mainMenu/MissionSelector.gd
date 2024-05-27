class_name MissionSelector
extends OptionButton

var missionsDirectory = "res://missions/"
# missions is { "missionName": [index(int), missionPath(str)] }
@export var missionsDict: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_item("Choose Mission", 0)
	set_item_disabled(0,true)
	add_separator()
	loadMissions()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func loadMissions():
	# get folders in missions directory
	var missions = DirAccess.get_directories_at(missionsDirectory)
	var json = JSON.new()
	# for each folder, load parameters.json and fetch name
	for x in missions.size():
		var path = missionsDirectory + missions[x]
		var paramsJson = path + "/parameters.json"
		if FileAccess.file_exists(paramsJson):
			# print("file exists: ", paramsJson)
			var params = FileAccess.get_file_as_string(paramsJson)
			var err = json.parse(params)
			if err == OK:
				# populate missions dict
				var data = json.data
				missionsDict = data
	
	# order missions alphabetically
	var missionsDictKeys = missionsDict.keys()
	missionsDictKeys.sort()
	
	# add to options
	for x in missionsDictKeys:
		add_item(x)
		
	return missionsDict


func _on_play_button_button_up() -> void:
	# hide main menu
	# display loading
	
	pass # Replace with function body.
