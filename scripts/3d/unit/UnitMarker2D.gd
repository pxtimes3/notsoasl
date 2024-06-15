extends Sprite2D

# Reference to the target node in 3D space
@export var target_path : NodePath = "../UnitMarkerAnchor"

# Vertical offset for the floating effect
@export var vertical_offset : float = 0.0
@export var horizontal_offset : float = 0.0

# Reference to the 3D target node
var target

func _ready():
	# Get the target node from the node path
	target = get_node(target_path)

func _process(delta):
	target = get_node(target_path)
	if target:
		# Get the camera node
		var camera = get_viewport().get_camera_3d()
		
		if camera:
			# Get the 2D position of the target on the screen
			var screen_pos = camera.unproject_position(target.global_transform.origin)
			
			# Add the vertical offset to the screen position
			screen_pos.y -= vertical_offset
			screen_pos.x -= horizontal_offset
			
			# Set the position of the 2D object to the screen position
			self.global_position = screen_pos

func _handle_click(sprite : Sprite2D, event : InputEvent):
	PubSub.unit_input_left_click.emit(self.get_parent(), event)
