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
#var c = 0
#func _process(delta: float) -> void:
	#c += 1
	#if int(c) % 50 == 0:
		#prints("SelectedUnits: ",selectedUnits)

func newUnitMarker(p := []):
	print(p)


## Returns the currently selected units, if any.
func getSelectedUnits() -> Array:
	if selectedUnits.size() > 0:
		return selectedUnits
		
	return []


func inputHandled() -> void:
	push_warning("Input should noe be handled")
	get_node(".").get_viewport().set_input_as_handled()

## Handles selection of units. Stores them in the selectedUnits array.
## caller: MyUnitEntity
## UnitEntity
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
				for x : UnitEntity in selectedUnits:
					x._toggleSelected()
				selectedUnits = []
				var squad = caller.SQUAD
				get_tree().call_group("squad-" + caller.SQUAD, "outline", 1)
				caller._toggleSelected()
				# add this unit to selectedUnits
				selectedUnits = [caller]
				inputHandled()
				
			elif Input.is_key_pressed(KEY_SHIFT):
				get_tree().call_group("squad-" + caller.SQUAD, "outline", 1)
				caller._toggleSelected()
				# shift is pressed, appending to selectedUnitssquad
				if caller not in selectedUnits:
					selectedUnits.push_front(caller)
					# prints("selectedUnits appended.", selectedUnits)
				else: 
					selectedUnits.erase(caller)
					# prints("Removed caller:", str(caller), "from selectedunits.", selectedUnits)
				inputHandled()
				
		elif event.button_index == 1 and Input.is_key_pressed(KEY_CTRL):
			"""
			Is CTRL pressed?
			"""
			print(caller.get_groups())
			var addUnits : Array
			if caller.UNITTYPE == "company-hq":
				addUnits = get_tree().get_nodes_in_group("company-" + caller.COMPANY)
			else:
				addUnits = get_tree().get_nodes_in_group("platoon-" + caller.PLATOON)
			var unitsToSelect : Array
			for n in addUnits:
				# sortera bort allt som inte är units
				var unitClass = n.get_class()
				if unitClass != "CharacterBody3D":
					unitsToSelect.append(n)
			
			multiUnitSelection(unitsToSelect)


func multiUnitSelection(units : Array) -> void:
	## If KEY_SHIFT is pressed add the new units and dont empty selectedunits
	## 
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
		print(event)
		print(get_mouse_pos())
		push_warning("Handle unselecting units by clicking anywhere else")

func get_mouse_pos():
	var space_state = get_parent().get_world_3d().get_direct_space_state()
	var mouse_position = get_viewport().get_mouse_position()
	var camera = get_tree().root.get_camera_3d()
	
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_position) * 1000
		
	var params = PhysicsRayQueryParameters3D.new()
	params.from = ray_origin
	params.to = ray_end
	#params.collision_mask = 2
	params.exclude = []
	
	return space_state.intersect_ray(params)


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
