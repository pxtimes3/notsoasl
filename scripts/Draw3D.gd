extends Node

var points:Array
var lines:Array

var mouse_line: MeshInstance3D

func _ready() -> void:
	call_deferred("_init_mouse_line")
	if Mode.MODE == 1:
		pass

func _process(delta: float) -> void:
	if Mode.MODE == 1:
		_update_mouse_line()
		pass

func _init_mouse_line(pos : Vector3 = Vector3.ZERO):
	mouse_line = await line(Vector3.ZERO, Vector3.ZERO, Color.BLACK)

func _update_mouse_line():
	var mouse_pos = get_mouse_pos()
	var mouse_line_immediate_mesh = mouse_line.mesh as ImmediateMesh
	if mouse_pos != null:
		var mouse_pos_V3:Vector3 = mouse_pos
		mouse_line_immediate_mesh.clear_surfaces()
		mouse_line_immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		#mouse_line_immediate_mesh.surface_add_vertex(Vector3.ZERO)
		mouse_line_immediate_mesh.surface_add_vertex(Order.getSelectedUnitPosition())
		mouse_line_immediate_mesh.surface_add_vertex(mouse_pos_V3)
		mouse_line_immediate_mesh.surface_end()	

#Returns the position in 3d that the mouse is hovering, or null if it isnt hovering anything
func get_mouse_pos():
	var space_state = get_parent().get_world_3d().get_direct_space_state()
	var mouse_position = get_viewport().get_mouse_position()
	var camera = get_tree().root.get_camera_3d()
	
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_position) * 1000
		
	var params = PhysicsRayQueryParameters3D.new()
	params.from = ray_origin
	params.to = ray_end
	params.collision_mask = 1
	params.exclude = []
	
	var rayDic = space_state.intersect_ray(params)	
	
	if rayDic.has("position"):
		return rayDic["position"]
	return null

func point(pos: Vector3, radius = 0.05, color = Color.WHITE_SMOKE, persist_ms = 0):
	var mesh_instance := MeshInstance3D.new()
	var sphere_mesh := SphereMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = sphere_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_instance.position = pos

	sphere_mesh.radius = radius
	sphere_mesh.height = radius*2
	sphere_mesh.material = material

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color

	return await final_cleanup(mesh_instance, persist_ms)

func line(pos1: Vector3, pos2: Vector3, color = Color.WHITE_SMOKE, persist_ms = 0):
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP, material)
	immediate_mesh.surface_add_vertex(pos1)
	immediate_mesh.surface_add_vertex(pos2)
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color

	return await final_cleanup(mesh_instance, persist_ms)


## 1 -> Lasts ONLY for current physics frame
## >1 -> Lasts X time duration.
## <1 -> Stays indefinitely
func final_cleanup(mesh_instance: MeshInstance3D, persist_ms: float):
	get_tree().get_root().add_child(mesh_instance)
	if persist_ms == 1:
		await get_tree().physics_frame
		mesh_instance.queue_free()
	elif persist_ms > 0:
		await get_tree().create_timer(persist_ms).timeout
		mesh_instance.queue_free()
	else:
		return mesh_instance
