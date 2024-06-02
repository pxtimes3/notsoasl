## Handles selection of units
# class_name Selection
extends Node

var current_scene = null
var selectedUnits = [] # contains currently selected unit/s
var unitGroups = [] # contains all the groups created during unit-creation

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func select(caller, event, position):
	if event is InputEventMouseButton:
		# got a click
		if event.button_index == 1 and event.pressed == true and not event.double_click:
			print(event)
			# not rightclick 
			var groups = caller.get_groups()
			# if not SHIFT, then unselect other units and select this unit
			if not Input.is_key_pressed(KEY_SHIFT):
				for x in selectedUnits.size():
					get_tree().call_group(selectedUnits[x], "outline", 0)
				get_tree().call_group(caller.UNIT.unit, "outline", 1)
				# add this unit to selectedUnits
				selectedUnits = [caller.UNIT.unit]
			else:
				get_tree().call_group(caller.UNIT.unit, "outline", 1)
				# shift is pressed, appending to selectedUnits
				selectedUnits.append(caller.UNIT.unit)
				print(selectedUnits)
		elif event.double_click:
			if caller.UNIT.unit.ends_with("hq"):
				pass
			print("doubleclick!")
			print(unitGroups)
		
		
func unselect(caller, event, position):
	pass

# if mouse_entered:
		##print("mouse entered name:",self.name)
		#if event is InputEventMouseButton and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			#print("name:",self.name)
			#print("position:", self.position)
			#print("unit:", self.UNIT)
			#print("groups:", self.get_groups())
			#SELECTED = true
			##get_tree().get_nodes_in_group()
			#get_tree().call_group(self.UNIT.unit, "outline", 1)
		#if event is InputEventMouseButton and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			## open orders menu
			#print("open the menu!", event)
			#SELECTED = true
			##get_tree().get_nodes_in_group()
			#get_tree().call_group(self.UNIT.unit, "outline", 1)
			#Order.openOrdersMenu.emit()
			##var menu = get_node("/root/main/UnitOrdersMenu")
			##menu.position = get_viewport().get_mouse_position()
			##menu.show()
