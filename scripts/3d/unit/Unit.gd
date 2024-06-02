# Unit as an entity on the battle map
class_name UnitEntity
extends Node3D

var unitEntityScene: PackedScene = load("res://scenes/3d/unit/Unit.tscn")
var unitMarkerScene : PackedScene = load("res://scenes/3d/unit/UnitMarker.tscn")

var UnitID : String = ""
var UnitType : String = ""
var Company : String = ""	# id of the company
var Platoon : String = ""	# id of the platoon
var Fireteam : String = ""	# id of fireteam if applicable
var Player : String = ""
var UnitEquipment : Dictionary = {
	"radio" : false,
}

func createUnitEntity(UnitID:String, UnitType:String, Company:String, Platoon:String, Fireteam:String, Player: String, UnitEquipment:Dictionary) -> UnitEntity:
	# var new_unitEntity = unitEntityScene.instantiate()
	self.UnitID = UnitID
	self.UnitType = UnitType
	self.Company = Company
	self.Platoon = Platoon
	self.Fireteam = Fireteam
	self.Player = Player
	self.UnitEquipment = UnitEquipment
	#var unitmarker = get_node("UnitMarker")
	
	return self
