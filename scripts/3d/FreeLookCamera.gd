#Copyright 2020 Adam Viola
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class_name FreeLookCamera 
extends Camera3D

@onready var camera = self

# TODO: Ändra Q + E till Y=0, Y=20 osv
# Modifier keys' speed multiplier
const SHIFT_MULTIPLIER = 2.5
const ALT_MULTIPLIER = 1.0 / SHIFT_MULTIPLIER

@export_range(0.0, 1.0) var sensitivity = 0.25

# Mouse state
var _mouse_position = Vector2(0.0, 0.0)
var _total_pitch = 0.0

# Movement state
var _direction = Vector3(0.0, 0.0, 0.0)
var _velocity = Vector3(0.0, 0.0, 0.0)
var _acceleration = 100
var _deceleration = -50
var _vel_multiplier = 4

# Keyboard state
var _w = false
var _s = false
var _a = false
var _d = false
var _q = false
var _e = false
var _shift = false
var _alt = false

func _input(event):
	# Receives mouse motion
	if event is InputEventMouseMotion:
		_mouse_position = event.relative
	
	# Receives mouse button input
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_MIDDLE: # Only allows rotation if right click down
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
			#MOUSE_BUTTON_WHEEL_UP: # Increases max velocity
				#_vel_multiplier = clamp(_vel_multiplier * 1.1, 0.2, 20)
			#MOUSE_BUTTON_WHEEL_DOWN: # Decereases max velocity
				#_vel_multiplier = clamp(_vel_multiplier / 1.1, 0.2, 20)

	# Receives key input
	if event is InputEventKey:
		match event.keycode:
			KEY_W:
				_w = event.pressed
			KEY_S:
				_s = event.pressed
			KEY_A:
				_a = event.pressed
			KEY_D:
				_d = event.pressed
			KEY_Q:
				_q = event.pressed
			KEY_E:
				_e = event.pressed

# Updates mouselook and movement every frame
func _process(delta):
	#rotation.x = clamp(rotation.x, -1, 1)
	position.y = clamp(position.y, 0.3, 200)
	_update_mouselook()
	_update_movement(delta)

# Updates camera movement
func _update_movement(delta):
	# Computes desired direction from key states
	_direction = Vector3((_d as float) - (_a as float), 
						(_e as float) - (_q as float), 
						(_s as float) - (_w as float))
	
	# Computes the change in velocity due to desired direction and "drag"
	# The "drag" is a constant acceleration on the camera to bring it's velocity to 0
	var offset = _direction.normalized() * _acceleration * _vel_multiplier * delta \
		+ _velocity.normalized() * _deceleration * _vel_multiplier * delta
	
	# Compute modifiers' speed multiplier
	var speed_multi = 10
	if _shift: speed_multi *= SHIFT_MULTIPLIER
	if _alt: speed_multi *= ALT_MULTIPLIER
	
	# Checks if we should bother translating the camera
	if _direction == Vector3.ZERO and offset.length_squared() > _velocity.length_squared():
		# Sets the velocity to 0 to prevent jittering due to imperfect deceleration
		_velocity = Vector3.ZERO
	else:
		# Clamps speed to stay within maximum value (_vel_multiplier)
		_velocity.x = clamp(_velocity.x + offset.x, -_vel_multiplier, _vel_multiplier)
		_velocity.y = clamp(_velocity.y + offset.y, -_vel_multiplier, _vel_multiplier)
		_velocity.z = clamp(_velocity.z + offset.z, -_vel_multiplier, _vel_multiplier)
	
		translate(_velocity * delta * speed_multi)

# Updates mouse look 
func _update_mouselook():
	# Only rotates mouse if the mouse is captured
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_position *= sensitivity
		var yaw = _mouse_position.x
		var pitch = _mouse_position.y
		_mouse_position = Vector2(0, 0)
		
		# Prevents looking up/down too far
		pitch = clamp(pitch, -90 - _total_pitch, 90 - _total_pitch)
		_total_pitch += pitch
	
		rotate_y(deg_to_rad(-yaw))
		rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))


###################################################################################################
##     RAYCASTING
###################################################################################################

const RAY_LENGTH = 1000.0

signal mouse_ray_processed()

@export_flags_3d_physics var _detection_layers

var _query_mouse := false
var _mouse_event : InputEventMouse


func _unhandled_input(event):

	# Take all unhandled mouse events and save them to be processed
	
	if event is InputEventMouseButton and event.button_index in [1,2]:
		_query_mouse = true
		_mouse_event = event


func _physics_process(_delta):
	# get_node("/root/main/Units/Unit/Sprite2D").position = self.unproject_position(global_transform.origin)
	if _query_mouse:
		_check_sprite_input()
		_query_mouse = false
		mouse_ray_processed.emit()

func _check_if_sprite2d_was_clicked(event : InputEvent) -> bool:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var from = event.global_position
		# var to = from + project_ray_normal(event.global_position) * 1000
		var to = from + Vector2(0, 100)

		var space_state_2d = get_tree().root.get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(from, to)
		query.collide_with_areas = true
		query.hit_from_inside = true
		var result = space_state_2d.intersect_ray(query)

		if result:
			var collider = result.collider
			if collider is Area2D:
				var sprite_2d = collider.get_parent()
				if sprite_2d is Sprite2D:
					return _handle_sprite2d_click(sprite_2d, event)
		
	return false


func _handle_sprite2d_click(sprite : Sprite2D, event : InputEvent) -> bool:
	sprite._handle_click(event)
	return true # for now?


func _check_sprite_input() -> bool:
	
	# List of unsuccessful Sprite3Ds

	var not_hits = []

	# Construct raycast parameters

	var space_state = get_world_3d().direct_space_state
	var from = project_ray_origin(_mouse_event.position)
	var to = from + project_ray_normal(_mouse_event.position) * RAY_LENGTH
	

	# Iterate until successful hit or no valid sprites remain
	while true:
		var query = PhysicsRayQueryParameters3D.create(from, to, _detection_layers, not_hits)
		query.collide_with_areas = true
		
		# Check for Sprite2D-click (i.e. unit marker)
		var result := {}
		if _check_if_sprite2d_was_clicked(_mouse_event) != true:
			result = space_state.intersect_ray(query)

		# Exit if no results
		if result.is_empty():
			# prints("Empty result")
			return false

		# Exit if successful collision
		elif result.collider.owner != null \
		and result.collider.owner.has_method("try_mouse_input"):
			result.collider.owner.try_mouse_input(result.collider.owner, self, _mouse_event, result.position, result.normal)
			return true
		
		elif result.collider.has_method("try_mouse_input"):
			result.collider.try_mouse_input(result.collider, self, _mouse_event, result.position, result.normal)
			return true
			
		# Add sprite to not hits
		else:
			# prints("No hit!", result.collider)
			not_hits.append(result.collider)
	
	return true
