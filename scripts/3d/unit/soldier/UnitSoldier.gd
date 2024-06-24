extends CharacterBody3D

@export var fall_acceleration = 75000
@export var gravity: float = -9.8

@export var ENTITY_STATUS = ""

var _mouse_input_received := false
var target_velocity = Vector3.ZERO

@export var SPEED : float = 1.0

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
@export var CURRENT_ORDER : StaticBody3D


func _ready():
	PubSub.turnPlayStart.connect(turnStarted)
	PubSub.turnPlaying.connect(turnManager.bind())
	PubSub.turnPlayEnd.connect(turnEnded)
	

func _process(_delta: float) -> void:
	pass


func turnManager(args : Array = []):
	pass


func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if CURRENT_ORDER:
		if not is_at_waypoint():
			# Log.debug(self, "wants to move to waypoint %s" % CURRENT_ORDER.global_position)
			move_to_waypoint(delta)
	else:
		# If no order, just apply gravity
		velocity.x = 0
		velocity.z = 0
	
	# Apply the velocity
	move_and_slide()
	
	# Check if we've landed on the floor
	if is_on_floor():
		PubSub.onFloor.emit(self, CONNECT_ONE_SHOT)


func turnStarted():
	if getCurrentOrder():
		CURRENT_ORDER = getCurrentOrder()
		set_process(true)


func turnEnded():
	set_process(false)


func getCurrentOrder():
	var orders = get_node("Orders")
	var count = orders.get_child_count()
	if $Orders.get_child_count():
		return $Orders.get_child(0)
	else:
		return false


func is_at_waypoint() -> bool:
	var dist = global_position.distance_to(CURRENT_ORDER.global_position)
	# Log.debug(self, "I am %s units from my waypoint" % dist)
	return  dist < 0.1

func move_to_waypoint(delta):
	if CURRENT_ORDER:
		var target_position = CURRENT_ORDER.global_position
		target_position.y = global_position.y  # Keep the same y-coordinate
		
		var direction = (target_position - global_position).normalized()
		#if direction != Vector3.ZERO:
		#	self.basis = basis.looking_at(target_position).inverse()
		
		# Set the horizontal velocity
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		# The y velocity is already set by gravity
		
		# Make the character look at the waypoint
		look_at(target_position, Vector3.UP, true)
	else:
		Log.debug(self, "No current order to move to")


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
	if on == 1 and not $"unit-soldier-blue/OutlineMesh".is_visible():
		$"unit-soldier-blue/OutlineMesh".show()
	else:
		$"unit-soldier-blue/OutlineMesh".hide()


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
