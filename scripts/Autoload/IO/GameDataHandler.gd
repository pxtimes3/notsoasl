extends Node

# const gameDataPath = "user://gamedata/notsoasl/tmp" ## TODO: Probably a different path for every platform?
const gameDataPath = "res://usr/tmp/"  ## for debug TODO: Dont forget to remove this!
var uid = OS.get_unique_id()
var gameDataFileName = uid + "-" + str(Time.get_unix_time_from_system() * 1000) + ".json"
var gameDataFile : FileAccess

func _ready():
	purgeTempFiles()

func createGameDataFile(filename : String = gameDataFileName):
	var file = FileAccess.open(gameDataPath + filename, FileAccess.WRITE)
	if not FileAccess.file_exists(gameDataPath + filename):
		Log.fatal(self, "CreateGameDataFile could not be found!")
		return false
	
	gameDataFile = file


func writeToGameDataFile(data : String):
	if not gameDataFile:
		createGameDataFile()
	gameDataFile.store_string(data)
	
	
	
## Removes any temporary files in user://gamedata/notsoasl/tmp
func purgeTempFiles():
	# var path = "user://gamedata/notsoasl/tmp"
	var path = "res://usr/tmp/" ## for debug TODO: Dont forget to remove this!
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.begins_with(uid) \
			and file_name.ends_with("json"):
				Log.debug(self, "Found: " + file_name)
				dir.remove(file_name)
			
			file_name = dir.get_next()
