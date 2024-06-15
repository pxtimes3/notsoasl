extends Node

var isDragging : bool
var newPos : Vector3

func _process(_delta):
	if isDragging:
		# var input_vec = Input.get_action_strength("ui_mouse") * Vector2(1, -1)
		# var mouse_ray = get_viewport().get_camera().project_ray_origin(get())
		var new_pos = Order.get_mouse_pos()
		#var new_transform = Transform3D(Basis(), new_pos)
		#set_transform(new_transform)
		self.position = new_pos
		#print(self.position)

# Drag to reposition
func _input(event):
	print(event)
	if event is InputEventMouseButton and Mode.MODE != 1:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			isDragging = true
			prints("dragged!", self)
		else:
			isDragging = false
