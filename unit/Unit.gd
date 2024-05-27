extends Node3D

@export var UnitSoldier: PackedScene
@export var UnitMarker: PackedScene

#var unitScene = Node3D.new()
var UnitID : String = ""
var UnitType : String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## 
## @param Id: String with an ID for the unit in the format n1-n2-n3-n4...
##            n1 = player, n2 = company, n3 = platoon, n4 = squad
##            HQ units are always 1, first non-hq 2 etc.
## @param type: String-ID of the type of unit
##              "usarmyriflecompany-riflecompany-platoon-riflesquad" or 
## 				"usarmyriflecompany-wpnsplatoon-lmgsection"
##              Definitions in usarmy.json
## @param special: Dictionary for special instructions. "count": 1 creates only
## one of the last unit in type.
##
## @return One UnitScene containing x Entities.
## 
func createUnit(id : String, name : Array = ["A","B"], type : String = "", special : Dictionary = {}):
	# unitScene.new()
	# p1, 1st co, 1st rifle platoon, 1st squad
	# id = "1-1-2-2"
	# this creates only riflemen
	type = "usarmyriflecompany-riflecompany-platoon-riflesquad-rifleman"
	special = {"count": 8}
	if special.has("count"):
		var count = special.count
		addEntityToUnit(12, id)
	configureUnitMarker(id, name)
	return self
	
func configureUnitMarker(id : String, text : Array):
	$Unitmarker/SubViewport/Control/Company.text = text[0]
	$Unitmarker/SubViewport/Control/Platoon.text = text[1]
	$Unitmarker/SubViewport/Control.add_to_group(id)

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
