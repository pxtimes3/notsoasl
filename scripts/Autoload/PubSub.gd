extends Node

### GAME

##### GAMESTART
signal game_loaded

### TURN
signal executeTurn(turn : int)
signal turnProcessed()
signal turnPlayStart()
signal turnPlaying()
signal turnPlayEnd()

### UNIT
signal unit_input_event(caller: Node, event: InputEvent)
signal unit_input_left_click(caller: Node, event: InputEvent)
signal unit_input_right_click(caller: Node, event: InputEvent)

### UNIT_SOLDIER
signal onFloor(entity : CharacterBody3D)
signal Orders

### ORDERS
signal openOrdersMenu
signal ordersMenu
