extends Node

signal openOrdersMenu
signal ordersMenu

var orderColor : Dictionary = {
	"order_move_patrol" : Color.AQUA,
	"order_move_fast" : Color.WEB_PURPLE,
	"order_move_assault" : Color.ROSY_BROWN,
	"order_move_crawl" : Color.YELLOW,
}
var currentOrder = ""
var points = []
var lines = []
@onready var indicator = get_node("/root/main/Marker")
#var orderline : OrderLine

func _input(event: InputEvent) -> void:
	if Selection.getSelectedUnits().size() > 0 \
	and Mode.MODE == 1:
		indicator.show()
		currentOrder = Mode.CURRENTORDER
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
func getGroundAtCoordinates(coordinates : Vector3, mask : int = 1, RAY_LENGTH : int = -1000):
	var space_state = get_parent().get_world_3d().get_direct_space_state()
	var ray_origin = coordinates
	var ray_end = Vector3(coordinates.x, RAY_LENGTH, coordinates.z)
	# var end = Vector3(origin.x, RAY_LENGTH, origin.z)
	#var query = PhysicsRayQueryParameters3D.create(origin, end, mask)
	var params = PhysicsRayQueryParameters3D.new()
	params.from = ray_origin
	params.to = ray_end
	params.collision_mask = 1
	params.exclude = []
	params.collide_with_areas = true

	var rayDic = space_state.intersect_ray(params)	
	
	if rayDic.has("position"):
		return rayDic["position"]
	return null


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


func getSelectedUnitPosition() -> Vector3:
	var lastUnit = null
	var position = false
	var units = Selection.getSelectedUnits()
	
	if units.size() > 1:
		lastUnit = units[units.size() - 1]
	else:
		lastUnit = units[0]

	position = getGroundAtCoordinates(lastUnit.global_position)
	return position

func _draw_point_and_line() -> void:
	var point1
	var point2
	## TODO: If multiple units!?
	if points.size() < 1:
		points.append(getSelectedUnitPosition()) # add selected unit
		point1 = points[0] # assign unit position as point1
		point2 = Vector3(get_mouse_pos()) # mouse position is point2
		points.append(point2) 
	elif points.size() > 1:
		point1 = points[points.size() -1]
		point2 = Vector3(get_mouse_pos()) # mouse position is point2
		points.append(point2) 
	
	# sanitycheck
	if typeof(point1) != TYPE_VECTOR3 or typeof(point2) != TYPE_VECTOR3:
		push_error("Points are not Vector3!")
		breakpoint
	
	# draw line and add a waypoint
	var cbWayPoint = OrderWayPoint.new(point2, currentOrder)
	var orderline = OrderLine.new(point1, point2, orderColor[currentOrder])
		
	self.add_child(orderline)
	self.add_child(cbWayPoint)
	handOverOrderToUnit(cbWayPoint)


func drawCylinder(start : Vector3, end : Vector3, color : Color = Color(1,0,0,0.9)) -> MeshInstance3D:
	var orderline = OrderLine.new(start, end, color)
	orderline.look_at_from_position(start,end,Vector3(0,1,0))
	
	return orderline


## Skapar en punkt (sic!)
func point(pos: Vector3, radius : float = 1.0, color = Color.WHITE_SMOKE) -> MeshInstance3D:
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
	
	return mesh_instance


## Skickar över order/s till unit. Formatterade på rätt sätt osv.
func handOverOrderToUnit(waypoint : OrderWayPoint):
	pass
	
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
