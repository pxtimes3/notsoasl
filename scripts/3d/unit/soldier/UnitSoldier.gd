extends CharacterBody3D

@export var fall_acceleration = 75000

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

func _process(_delta: float) -> void:
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
## @param order = Dictionary in the form of {"move" : "destination as Vector3"}
func recieveOrder(order : Array) -> void:
	prints(self, "got order", order)
