extends Node3D

# Used for checking if the mouse is inside the Area3D.
var is_mouse_inside = false
# The last processed input touch/mouse event. To calculate relative movement.
var last_event_pos2D = null
# The time of the last event in seconds since engine start.
var last_event_time: float = -1.0

@onready var node_viewport = $SubViewport
@onready var node_unit = $".."
@onready var node_quad = $Quad
@onready var node_area = $Quad/Area3D

func _ready():
	node_area.mouse_entered.connect(_mouse_entered_area)
	node_area.mouse_exited.connect(_mouse_exited_area)
	node_area.input_event.connect(_mouse_input_event)

	# If the material is NOT set to use billboard settings, then avoid running billboard specific code
	if node_quad.get_surface_override_material(0).billboard_mode == BaseMaterial3D.BillboardMode.BILLBOARD_DISABLED:
		set_process(false)


func _process(_delta):
	# NOTE: Remove this function if you don't plan on using billboard settings.
	rotate_area_to_billboard()


func _mouse_entered_area():
	is_mouse_inside = true


func _mouse_exited_area():
	is_mouse_inside = false


#func _unhandled_input(event):
	## Check if the event is a non-mouse/non-touch event
	#for mouse_event in [InputEventMouseButton, InputEventMouseMotion, InputEventScreenDrag, InputEventScreenTouch]:
		#if is_instance_of(event, mouse_event):
			## If the event is a mouse/touch event, then we can ignore it here, because it will be
			## handled via Physics Picking.
			#return
	#Selection.newUnitMarker(["_unhandled_input"])
	#node_viewport.push_input(event)


func _mouse_input_event(_camera: Camera3D, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int):
	if event is InputEventMouseButton:
		var caller = get_parent_node_3d() # should get us the Unit-node.
		Selection.select(caller, event, event_position)
	# node_viewport.push_input(event)


func rotate_area_to_billboard():
	#var billboard_mode = node_quad.get_surface_override_material(0).params_billboard_mode
	# we don't care about billboard mode since it should be on by default in our case :D
	
	var camera = get_viewport().get_camera_3d()
	# Look in the same direction as the camera.
	var look = camera.to_global(Vector3(0, 0, -100)) - camera.global_transform.origin
	look = node_area.position + look

	node_area.look_at(look, Vector3.UP)

	# Rotate in the Z axis to compensate camera tilt.
	node_area.rotate_object_local(Vector3.BACK, camera.rotation.z)
	
	# Try to match the area with the material's billboard setting, if enabled.
	#if billboard_mode > 0:
		## Get the camera.
		#var camera = get_viewport().get_camera_3d()
		## Look in the same direction as the camera.
		#var look = camera.to_global(Vector3(0, 0, -100)) - camera.global_transform.origin
		#look = node_area.position + look
#
		## Y-Billboard: Lock Y rotation, but gives bad results if the camera is tilted.
		#if billboard_mode == 2:
			#look = Vector3(look.x, 0, look.z)
#
		#node_area.look_at(look, Vector3.UP)
#
		## Rotate in the Z axis to compensate camera tilt.
		#node_area.rotate_object_local(Vector3.BACK, camera.rotation.z)
