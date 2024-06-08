class_name Cell
extends Node

var h 
var y
var x
var d
var max

func _init(x, y, h, polygon):
	var PolyLabel = PolyLabel.new()
	h = h
	y = y
	x = x
	d = PolyLabel._point_to_polygon_distance(x, y, polygon)
	max = d + h * sqrt(2)

func __lt__(other):
	return self.max < other.max

func __lte__(other):
	return self.max <= other.max

func __gt__(other):
	return self.max > other.max

func __gte__(other):
	return self.max >= other.max

func __eq__(other):
	return self.max == other.max

