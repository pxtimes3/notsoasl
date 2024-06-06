extends Node

signal openOrdersMenu
signal ordersMenu

var currentOrders = {}
var points = []
var lines = []
@onready var indicator = get_node("/root/main/Marker")
var orderline : OrderLine

func _input(event: InputEvent) -> void:
	if Selection.getSelectedUnits().size() > 0 \
	and Mode.MODE == 1:
		indicator.show()
		if event.is_action_pressed("mouse_left_click"):
			_draw_point_and_line()
	
	if event.is_action_pressed("mouse_right_click") \
	and Selection.getSelectedUnits().size() > 0 \
	and Mode.MODE == 1:
		indicator.hide()
		Mode.endMode(1)

func _process(delta) -> void:
	if Mode.MODE == 1:
		var mousePos = get_mouse_pos()
		if mousePos:
			indicator.global_position = mousePos

# shows the orders menu at mouse position
func showOrdersMenu(pos : Vector2):
	ordersMenu.emit(pos)


## Casts a ray from coordinates straight down until it collides with the ground
## and returns the position. 
##
## @param coordinates : Vector3
## @param mask : int = optional layer mask to collide with (in case ground is 
## not at 1 or if we want to check for something else but the ground. 
## @param RAY_LENGTH : int = -1000 should cover most of all our use cases.
## @return float for the Y coordinate of the collision.
func getGroundAtCoordinates(coordinates : Vector3, mask : int = 1, RAY_LENGTH : int = -1000) -> float:
	var space_state = get_parent().get_world_3d().direct_space_state
	
	var origin = coordinates
	var end = Vector3(origin.x, RAY_LENGTH, origin.z)
	var query = PhysicsRayQueryParameters3D.create(origin, end, mask)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	
	return result.position.y


func getSelectedUnitPosition() -> Vector3:
	var position = false
	var units = Selection.getSelectedUnits()
	
	if units.size() > 0:
		var lastUnit = units[units.size() - 1]
		position = lastUnit.global_position
		var ground = getGroundAtCoordinates(position)
		position.y = ground
		
	return position

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

func _draw_point_and_line()->void:
	print("_draw_point_and_line() called")

	if points.size() < 1:
		# No points. Unit = starting point
		prints("No points. Unit = starting point")
		var unitPoint = Vector3(getSelectedUnitPosition())
		points.append(unitPoint)
		prints("points:", points)
	var mouse_pos = get_mouse_pos()
	if mouse_pos != null:
		#If there are at least 2 points...
		if points.size() >= 1:
			prints("points are more than 1", points)
			var mouse_pos_V3:Vector3 = mouse_pos
			points.append(await point(mouse_pos_V3,0.3))
			prints("Point appended")
			#Draw a line from the position of the last point placed to the position of the second to last point placed
			var point1 = points[points.size()-1]
			var point2 = points[points.size()-2]
			# TODO: Make this a bit less messy
			if typeof(point1) != TYPE_VECTOR3:
				point1 = point1.position
			if typeof(point2) != TYPE_VECTOR3:
				point2 = point2.position
			
			var line = await drawCylinder(point1, point2, Color(0,0,1,0.9))
			
			lines.append(line)


func drawCylinder(start : Vector3, end : Vector3, color : Color = Color(1,0,0,0.9)):
	prints("drawCylinder() called")
	prints("start: ", start, " end:", end)
	orderline = OrderLine.new(start, end, color)
	
	#var upish:Vector3 = Vector3.UP.normalized()
	orderline.look_at_from_position(start,end,Vector3(0,1,0))
	self.add_child(orderline)


## Skapar en punkt (sic!)
func point(pos: Vector3, radius : float = 1.0, color = Color.WHITE_SMOKE):
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
	
	self.add_child(mesh_instance)
	
	return mesh_instance


## @deprecated
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
