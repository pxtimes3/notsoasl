# Unit as an entity on the battle map
class_name UnitEntity
extends Node3D

var unitEntityScene: PackedScene = load("res://scenes/3d/unit/Unit.tscn")
var unitMarkerScene : PackedScene = load("res://scenes/3d/unit/UnitMarker.tscn")

var UNITID : String = ""
var UNITTYPE : String = ""
var COMPANY : String = ""	# id of the company
var PLATOON : String = ""	# id of the platoon
var SQUAD : String = ""		# id of squad
var PLAYER : String = ""
var UNITEQUIPMENT : Dictionary = {
	"radio" : false,
}
var UNITORDERS : Array = [
	## Acts as a stack in order to put unit-initiated actions on top.
	## Once consumed the first order is popped off the top of the array.
	## Consumation of the order happens when all entities have arrived in the 
	## waypoints area of influence or something happens that erases the queue
	## such as destruction of the unit, overwhelming fire, rout etc.
	##
	## {"patrol" : [start Vector3, end Vector3]},
	## {"patrol" : "pos Vector3"}
]

func createUnitEntity(UnitID:String, UnitType:String, Company:String, Platoon:String, Squad:String, Player: String, UnitEquipment:Dictionary) -> UnitEntity:
	# var new_unitEntity = unitEntityScene.instantiate()
	self.UNITID = UnitID
	self.UNITTYPE = UnitType
	self.COMPANY = Company
	self.PLATOON = Platoon
	self.SQUAD = Squad
	self.PLAYER = Player
	self.UNITEQUIPMENT = UnitEquipment
	
	add_to_group("unit-"+UNITID)
	add_to_group("company-"+COMPANY)
	add_to_group("platoon-"+PLATOON)
	add_to_group("squad"+SQUAD)
	
	return self

func _ready():
	pass
