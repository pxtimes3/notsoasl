extends CharacterBody3D

@export var fall_acceleration = 75000

@export var ENTITY_STATUS = ""

var _mouse_input_received := false
var target_velocity = Vector3.ZERO

var PLAYER: String # player controllable
var SELECTED: bool = false
var ID: String;
var COMPANY: String = "" # A, B, C ...
var PLATOON: String = "" # A-A, A-B, A-C ...
var SQUAD: String = "" # A, B, C ...
var NPC: bool = false # npc/civilian
var MORALE: int = 100 # green = 50, conscript = 70, veteran = 100, elite = 120
var FATIGUE: int = 100 # 0 = exhausted TODO: regen?
var HEALTH: int = 3 # 0 dead, 1 injured, 2 wounded, 3 healthy
var EQUIPMENT: Dictionary = {}
@export var ORDERS : Array = []


func _ready():
	PubSub.turnPlayStart.connect(turnStarted)
	
	PubSub.turnPlaying.connect(turnManager.bind([
		
	]))
	
	PubSub.turnPlayEnd.connect(turnEnded)


func _process(_delta: float) -> void:
	pass


func turnManager(args : Array = []):
	pass


func _physics_process(delta: float) -> void:
	#var direction = Vector3.ZERO
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	else: 
		PubSub.onFloor.emit(self, CONNECT_ONE_SHOT)
	# Moving the Character
	velocity = target_velocity
	move_and_slide()


func turnStarted():
	set_process(true)


func turnEnded():
	set_process(false)


func try_mouse_input(caller: Node, _camera: Node, event: InputEvent, _input_position: Vector3, _normal: Vector3) -> bool:
	prints(caller)
	if event.button_mask != 0:
		# get unit
		var unit = self.get_parent_node_3d()
		if event.button_mask == 1:
			_mouse_input_received = true
			PubSub.unit_input_left_click.emit(unit, event)
		elif event.button_mask == 2:
			_mouse_input_received = true
			PubSub.unit_input_right_click.emit(unit, event)

	return false


func setSelected(value : bool):
	SELECTED = value
	
	
func outline(on):
	if on == 1 and not $"Pivot/unit-soldier-blue/OutlineMesh".is_visible():
		$"Pivot/unit-soldier-blue/OutlineMesh".show()
	else:
		$"Pivot/unit-soldier-blue/OutlineMesh".hide()


## Recieves the units orders and adds to the unit-soldier to calculate when 
## an order is completed by the individual entity. Ie. entity has reached the 5m
## zone around their calculated end position. Also for debugging purposes.
##
## @param order = Array in the form of ["move" : "destination as Vector3"]
func recieveOrder(order : Array) -> void:
	Log.info(self, "Got order " + Log.array_to_string(order))
	var waypoint = addOrderWayPoint(order[0], order[1], getOffsetFromUnitMiddle())
	var entityOrder = [order[0], order[1], waypoint]
	self.ORDERS.push_back(entityOrder)


func getOffsetFromUnitMiddle() -> Vector3:
	var offset = Vector3.ZERO
	var myPos = self.global_position
	var unitMiddle = get_node_or_null("../UnitMarkerAnchor")
	if unitMiddle != null:
		offset = unitMiddle.global_position - myPos
		
	return offset


func addOrderWayPoint(order : String, wpPosition : Vector3, offset : Vector3) -> EntityOrderWayPoint:
	var wayPointPos = wpPosition - offset
	var waypoint = EntityOrderWayPoint.new(order, wayPointPos)
	get_node("Orders").add_child(waypoint)
	waypoint.global_position = wpPosition - offset
	waypoint.global_position.y = 3
	
	return waypoint
