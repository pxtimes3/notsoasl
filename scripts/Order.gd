extends Node

signal openOrdersMenu
signal ordersMenu

var currentOrders = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	pass

# shows the orders menu at mouse position
func showOrdersMenu(pos : Vector2):
	print("I WAS EMITTED!", pos)
	ordersMenu.emit(pos)

func drawOrderLine() -> void:
	# get currently selected units position = start
	var startPos = getSelectedUnitPosition()
	if startPos:
		
		pass
	# follow cursor
	# click = place endpoint
	# shift-click = place waypoint => new start?
	pass


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
	var end = Vector3(origin.x, -1000, origin.z)
	var query = PhysicsRayQueryParameters3D.create(origin, end, 1)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	
	return result.position.y


func getSelectedUnitPosition():
	var startPosition = Vector3.UP
	var units = Selection.getSelectedUnits()
	
	if units.size() > 0:
		var lastUnit = units[units.size() - 1]
		var position = lastUnit.global_position
		var ground = getGroundAtCoordinates(position)
		position.y = ground
		
		return position

