## Creates the order waypoint with unit-id, order etc.

class_name OrderWayPoint
extends MeshInstance3D

var order : String

func _init(pos: Vector3, order : String, radius : float = 0.5, color = Color.WHITE_SMOKE) -> void:
	#var mesh = MeshInstance3D.new()
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	
	var sphere = SphereMesh.new()
	sphere.radius = radius
		
	self.mesh = sphere
	self.cast_shadow = SHADOW_CASTING_SETTING_OFF
	self.material_override = mat
	self.position = pos
