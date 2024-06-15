extends Control

signal ordersMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()
	PubSub.ordersMenu.connect(showMenu)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var menuArea = $VBoxContainer.get_rect()
	if self.visible:
		if not Rect2(menuArea['position'], menuArea['size']).has_point(get_local_mouse_position()):
			if $Timer.is_stopped():
				print("timer started", $Timer.time_left)
				$Timer.start()
		else:
			$Timer.stop()
	
func showMenu(position : Vector2 = Vector2(0,0), unitType : String = ""):
	# TODO: Kolla så den inte försvinner utanför viewporten
	print("I'm at: ", self.global_position)
	print("I wanna show myself at: ", get_global_mouse_position())
	show()
	self.position = Vector2(get_global_mouse_position())
	#self.move_local_x(20)

func _on_timer_timeout() -> void:
	print("timed out")
	$Timer.stop()
	hide()

func _on_orders_menu() -> void:
	print("I has signal!")
