extends CharacterBody3D

@export var fall_acceleration = 75

signal ordersMenu

var target_velocity = Vector3.ZERO

var PLAYER: bool = false # player controllable
var SELECTED: bool = false
var NPC: bool = false # npc/civilian
var UNIT: Dictionary = {} # unit id/ids
var MORALE: int = 100 # green = 50, conscript = 70, veteran = 100, elite = 120
var FATIGUE: int = 100 # 0 = exhausted TODO: regen?
var HEALTH: int = 3 # 0 dead, 1 injured, 2 wounded, 3 healthy

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	# Moving the Character
	velocity = target_velocity
	move_and_slide()

func _on_input_event(camera, event, position, normal, shape_idx):
	Selection.select(self, event, position)

func initialize():
	# pos.y = 0.0
	self.add_to_group(UNIT["unit"])
	# look_at_from_position(pos, Vector3.UP)

func outline(on):
	if on == 1 and not $"Pivot/unit-soldier-blue/OutlineMesh".is_visible():
		$"Pivot/unit-soldier-blue/OutlineMesh".show()
	else:
		$"Pivot/unit-soldier-blue/OutlineMesh".hide()

func setSelected(value : bool):
	SELECTED = value

func _unhandled_input(event: InputEvent) -> void:
	# Selection.unselect(self, event, position)
	if event is InputEventMouseButton \
	and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if SELECTED == true \
		and not Input.is_key_pressed(KEY_SHIFT) \
		and Mode.MODE != "order":
			if mouse_exited and $"Pivot/unit-soldier-blue/OutlineMesh".is_visible():
				get_tree().call_group(UNIT["unit"], "outline", 0)
				SELECTED = false
