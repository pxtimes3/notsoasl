extends Node

var UnitScene: PackedScene
var UnitSoldier: PackedScene
var UnitMarker: PackedScene

var unitGroups = Selection.unitGroups
var missionUnits : Dictionary = MissionParameters.MISSION_UNITS
var playerUnits = {}

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

func load_and_instance_scene(scene_path: String, vars: Dictionary):
	# Load the scene from the given path
	var scene_to_instance = load(scene_path)
	
	# Check if the resource loaded is a PackedScene
	if scene_to_instance is PackedScene:
		# Instance the scene
		var myScene = scene_to_instance.instantiate()
		
		# Add to Units node
		var unitsNode = get_tree().root.get_node("main/Units")
		unitsNode.add_child(myScene)
		return myScene
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
				var myUnit = newUnit(unit["id"], unitParent, unit["unitType"], currentPlayer, unit["name"])
				add_child_to_scene(myUnit,"Units")

var unitsCreated = 0
func newUnit(id : String, parent : String, unitType : String, _player : String, unitName : Array = []):
	# print("createUnits got called with ID: ", id, " PARENT: ", parent, " UNITTYPE: ", unitType, " UNITNAME: ", unitName, " PLAYER: ", _player)
	# fetch definitions for unit
	var definition = getUnitDefinitions(unitType)
	# set special equipment (radio etc. for the unit)
	# TODO: refactor this
	var unitVars = {
		"unitEquipment": {
			"radio": false,
		}
	}
	if definition.has("radio"):
		unitVars.unitEquipment.radio = definition["radio"]
	
	#var myUnitEntity = UnitEntity.new()
	var myUnitEntity = load("res://scenes/3d/unit/Unit.tscn")
	myUnitEntity = myUnitEntity.instantiate()
	myUnitEntity = myUnitEntity.createUnitEntity(id,unitType,unitName[0], unitName[1], "", _player, unitVars.unitEquipment)
	
	myUnitEntity.add_to_group(_player)
	
	# add entities to myUnitEntity
	addEntitiesToUnit(myUnitEntity, definition.entities)
	
	# set unitmarker labels
	myUnitEntity.get_node("UnitMarker/SubViewport/Control/Company").text = unitName[0]
	myUnitEntity.get_node("UnitMarker/SubViewport/Control/Platoon").text = unitName[1]

	# position unit
	myUnitEntity.global_position = calculateSpawnPoint(myUnitEntity, _player)
	myUnitEntity.look_at_from_position(myUnitEntity.position, Vector3(1,0,-100), Vector3(0, 1, 0), true)
	
	unitsCreated += 1
	return myUnitEntity

func calculateSpawnPoint(unit : UnitEntity, player : String) -> Vector3:
	var currentPlayer = player
	var deploymentZone = get_node("/root/main/" + player + "_deploy")
	
	# TODO: Refactor this mess!
	# TODO: Check if unit is outside deployment zone
	# TODO: Check how this fails for player2
	
	var aabb = deploymentZone.get_aabb() # xyz, whd
	var spawnX = aabb.get_endpoint(1)[0] + 5 + (unitsCreated * 10)
	var spawnZ = aabb.get_endpoint(1)[2] + 50

	var position = Vector3(spawnX,10,spawnZ)
	
	return position

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

#func createUnit(id : String, name : Array, type : String, definition : Dictionary, player : String = "", special : Dictionary = {}):
	#var newUnit = UnitScene.new()
	#for i in definition["entities"]:
		#addEntityToUnit(definition[type]["units"]["entities"][i], id)
	#
	#self.add_to_group(id)
	#unitGroups.append(id)
	# return self
	
var spawnCoords = Vector3.UP
var spawnX = 0
var spawnZ = 0
var soldierCount = 0
func addEntitiesToUnit(unitScene : UnitEntity, definitions : Dictionary) -> UnitEntity:
	var unitType = unitScene.UnitType
	var count := 0
	var num := 0
	for i in definitions:
		createAndAddEntity(unitScene, currentDefinitions["entities"][i], definitions[i], count)
		#soldierCount += 1
	spawnX = 0
	spawnZ = 0
	return unitScene
	
func configureUnitMarker(id : String, text : Array):
	return get_node("res://scenes/3d/unit/UnitMarker.tscn")
	#print(self.get_children())
	#UnitMarker.get_node("Company").text = text[0]
	#UnitMarker.get_node("Platoon").text = text[1]
	#UnitMarker.add_to_group(id)


## creates a unit_soldier and adds it to myUnitEntity
func createAndAddEntity(unitScene : UnitEntity, entityVars : Dictionary, num : int = 1, count : int = 0) -> void:
	spawnCoords = Vector3.UP
	
	var entityModel = load("res://scenes/3d/unit/soldier/unit_soldier.tscn")
	if entityVars.has("model"):
		entityModel = load(entityVars.model) # well it's a scene, but you know...
	
	for x in num:
		if spawnX > 6:
			spawnZ = spawnZ - 2
			spawnX = 0
			
		spawnCoords.x = spawnX + randf_range(-0.5,0.5)
		spawnCoords.z = spawnZ + randf_range(-0.5,0.5)
		
		var mySoldier = entityModel.instantiate()
		mySoldier.ID = "Soldier"+str(soldierCount)
		mySoldier.UNIT["unit"] = unitScene.UnitID
		mySoldier.global_position = spawnCoords
		mySoldier.add_to_group(currentPlayer)
		if x < 1:
			mySoldier.UNIT["team"] = "0-1-A"
		# print("Adding soldier at X: ", spawnX, " Z: ", spawnZ)
		unitScene.add_child(mySoldier)
		soldierCount += 1
		spawnX += 2

func addEntityToUnit(entities: int, groupid: String, model : String = "UnitSoldier"):
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
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
