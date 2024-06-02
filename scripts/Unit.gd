extends Node

@export var UnitScene: PackedScene
@export var UnitSoldier: PackedScene
@export var UnitMarker: PackedScene

var unitGroups = Selection.unitGroups
var missionUnits : Dictionary = MissionParameters.MISSION_UNITS

var UnitID : String = ""
var UnitType : String = ""
var Company : String = ""	# id of the company
var Platoon : String = ""	# id of the platoon
var Fireteam : String = ""	# id of fireteam if applicable
var Player : String
var currentPlayer = ""
var parent = ""
var currentDefinitions = ""

func add_child_to_scene(child, parent):
	# Assume that the scene is already loaded and running
	var main_scene = get_tree().root.get_node("main")
	
	# If MainScene is not at the root, adjust the path accordingly
	var parent_node = main_scene.get_node(parent)
	
	if parent_node:
		# Create a new child node (e.g., a Sprite)
		var new_child = Sprite2D.new()
		new_child.texture = preload("res://assets/sprites/ui/backgrounds/ww34.jpg")
		
		# Set properties for the new child if necessary
		new_child.position = Vector2(100, 100)
		
		# Add the new child to the parent node
		parent_node.add_child(child)
	else:
		print("Parent node not found!")

func load_and_instance_scene(scene_path: String):
	# Load the scene from the given path
	var scene_to_instance = load(scene_path)
	
	# Check if the resource loaded is a PackedScene
	if scene_to_instance is PackedScene:
		# Instance the scene
		scene_to_instance.instantiate()
		
		# Add the instance as a child of the current node
		#self.add_child(instance)
	else:
		# Print an error if the scene failed to load correctly
		print("Error: The resource at ", scene_path, " is not a valid scene.")

func unitCreation(params : Dictionary, parent : String):
	for i in params["players"]:
		# usually [player1, cpu] or [player1, player2]
		# insert player
		missionUnits[i] = {}
		currentPlayer = i
		for n in params[currentPlayer]:
			if not params[currentPlayer][n].has("definitions"):
				push_error("no definitions for ", currentPlayer, "(", n, ")!")
				break
			readDefinitions(params[currentPlayer][n]["definitions"])
			missionUnits[currentPlayer]["units"] = params[currentPlayer][n]["units"]
			for x in params[currentPlayer][n]["units"]:
				var unit = params[currentPlayer][n]["units"][x]
				var unitParent = ""
				if not unit.has("parent"):
					# mostly company HQs
					unitParent = ""
				else:
					unitParent = unit["parent"]
				# create unit
				add_child_to_scene(
					newUnit(
						unit["id"], 
						unitParent, 
						unit["unitType"],
						unit["name"], 
						currentPlayer
					),
					"units"
				)
			
func newUnit(id : String, parent : String, unitType : String, unitName : Array = [], _player : String = ""):
	print("createUnits got called with ID: ", id, " PARENT: ", parent, " UNITTYPE: ", unitType, " UNITNAME: ", unitName, " PLAYER: ", _player)
	# fetch definitions for unit
	var definition = getUnitDefinitions(unitType)
	
	##var defTest = currentDefinitions + "." + typePath
	#var definition = currentDefinitions["units"][typePath]
	##var definition = units.keys()
	##var definition = units[keys][typePath][type]
	
	## id : String
	## name : Array = ["A","B"]
	## type : String = ""
	## definition : Dictionary = {}
	## special : Dictionary = {}
	var myUnitScene = load_and_instance_scene("res://scenes/3d/unit/Units.tscn")
	##(id, unitName,"",{"count": 1})
	#var position = Vector3(1 + (unitsCreated * 10),10,100)
	#myUnit.look_at_from_position(position, Vector3(1,0,-100), Vector3(0, 1, 0), true)
	
	# var myUnit : PackedScene = UnitScene
	return myUnitScene

func getUnitDefinitions(unitType : String):
	# traverse definitions for unittype
	var unitDefinition : Dictionary
	var foundDefs = find_key_dict(currentDefinitions, unitType)
	
	if foundDefs:
		return foundDefs
	else:
		print("found no defs for ", unitType)
		return null

# Helper function to perform the recursive search for a key in a nested dictionary
func search_key(haystack: Dictionary, needle: String) -> Variant:
	for key in haystack.keys():
		if key == needle:
			return haystack[key]
		elif typeof(haystack[key]) == TYPE_DICTIONARY and key not in ["structure"]:
			var result = search_key(haystack[key], needle)
			if result != null:
				return result
	return null

# Main function to find the dictionary associated with a key in the nested dictionary
func find_key_dict(haystack: Dictionary, needle: String) -> Variant:
	return search_key(haystack, needle)

func findKeyInDictionary(needle, dictionary, keyPath = []):
	# dont go here
	var nogo = ["structure", "entities"]
	for n in dictionary:
		if n == needle:
			keyPath.push_back(n)
			return dictionary[n]
		elif not n in nogo:
			for nn in dictionary:
				if nn == needle:
					keyPath.push_back(n)
					return dictionary[nn]
				elif typeof(dictionary[nn]) == 27:
					findKeyInDictionary(needle, dictionary[nn])
		else:
			findKeyInDictionary(needle, dictionary[n])
			
	return keyPath
	
func shouldWeCreateUnit(type):
	currentDefinitions.find_key("type")

func readDefinitions(file):
	var data = JSON.parse_string(FileAccess.get_file_as_string("res://scripts/json/toe/" + file))
	currentDefinitions = data

func createUnit(id : String, name : Array, type : String, definition : Dictionary, player : String = "", special : Dictionary = {}):
	var newUnit = UnitScene.new()
	for i in definition["entities"]:
		addEntityToUnit(definition[type]["units"]["entities"][i], id)
	configureUnitMarker(id, name)
	self.add_to_group(id)
	unitGroups.append(id)
	# return self
	
func configureUnitMarker(id : String, text : Array):
	var UnitMarker = $UnitMarker/UnitMarkerSubviewPort/Control
	UnitMarker.get_node("Company").text = text[0]
	UnitMarker.get_node("Platoon").text = text[1]
	UnitMarker.add_to_group(id)

func addEntityToUnit(entities: int, groupid: String, model : String = "UnitSoldier"):
	var spawnCoords = Vector3.UP
	var unitcount = entities
	
	for x in unitcount:
		spawnCoords.y = 0
		spawnCoords.x = 1+randf_range(-3,3)
		spawnCoords.z = 1+randf_range(-3,3)
		
		var mySoldier = UnitSoldier.instantiate()
		mySoldier.name = "Soldier"+str(x+1)
		mySoldier.UNIT["unit"] = groupid
		mySoldier.position = spawnCoords
		mySoldier.add_to_group(groupid)
		mySoldier.add_to_group("Player1")
		if x < 1:
			mySoldier.UNIT["team"] = "0-1-A"
		# unit.initialize()
		add_child(mySoldier)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
