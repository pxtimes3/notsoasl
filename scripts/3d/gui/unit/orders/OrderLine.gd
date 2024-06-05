## Creates a line between the order waypoints

class_name OrderLine
extends MeshInstance3D

func _init(from:Vector3, to:Vector3, color:Color) -> void:
	var length = (from-to).length()
	var radius := 0.2
	var line := CylinderMesh.new()

	line.radial_segments = 8
	line.bottom_radius = radius
	line.top_radius = radius
	line.cap_bottom = false
	line.height = length
	
	var line_array = line.get_mesh_arrays()
	for i in range(0,line_array[0].size()):
		# Move the cylinder up so its end is the origin
		line_array[ArrayMesh.ARRAY_VERTEX][i] -= Vector3(0,length/2.0,0)
		line_array[ArrayMesh.ARRAY_VERTEX][i] = line_array[ArrayMesh.ARRAY_VERTEX][i].rotated(Vector3.RIGHT, PI/2.0)
		line_array[ArrayMesh.ARRAY_NORMAL][i] = line_array[ArrayMesh.ARRAY_NORMAL][i].rotated(Vector3.RIGHT, PI/2.0)

	var arr_mesh = ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, line_array)
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.transparency = 0.4
	line.material = mat
	
	self.cast_shadow = SHADOW_CASTING_SETTING_OFF
	self.transparency = 0.25
	
	mesh = arr_mesh
