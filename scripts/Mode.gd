extends Node

enum GAMESTATE {NORMAL, ORDER, TURN}
@export var MODE = GAMESTATE.NORMAL


func _unhandled_key_input(event):
	if Input.is_action_pressed("order_patrol"):
		print (event)
# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Selection.selectedUnits.size() == 0 and MODE == GAMESTATE.ORDER:
		MODE = GAMESTATE.NORMAL
	if Input.is_action_pressed("order_patrol") and Selection.selectedUnits.size() > 0:
		MODE = GAMESTATE.ORDER
		Order.drawOrderLine()
