extends Node

enum GAMESTATE {NORMAL, ORDER, TURN}

@export var MODE = GAMESTATE.NORMAL
@export var CURRENTORDER : String = ""
@onready var textTopMiddle = get_node("/root/main/GameUi/TopMiddle/MarginContainer/Text")

func _ready() -> void:
	PubSub.executeTurn.connect(executeTurn.bind())

func _process(_delta: float) -> void:
	if Selection.selectedUnits.size() > 0 and MODE == GAMESTATE.NORMAL:
		#textTopMiddle.text = "SELECTEDUNIT"
		pass
		
	if Selection.selectedUnits.size() == 0 and MODE == GAMESTATE.ORDER:
		MODE = GAMESTATE.NORMAL
		
	if Input.is_action_pressed("order_move_patrol") and Selection.selectedUnits.size() > 0:
		MODE = GAMESTATE.ORDER
		CURRENTORDER = "order_move_patrol"
		textTopMiddle.text = "ORDERDRAWLINE"
		
	if Input.is_action_pressed("order_move_fast") and Selection.selectedUnits.size() > 0:
		MODE = GAMESTATE.ORDER
		CURRENTORDER = "order_move_fast"
		textTopMiddle.text = "ORDERDRAWLINE"
		
	if Input.is_action_pressed("order_move_assault") and Selection.selectedUnits.size() > 0:
		MODE = GAMESTATE.ORDER
		CURRENTORDER = "order_move_assault"
		textTopMiddle.text = "ORDERDRAWLINE"
		
	if Input.is_action_pressed("order_move_crawl") and Selection.selectedUnits.size() > 0:
		MODE = GAMESTATE.ORDER
		CURRENTORDER = "order_move_crawl"
		textTopMiddle.text = "ORDERDRAWLINE"


func executeTurn() -> void:
	MODE = GAMESTATE.TURN


func endMode(mode : GAMESTATE) -> void:
	textTopMiddle.text = ""
	MODE = GAMESTATE.NORMAL
	CURRENTORDER = ""
