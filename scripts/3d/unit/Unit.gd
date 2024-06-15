# Unit as an entity on the battle map
class_name UnitEntity
extends Node3D

#signal input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3)
#signal PubSub.input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3)
signal mouse_entered()
signal mouse_exited()

var unitEntityScene: PackedScene = load("res://scenes/3d/unit/Unit.tscn")

var unitIcon = preload("res://assets/sprites/ui/unit/icon-ak47-48x48.svg")
var unitIconSelected = preload("res://assets/sprites/ui/unit/icon-ak47-48x48-selected.svg")

var mouse_over := false
var centroid = Centroid.new()
var _mouse_input_received := false

@onready var _unitMarker = $UnitMarker2D
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


func _ready():
	PubSub.unit_input_event.connect(try_mouse_input.bind(self))
	PubSub.executeTurn.connect(turnPlayStart.bind())
	PubSub.turnPlayStart.connect(turnPlayStart.bind())
	PubSub.turnPlayEnd.connect(turnPlayEnd.bind())
	var camera = get_viewport().get_camera_3d()
	if camera.has_signal("mouse_ray_processed"):
		camera.mouse_ray_processed.connect(_on_3d_mouse_ray_processed)
	
func _process(_delta):
	if Engine.get_process_frames() % 300 == 0:
		var repCenter = centroid.calculate_centroid(getUnitEntityPositions())
		$UnitMarkerAnchor.position.x = repCenter.x
		$UnitMarkerAnchor.position.z = repCenter.y


func yell(message):
	prints(message)

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

func getUnitEntityPositions() -> Array:
	var entitiesXZ := []
	var entities = get_children().filter(func(unit): return unit.get_class() == "CharacterBody3D")
	
	for n : CharacterBody3D in entities:
		entitiesXZ.append(Vector2(n.position.x, n.position.z))

	return entitiesXZ
	

func selectUnit() -> void:
	SELECTED = true
	_unitMarker.set_texture(unitIconSelected)
	get_tree().call_group("squad-" + self.SQUAD, "outline", 1)
	ordersVisibility(1)
	
	
func unSelectUnit() -> void:
	SELECTED = false
	_unitMarker.set_texture(unitIcon)
	get_tree().call_group("squad-" + self.SQUAD, "outline", 0)
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



func try_mouse_input(caller: Node, _camera: Node, event: InputEvent, _input_position: Vector3, _normal: Vector3) -> bool:
	prints(caller)
	if event.button_mask != 0:
		## we got a click
		if event.button_mask == 1:
			## left click
			_mouse_input_received = true
			PubSub.unit_input_left_click.emit(self, event)
		elif event.button_mask == 2:
			## right click
			_mouse_input_received = true
			PubSub.unit_input_right_click.emit(self, event)

	return false

func _on_3d_mouse_ray_processed() -> void:

	# Received Input

	if _mouse_input_received:

		# Mouse Entered Case

		if !mouse_over:
			mouse_over = true
			mouse_entered.emit()
	
	# Mouse Exited Case

	elif mouse_over:
		mouse_over = false
		mouse_exited.emit()
	
	_mouse_input_received = false


################
## EXECUTE TURN!
################

func turnPlayStart() -> void:
	# record start position, orders, unit entities, alive/destroyed
	pass
	
	
func turnPlayEnd() -> void:
	pass
