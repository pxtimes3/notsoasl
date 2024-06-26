extends Node

var UnitScene: PackedScene
var UnitSoldier: PackedScene = load("res://scenes/3d/unit/soldier/UnitSoldier.tscn")
var UnitMarker: PackedScene

var unitGroups = Selection.unitGroups
var missionUnits : Dictionary = MissionParameters.MISSION_UNITS
var playerUnits = {}

var currentPlayer = ""
var parent = ""
var currentDefinitions = ""

func add_child_to_scene(child, nodeParent):
	# Assume that the scene is already loaded and running
	var main_scene = get_tree().root.get_node("main")
	
	# If MainScene is not at the root, adjust the path accordingly
	var parent_node = main_scene.get_node(nodeParent)
	
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
		var myScene = scene_to_instance.instantiate()
		
		# Add to Units node
		var unitsNode = get_tree().root.get_node("main/Units")
		unitsNode.add_child(myScene)
		return myScene
	else:
		# Print an error if the scene failed to load correctly
		print("Error: The resource at ", scene_path, " is not a valid scene.")

func unitCreation(params : Dictionary):
	for i in params["players"]:
		# usually [player1, cpu] or [player1, player2]
		# insert player
		missionUnits[i] = {}
		currentPlayer = i
		for n in params[currentPlayer]:
			if not params[currentPlayer][n].has("definitions"):
				Log.error(self, "no definitions for " + currentPlayer + "(" + str(n) + ")!")
				
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
func newUnit(id : String, _unitParent : String, unitType : String, _player : String, unitName : Array = []):
	# fetch definitions for unit
	var definition = getUnitDefinitions(unitType)
	# set special equipment (radio etc. for the unit)
	var unitVars = {
		"unitEquipment": {
			"radio": false,
		}
	}
	var unitCompany = unitName[0]
	var unitPlatoon = unitName[1]
	var unitSquad   = unitName[2]
	var myUnitEntity = load("res://scenes/3d/unit/Unit.tscn")

	if definition.has("radio"):
		unitVars.unitEquipment.radio = definition["radio"]
	
	myUnitEntity = myUnitEntity.instantiate()
	myUnitEntity = myUnitEntity.createUnitEntity(id, unitType, unitCompany, unitPlatoon, unitSquad, _player, unitVars.unitEquipment)
	
	myUnitEntity.add_to_group(_player)
	myUnitEntity.add_to_group("company-" + unitCompany)
	myUnitEntity.add_to_group("platoon-" + unitPlatoon)
	myUnitEntity.add_to_group("squad-" + unitSquad)
	
	# add entities to myUnitEntity
	addEntitiesToUnit(myUnitEntity, definition.entities)

	# position unit
	myUnitEntity.position = calculateSpawnPoint(myUnitEntity, _player)
	myUnitEntity.look_at_from_position(myUnitEntity.position, Vector3(1,0,-100), Vector3(0, 1, 0), true)
	
	unitsCreated += 1
	return myUnitEntity

var spawnCoords = Vector3.UP
var spawnX = 0
var spawnZ = 0
var soldierCount = 0

func calculateSpawnPoint(_unit : UnitEntity, player : String) -> Vector3:
	var _currentPlayer = player
	var deploymentZone = get_node("/root/main/" + player + "_deploy")
	
	var aabb = deploymentZone.get_aabb() # xyz, whd
	var unitSpawnX = aabb.get_endpoint(1)[0] + 5 + (unitsCreated * 10)
	var unitSpawnZ = aabb.get_endpoint(1)[2] + 50

	var position = Vector3(unitSpawnX,10,unitSpawnZ)
	
	return position

func getUnitDefinitions(unitType : String):
	# traverse definitions for unittype
	# var unitDefinition : Dictionary
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
	
#func shouldWeCreateUnit(type):
#	currentDefinitions.find_key("type")

func readDefinitions(file):
	if file:
		var string = FileAccess.get_file_as_string("res://scripts/json/toe/" + file)
		var data = JSON.parse_string(string)
		currentDefinitions = data
	else:
		Log.error(self, "@param file was empty!")

#func createUnit(id : String, name : Array, type : String, definition : Dictionary, player : String = "", special : Dictionary = {}):
	#var newUnit = UnitScene.new()
	#for i in definition["entities"]:
		#addEntityToUnit(definition[type]["units"]["entities"][i], id)
	#
	#self.add_to_group(id)
	#unitGroups.append(id)
	# return self
	

func addEntitiesToUnit(unitScene : UnitEntity, definitions : Dictionary) -> UnitEntity:
	var count := 0
	for i in definitions:
		createAndAddEntity(unitScene, currentDefinitions["entities"][i], definitions[i], count)
		#soldierCount += 1
	spawnX = 0
	spawnZ = 0
	return unitScene
	
#func configureUnitMarker(id : String, text : Array):
#	return get_node("res://scenes/3d/unit/UnitMarker.tscn")
	#print(self.get_children())
	#UnitMarker.get_node("Company").text = text[0]
	#UnitMarker.get_node("Platoon").text = text[1]
	#UnitMarker.add_to_group(id)


## creates a unit_soldier and adds it to myUnitEntity
func createAndAddEntity(unitScene : UnitEntity, entityVars : Dictionary, num : int = 1, _count : int = 0) -> void:
	spawnCoords = Vector3.UP
	
	#var entityModel = load("res://scenes/3d/unit/soldier/UnitSoldier.tscn").duplicate()
	#if entityVars.has("model"):
		#entityModel = load(entityVars.model) # well it's a scene, but you know...
	
	for x in num:
		if spawnX > 6:
			spawnZ = spawnZ - 2
			spawnX = 0
			
		spawnCoords.x = spawnX + randf_range(-0.5,0.5)
		spawnCoords.z = spawnZ + randf_range(-0.5,0.5)
		
		var mySoldier = UnitSoldier.instantiate()
		
		mySoldier.COMPANY = unitScene.COMPANY	# id of the company
		mySoldier.PLATOON = unitScene.PLATOON	# id of the platoon
		mySoldier.SQUAD = unitScene.SQUAD	# id of fireteam if applicable
		mySoldier.PLAYER = unitScene.PLAYER
		mySoldier.ID = "soldier"+str(soldierCount)
		mySoldier.EQUIPMENT = entityVars
		
		mySoldier.add_to_group(unitScene.PLAYER)
		mySoldier.add_to_group("company-" + unitScene.COMPANY)
		mySoldier.add_to_group("platoon-" + unitScene.PLATOON)
		mySoldier.add_to_group("squad-" + unitScene.SQUAD)
		
		mySoldier.position = spawnCoords
		
		unitScene.add_child(mySoldier)
		soldierCount += 1
		spawnX += 2

func addEntityToUnit(entities: int, groupid: String, _model : String = "UnitSoldier"):
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
func _process(_delta: float) -> void:
	pass
