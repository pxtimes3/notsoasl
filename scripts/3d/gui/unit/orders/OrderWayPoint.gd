## Creates the order waypoint with unit-id, order etc.

class_name OrderWayPoint
extends Area3D

signal isDragging

@export var is_dragging : bool
@export var waypointPos : Vector3
@export var waypointOrder : String
@export var waypointRadius : float
@export var waypointColor : Color

func _init(pos: Vector3, order : String, radius : float = 0.5, color = Color.WHITE_SMOKE) -> void:
	self.order = order
	self.waypointPos = pos
	self.waypointOrder = order
	self.waypointRadius = radius
	self.waypointColor = color
	
	var mesh = MeshInstance3D.new()
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	var sphere = SphereMesh.new()
	sphere.radius = radius
	
	var sphereShape = SphereShape3D.new()
	sphereShape.radius = radius
	
	var collisionMesh = CollisionShape3D.new()
	collisionMesh.shape = sphereShape
		
	mesh.mesh = sphere
	mesh.cast_shadow = false
	
	mesh.material_override = mat
	
	self.add_child(mesh)
	self.add_child(collisionMesh)
	
	self.position = pos

## TODO: How do we make a unique instance of the class? Duplicate etc. wont work.
## 
#
#var newPos : Vector3
#
#func _process(delta):
	#if is_dragging:
		#var input_vec = Input.get_action_strength("ui_mouse") * Vector2(1, -1)
		## var mouse_ray = get_viewport().get_camera().project_ray_origin(get())
		#var new_pos = Order.get_mouse_pos()
		##var new_transform = Transform3D(Basis(), new_pos)
		##set_transform(new_transform)
		#self.position = new_pos
		#print(self.position)
#
### Drag to reposition
#
#func _input(event):
	#if event is InputEventMouseButton and Mode.MODE != 1:
		#if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			#prints(self, "clicked on!")
