## Handles selection of units
# class_name Selection
extends Node

var selectedUnits : Array ## Contains currently selected unit/s in the form of [class UnitEntity] objects.
var unitGroups : Array ## Contains all the groups created during unit-creation. Currently not in use.

func _ready():
	PubSub.unit_input_left_click.connect(select.bind(1))
	PubSub.unit_input_right_click.connect(select.bind(2))
	PubSub.unit_input_event.connect(select.bind())


## Returns the currently selected units array.
func getSelectedUnits() -> Array:
	if selectedUnits.size() > 0:
		return selectedUnits
		
	return []


## Marks input as handled. Didn't seem to work. 
## @experimental
func inputHandled() -> void:
	push_warning("Input should now be handled")
	get_node(".").get_viewport().set_input_as_handled()

## Handles selection of units and stores or removes them from the selectedUnits array.[br]
## 
## [br][param caller]: [UnitEntity] => The unit that called (or had a child initialize the call).
## [br][param event]: [InputEvent] => To eventually check for double clicks.
## [br][param button]: [int] => Corresponds to the button_index/_mask.
func select(caller : UnitEntity, event : InputEvent, button : int) -> void:
	if button == 1 \
	and not Input.is_key_pressed(KEY_CTRL) \
	and not event.double_click:
		var _groups = caller.get_groups()
		# if not SHIFT, then unselect other units and select this unit
		if not Input.is_key_pressed(KEY_SHIFT):
			# unselect everyone else
			for x : UnitEntity in selectedUnits:
				x.unSelectUnit()
			# empty selectedUnits
			selectedUnits = []
			# add our unit
			if caller not in selectedUnits:
				selectedUnits.append(caller)
				caller.selectUnit()
			
		elif Input.is_key_pressed(KEY_SHIFT):
			# shift is pressed, appending to selectedUnits
			if caller not in selectedUnits:
				selectedUnits.push_front(caller)
				caller.selectUnit()
			else: 
				selectedUnits.erase(caller)
				caller.unSelectUnit()
			inputHandled()
			
	elif Input.is_key_pressed(KEY_CTRL):
		"""
		Is CTRL pressed?
		"""
		# print(caller.get_groups())
		var addUnits : Array
		if caller.UNITTYPE == "company-hq":
			addUnits = get_tree().get_nodes_in_group("company-" + caller.COMPANY)
		else:
			addUnits = get_tree().get_nodes_in_group("platoon-" + caller.PLATOON)
		var unitsToSelect : Array = []
		for n in addUnits:
			# sortera bort allt som inte är units
			var unitClass = n.get_class()
			if unitClass != "CharacterBody3D":
				unitsToSelect.append(n)
		
		multiUnitSelection(unitsToSelect)
	
	Log.debug(self, "selectedUnits: " + Log.array_to_string(selectedUnits))


## Handles the selection of multiple units when CTRL/CTRL+SHIFT is pressed[br]
## Adds them to, or removes them from, [member self.selectedUnits].[br]
##
## [br][param units] Contains a number of units to be added 
func multiUnitSelection(units : Array) -> void:
	## If KEY_SHIFT is pressed add the new units and dont empty selectedunits
	if Input.is_key_pressed(KEY_SHIFT):
		for n : UnitEntity in units:
			if n not in selectedUnits:
				selectedUnits.append(n)
				n.selectUnit()
	else:
		# empty selectedUnits
		for n : UnitEntity in selectedUnits:
			selectedUnits.erase(n)
			n.unSelectUnit()
		for n : UnitEntity in units:
			if n not in selectedUnits:
				selectedUnits.append(n)
				n.selectUnit()
		
	inputHandled()

## Removes an array of [UnitEntiy] from the selectedUnits array.
func unselect(_params : Array = []) -> void:
	for n : UnitEntity in selectedUnits:
		n.unSelectUnit()
	selectedUnits.clear()

# deprecated
#func showMouseOver():
	#pass
	

#func hideMouseOver():
	#pass


#func get_mouse_pos():
	#var space_state = get_parent().get_world_3d().get_direct_space_state()
	#var mouse_position = get_viewport().get_mouse_position()
	#var camera = get_tree().root.get_camera_3d()
	#
	#var ray_origin = camera.project_ray_origin(mouse_position)
	#var ray_end = ray_origin + camera.project_ray_normal(mouse_position) * 1000
		#
	#var params = PhysicsRayQueryParameters3D.new()
	#params.from = ray_origin
	#params.to = ray_end
	#params.collision_mask = 2
	#params.exclude = []
	
	#return space_state.intersect_ray(params)
