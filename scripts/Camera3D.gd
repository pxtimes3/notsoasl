extends Camera3D

var motion := Vector3()
var velocity := Vector3()
var move_speed := 1.5
# The initial camera node rotation.
var initial_rotation := rotation.z

# Called when the node enters the scene tree for the first time.
func _ready():
	# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direction = Vector3.ZERO
	# blir ett jävla roterande annars
	rotation.x = clamp(rotation.x, -1, 1)
	position.y = clamp(position.y, 0.1, 100)
	
	# move camera Z or X
	if Input.is_action_pressed("camera_move_forward"):
		direction.z = -1
	elif Input.is_action_pressed("camera_move_backward"):
		direction.z = 1
	#else: 
		#motion.z = 0
		
	if Input.is_action_pressed("camera_move_left"):
		motion.x = -1
	elif Input.is_action_pressed("camera_move_right"):
		motion.x = 1
	else: 
		motion.x = 0
	
	# move camera Y (zoom)
	if Input.is_key_pressed(KEY_CTRL) and Input.is_key_pressed(KEY_W):
		motion.y = -1
		print(self.position.y)
	elif Input.is_key_pressed(KEY_CTRL) and Input.is_key_pressed(KEY_S):
		print(self.position.y)
		motion.y = 1
	elif Input.is_action_just_released("camera_zoom_out"):
		print("mousewheeldown")
		print(self.position.y)
		motion.y = 10
	elif Input.is_action_just_released("camera_zoom_in"):
		print("mousewheelup")
		print(self.position.y)
		motion.y = -10
	else:
		motion.y = 0
	
	velocity += motion * move_speed
	velocity *= 0.9
	position += velocity * delta

func _input(event):
	# TODO: varför kan vi inte ha en if mousemotion and middle OR ctrl?
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		rotate(Vector3.UP, -event.relative.x * 0.001)
