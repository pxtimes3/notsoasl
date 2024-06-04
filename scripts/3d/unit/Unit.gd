# Unit as an entity on the battle map
class_name UnitEntity
extends Node3D

var unitEntityScene: PackedScene = load("res://scenes/3d/unit/Unit.tscn")
var unitMarkerScene : PackedScene = load("res://scenes/3d/unit/UnitMarker.tscn")

var UNITID : String = ""
var UNITTYPE : String = ""
var COMPANY : String = ""	# id of the company
var PLATOON : String = ""	# id of the platoon
var SQUAD : String = ""		# id of squad
var PLAYER : String = ""
var UNITEQUIPMENT : Dictionary = {
	"radio" : false,
}

func createUnitEntity(UnitID:String, UnitType:String, Company:String, Platoon:String, Squad:String, Player: String, UnitEquipment:Dictionary) -> UnitEntity:
	# var new_unitEntity = unitEntityScene.instantiate()
	self.UNITID = UnitID
	self.UNITTYPE = UnitType
	self.COMPANY = Company
	self.PLATOON = Platoon
	self.SQUAD = Squad
	self.PLAYER = Player
	self.UNITEQUIPMENT = UnitEquipment
	
	add_to_group("unit-"+UNITID)
	add_to_group("company-"+COMPANY)
	add_to_group("platoon-"+PLATOON)
	add_to_group("squad"+SQUAD)
	
	return self

func _ready():
	pass

## Gets the area occupied by the units children and returns the center point by 
## comparing distance between the children.
func getUnitCenter():
	var pos = []
	for n in self.get_children():
		if n is CharacterBody3D:
			var x = round(n.position.x * 100) / 100
			var z = round(n.position.z * 100) / 100
			pos.append([x,z])
			#print(n, n.global_position)
	print(pos)
	#print("Y: ", unitY.max(), " ", unitY.min())
	#var sum = unitY.reduce(func(accum, number): return (accum + number))
	#print(sum, " ", unitY.size(), " ", sum/unitY.size())
	
	var stool = SurfaceTool.new()
	stool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	stool.add_vertex(Vector3(0,0,-4))
	stool.add_vertex(Vector3(6,0,0))
	stool.add_vertex(Vector3(0,0,4))
	
	#stool.add_vertex(Vector3(2,0,0))
	#stool.add_vertex(Vector3(2,0,2))
	#stool.add_vertex(Vector3(0,0,2))
	
	var mesh = stool.commit()
	var m = MeshInstance3D.new()
	m.mesh = mesh
	
	self.add_child(m)
	
	### arraymesh
	#var vertices = PackedVector3Array()
	#vertices.push_back(Vector3(0, 0, 0))
	#vertices.push_back(Vector3(1, 0, 0))
	#vertices.push_back(Vector3(0, 0, 1))
#
	## Initialize the ArrayMesh.
	#var arr_mesh = ArrayMesh.new()
	#var arrays = []
	#arrays.resize(Mesh.ARRAY_MAX)
	#arrays[Mesh.ARRAY_VERTEX] = vertices
#
	## Create the Mesh.
	#arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	#var am = MeshInstance3D.new()
	#am.mesh = arr_mesh
	#
	#self.add_child(am)
	
	return 1
