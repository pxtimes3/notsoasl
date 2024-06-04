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

func getSelectedUnitPosition():
	var startPosition = Vector3.UP
	var units = Selection.getSelectedUnits()
	
	if units.size() > 0:
		var lastUnit = units[units.size() - 1]
		var position = lastUnit.position
		print(position)
		return startPosition

