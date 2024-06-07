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
# func _process(delta: float) -> void:
#	pass

func newUnitMarker(p := []):
	print(p)


## Returns the currently selected units, if any.
func getSelectedUnits() -> Array:
	if selectedUnits.size() > 0:
		return selectedUnits
		
	return []


## Handles selection of units. Stores them in the selectedUnits array.
## caller: MyUnitEntity
func select(caller, event) -> void:
	if event is InputEventMouseButton and event.pressed == true:
		"""
		Check if event is left mouse button (on button down)
		CTRL or Double Click multiselects units
		Right Mouse opens the order menu etc... 
		"""
		if event.button_index == 1 \
		and not Input.is_key_pressed(KEY_CTRL) \
		and not event.double_click:
			#print("input called on unit/unit-entity")
			#prints("Ground detected @ ", Order.getGroundAtCoordinates(caller.global_position))
			var groups = caller.get_groups()
			# if not SHIFT, then unselect other units and select this unit
			if not Input.is_key_pressed(KEY_SHIFT):
				for x in selectedUnits.size():
					get_tree().call_group(selectedUnits[x], "outline", 0)
				var squad = caller.SQUAD
				get_tree().call_group("squad-" + caller.SQUAD, "outline", 1)
				# add this unit to selectedUnits
				selectedUnits = [caller]
			else:
				get_tree().call_group("squad-" + caller.SQUAD, "outline", 1)
				# shift is pressed, appending to selectedUnitssquad
				if caller not in selectedUnits:
					selectedUnits.append(caller)
					# prints("selectedUnits appended.", selectedUnits)
				else: 
					selectedUnits.erase(caller)
					# prints("Removed caller:", str(caller), "from selectedunits.", selectedUnits)
		elif event.button_index == 1 and Input.is_key_pressed(KEY_CTRL):
			"""
			Is CTRL pressed?
			"""
			get_tree().call_group("platoon-" + caller.PLATOON, "outline", 1)
			var addUnits = get_tree().get_nodes_in_group("platoon-" + caller.PLATOON)
			if not Input.is_key_pressed(KEY_SHIFT):
				selectedUnits = []
			for n in addUnits:
				var unitClass = n.get_class()
				if unitClass != "CharacterBody3D" and n not in selectedUnits:
					selectedUnits.append(n)
		# print(selectedUnits)

func unselect(caller, event, position):
	pass

func showMouseOver():
	pass
	
func hideMouseOver():
	pass

func _unhandled_input(event):
	if event is InputEventMouseButton \
	and event.button_index == 1:
	# TODO: Handle unselecting units by clicking anywhere else
		push_warning("Handle unselecting units by clicking anywhere else")


func showOrderLines() -> void:
	# TODO: Fix me
	pass

func hideOrderLines() -> void:
	# TODO: Fix me
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
