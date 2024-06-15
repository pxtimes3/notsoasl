extends Node

var OrderWayPointScript = load("res://scripts/3d/gui/unit/orders/DragWayPoint.gd")
var WayPointScene : PackedScene = load("res://scenes/3d/unit/OrderWaypoint.tscn")

var orderColor : Dictionary = {
	"order_move_patrol" : Color.AQUA,
	"order_move_fast" : Color.WEB_PURPLE,
	"order_move_assault" : Color.ROSY_BROWN,
	"order_move_crawl" : Color.YELLOW,
}
var currentOrder = ""
var wayPoints = {
	## "unitnode" : [
	##	{"order": "globalPosition"}
	## ]
}
var points = {}
var lines = []

## första enheten i SelectedUnits för att räkna ut offset på waypoints.
var firstUnit : UnitEntity

@onready var indicator = get_node("/root/main/Marker")

func _input(event: InputEvent) -> void:
	if Selection.getSelectedUnits().size() > 0 \
	and Mode.MODE == 1:
		indicator.show()
		currentOrder = Mode.CURRENTORDER
		if event.is_action_pressed("mouse_left_click"):
			prepareOrderLineDrawing(Selection.getSelectedUnits())
	
	if event.is_action_pressed("mouse_right_click") \
	and Mode.MODE == 1:
		indicator.hide()
		Mode.endMode(1)
	
	if event.is_action_pressed("order_delete_node") \
	and Selection.getSelectedUnits().size() > 0:
		deleteLastNode()


func _process(delta) -> void:
	if Mode.MODE == 1:
		var mousePos = get_mouse_pos()
		if mousePos:
			indicator.global_position = mousePos

# Shows the orders menu at mouse position
func showOrdersMenu(pos : Vector2):
	PubSub.ordersMenu.emit(pos)


## Return collision w. ground at coordinates
func getGroundAtCoordinates(coordinates : Vector3, mask : int = 1, RAY_LENGTH : int = -1000):
	var space_state = get_parent().get_world_3d().get_direct_space_state()
	var ray_origin = coordinates
	var ray_end = Vector3(coordinates.x, RAY_LENGTH, coordinates.z)
	
	return performPhysicsQuery(space_state, ray_origin, ray_end)


## Returns the position in 3d that the mouse is hovering, or null if it isnt hovering anything
func get_mouse_pos():
	var space_state = get_parent().get_world_3d().get_direct_space_state()
	var mouse_position = get_viewport().get_mouse_position()
	var camera = get_tree().root.get_camera_3d()
	
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_position) * 1000
		
	return performPhysicsQuery(space_state, ray_origin, ray_end)


## Does the actual raycasting
func performPhysicsQuery(space_state, ray_origin : Vector3, ray_end : Vector3):
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


func prepareOrderLineDrawing(selectedUnits : Array) -> void:
	firstUnit = selectedUnits[0]
	for i in selectedUnits:
		_drawWaypoints(i)


func getUnitOffset(unit : UnitEntity, baseUnit : UnitEntity = firstUnit) -> Vector3:
	var offset = Vector3.UP
	offset = unit.global_position - baseUnit.global_position
	print("offset=", offset)
	return offset


func _drawWaypoints(unit : UnitEntity) -> void:
	var point1 : Vector3
	var point2 : Vector3
	var offset : Vector3 = Vector3(0,0,0)
	
	if not points.has(unit):
		points[unit] = []
	
	if unit != firstUnit:
		offset = getUnitOffset(unit)
	
	if points[unit].size() < 1:
		var ground = getGroundAtCoordinates(unit.global_position)
		var unitMiddle = unit.get_node("UnitMarker").global_position
		unitMiddle.y = ground.y
		points[unit].append(unitMiddle) # add selected unit
		point1 = unitMiddle
		point2 = offset + Vector3(get_mouse_pos()) # mouse position is point2
		points[unit].append(point2) 
	elif points[unit].size() > 1:
		point1 = points[unit][points[unit].size() -1]
		point2 = offset + Vector3(get_mouse_pos()) # mouse position is point2
		points[unit].append(point2) 
	
	# sanitycheck
	if typeof(point1) != TYPE_VECTOR3 or typeof(point2) != TYPE_VECTOR3:
		push_error("Points are not Vector3!")
		breakpoint
	
	var cbWayPoint = OrderWayPoint.new(point2, currentOrder)
	var orderline = OrderLine.new(point1, point2, orderColor[currentOrder])
		
	handOverOrderToUnit(unit, orderline)
	handOverOrderToUnit(unit, cbWayPoint)
	# send to Unit for distribution to it's entities.
	unit.forwardOrderToEntities([cbWayPoint.order, cbWayPoint.global_position])


## Skickar över order/s till unit.
func handOverOrderToUnit(unit : UnitEntity, mesh) -> void:
	var unitOrderNode = unit.get_node("Orders")
	unitOrderNode.add_child(mesh)


func deleteLastNode():
	var selectedUnits = Selection.selectedUnits
	for n : UnitEntity in selectedUnits:
		var orders = n.get_node("Orders").get_children()
		# sanitycheck
		if orders.size() > 1:
			orders[orders.size() - 1].free()
			orders[orders.size() - 2].free()
			var unitPoints : Array = points[n]
			var unitPointToDelete : int = unitPoints.size() - 1
			unitPoints.pop_back()
