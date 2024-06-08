# Unit as an entity on the battle map
class_name UnitEntity
extends Node3D

var unitEntityScene: PackedScene = load("res://scenes/3d/unit/Unit.tscn")

@onready var _unitMarker = $UnitMarker/SubViewport/Control

@export var SELECTED : bool = false
@export var UNITID : String = ""
@export var UNITTYPE : String = ""
@export var COMPANY : String = ""	# id of the company
@export var PLATOON : String = ""	# id of the platoon
@export var SQUAD : String = ""		# id of squad
@export var PLAYER : String = ""
@export var UNITEQUIPMENT : Dictionary = {
	"radio" : false,
}
@export var UNITORDERS : Array = [
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
	if Platoon.length() > 0:
		add_to_group("platoon-"+PLATOON)
	if Squad.length() > 0:
		add_to_group("squad"+SQUAD)
	
	return self

func _ready():
	await getEntityPositions()

func executeTurn():
	pass

## Conforms the unit "container" to encompass all it's entities
func conformToEntities():
	pass

func findInVector3Array(needle : float, haystack : Array, dimension = null):
	for n in haystack:
		if dimension != null:
			if n[dimension] == needle:
				return n
		else:
			if n.x == needle:
				return n
			if n.y == needle:
				return n
			if n.z == needle:
				return n

func getEntityPositions():
	var entitiesXYZ := []
	var entitiesX := []
	var entitiesZ := []
	var entities = get_children().filter(
		func(unit):
			return unit.get_class() == "CharacterBody3D"
	)
	
	for n : CharacterBody3D in entities:
		await PubSub.onFloor
		var position = n.position
		entitiesXYZ.append(n.position)
		entitiesX.append(n.position.x)
		entitiesZ.append(n.position.z)
		
	var middle = Vector3.ZERO
	middle.x = (V3Helper.sortV3Array(entitiesXYZ, 1, 1).x - V3Helper.sortV3Array(entitiesXYZ, 2, 1).x) / 2
	middle.y = -7
	middle.z = (V3Helper.sortV3Array(entitiesXYZ, 5, 1).z - V3Helper.sortV3Array(entitiesXYZ, 6, 1).z) / 2
	var middleNode = get_node("Middle")
	middleNode.position = middle

func _toggleSelected() -> void:
	if SELECTED == false:
		SELECTED = true
		_unitMarker.get_node("Unselected").hide()
		_unitMarker.get_node("Selected").show()
		ordersVisibility(1)
	else:
		SELECTED = false
		_unitMarker.get_node("Selected").hide()
		_unitMarker.get_node("Unselected").show()
		ordersVisibility(0)

func selectUnit() -> void:
	SELECTED = true
	_unitMarker.get_node("Unselected").hide()
	_unitMarker.get_node("Selected").show()
	ordersVisibility(1)
	
func unSelectUnit() -> void:
	SELECTED = false
	_unitMarker.get_node("Unselected").show()
	_unitMarker.get_node("Selected").hide()
	ordersVisibility(0)

func ordersVisibility(state : int):
	#pass
	var orders = self.get_node("Orders")
	if orders != null and orders.get_child_count():
		var children = orders.get_children()
		if state == 0:
			for n in children:
				n.hide()
		else:
			for n in children:
				n.show()
