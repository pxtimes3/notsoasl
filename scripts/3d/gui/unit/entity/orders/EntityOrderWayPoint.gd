class_name EntityOrderWayPoint
extends StaticBody3D

@export var waypointOrder : String

func _init(order, waypointPosition) -> void:
	waypointOrder = order
	
	var meshInstance = MeshInstance3D.new()
	var cylinderMesh = CylinderMesh.new()
	var material = StandardMaterial3D.new()
	var collisionShape = CollisionShape3D.new()
	
	material.albedo_color = Color(255.0, 111.0, 0.0, 1.0)
	cylinderMesh.material = material
	cylinderMesh.top_radius = 0
	cylinderMesh.bottom_radius = 0.5
	cylinderMesh.height = 2
	cylinderMesh.radial_segments = 8
	cylinderMesh.rings = 1
	meshInstance.mesh = cylinderMesh
	
	collisionShape.shape = CylinderShape3D.new()
	collisionShape.shape.height = 2.0
	collisionShape.shape.radius = 2.5
	
	self.add_child(meshInstance)
	self.add_child(collisionShape)
	
