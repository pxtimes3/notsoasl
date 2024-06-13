# Unit as an entity on the battle map
class_name UnitEntity
extends Node3D

var unitEntityScene: PackedScene = load("res://scenes/3d/unit/Unit.tscn")

@onready var _unitMarker = $UnitMarker/SubViewport/Control
@export var unitMiddle = Vector3.UP
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
	unitMiddle = await getUnitMiddle()
	$UnitMarker.position.x = unitMiddle.x
	$UnitMarker.position.z = unitMiddle.y
	
func _process(delta):
	pass
	
func executeTurn():
	pass

## @deprecated
## Conforms the unit "container" to encompass all it's entities
func conformToEntities():
	pass
	
	
func forwardOrderToEntities(order : Array) -> void:
	var entities = get_children().filter(func(unit): return unit.get_class() == "CharacterBody3D")
	for n in entities:
		n.recieveOrder(order)

var previousZ
func getUnitMiddle():
	var entitiesXYZ := []
	var entitiesXZ := []
	var entitiesX := []
	var entitiesZ := []
	var entities = get_children().filter(func(unit): return unit.get_class() == "CharacterBody3D")
	
	for n : CharacterBody3D in entities:
		await PubSub.onFloor
		entitiesXZ.append(Vector2(n.position.x, n.position.z))

	return V3Helper.compute2DPolygonCentroid(entitiesXZ)
	

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
