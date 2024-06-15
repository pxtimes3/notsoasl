extends Control

func _on_start_turn_button_up():
	PubSub.executeTurn.emit()
