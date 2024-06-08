class_name PolyLabelTests
extends Node2D

var polylabel = PolyLabel.new()

func _ready():
	print(test_short())

func test_short():
	#with open(cd + "/fixtures/short.json", "r") as f:
	var json_string = FileAccess.get_file_as_string("res://scripts/Autoload/PolyLabel/fixtures/short.json")
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_ARRAY:
			print(data_received) # Prints array
		else:
			print("Unexpected data")
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())

	print(json.data)
	var result = polylabel.polylabel(json.data)
	
	#	self.assertEqual(polylabel(short), [3317.546875, 1330.796875])
