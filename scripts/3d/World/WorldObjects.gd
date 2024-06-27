## Handles placement of "objects" in the world. An object can be a house, 
## decorative features as a tractor, a big rock or whatever.[br]
## [br]
## Models, textures etc. is either found in res://resources/models/world/<type>/<name>/ or
## if player provided (custom scenarios etc.) in user://resources/mission/models/world/<type>/<name>/

class_name WorldObjects
extends Node

var missionParameters : Dictionary
@export var objects : Dictionary
@export var buildings : Array
@export var obstacles : Array
@export var water : Array
@export var roaming : Array

## [param objects] is a dictionary filled with types of objects and their locations
## as defined in world.json in the mission directory.
func _init(params : Dictionary, objects : Dictionary = {}):
	missionParameters = params
	if objects.is_empty():
		# look for a file or die
		objects = findWorldJson()
		if objects.is_empty():
			Log.fatal(self, "Could not find definitions of the world")
		else:
			prepareBuildings(objects['buildings'])

		
func findWorldJson():
	var paths = [
		"res://resources".path_join(missionParameters['path'].path_join("world.json")),
		"user://resources".path_join(missionParameters['path'].path_join("world.json")),
	]
	var worldObjects : Dictionary = {}
	var pathsChecked : String
	for path in paths:
		pathsChecked += "\n\t"+path
		if FileAccess.file_exists(path):
			worldObjects = JSON.parse_string(FileAccess.get_file_as_string(path))
	
	if worldObjects.is_empty():
		Log.error(self, "No world.json found when looking here: %s" % pathsChecked)

	return worldObjects


func prepareBuildings(buildings):
	for model in buildings:
		checkForModel(model)

func checkForModel(obj):
	var path = "res://resources/models/world/" + obj['model'] + "/" +  obj['model'] + ".glb"
	if FileAccess.file_exists(path):
		Log.debug(self, str("Looked for %s and found %s" % [name, path]))
		var model = load(path).instantiate()
		model.position = Vector3(obj['position'][0], 0, obj['position'][1])
		model.rotation = Vector3(0,obj['rotation'][1],0)
		buildings.append(model)
	else:
		Log.error(self, str("Looked for %s and found nothing! (path: %s)" % [obj, path]))
