#	MIT License
#
#	Copyright (c) 2017 Michal Haták
#
#	Permission is hereby granted, free of charge, to any person obtaining a copy
#	of this software and associated documentation files (the "Software"), to deal
#	in the Software without restriction, including without limitation the rights
#	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#	copies of the Software, and to permit persons to whom the Software is
#	furnished to do so, subject to the following conditions:
#
#	The above copyright notice and this permission notice shall be included in all
#	copies or substantial portions of the Software.
#
#	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#	SOFTWARE.

class_name PolyLabel
extends Node2D

var inf : float = INF

func _point_to_polygon_distance(x : float, y : float, polygon):
	var inside : bool = false
	var min_dist_sq = inf
	
	for ring in polygon:
		var b = ring[-1]
		for a in ring:
			if ((a[1] > y) != (b[1] > y) and
				(x < (b[0] - a[0]) * (y - a[1]) / (b[1] - a[1]) + a[0])):
				inside = not inside
			
			min_dist_sq = min(min_dist_sq, _get_seg_dist_sq(x, y, a, b))
			b = a
	
	var result = sqrt(min_dist_sq)
	if not inside:
		return -result
	return result


func _get_seg_dist_sq(px, py, a, b):
	var x = a[0]
	var y = a[1]
	var dx = b[0] - x
	var dy = b[1] - y
	
	if dx != 0 or dy != 0:
		var t = ((px - x) * dx + (py - y) * dy) / (dx * dx + dy * dy)
		
		if t > 1:
			x = b[0]
			y = b[1]
		
		elif t > 0:
			x += dx * t
			y += dy * t
			
	dx = px - x
	dy = py - y

	return dx * dx + dy * dy


func _get_centroid_cell(polygon):
	
	var area = 0
	var x = 0
	var y = 0
	var points = polygon[0]
	var b = points[-1]  # prev
	for a in points:
		var f = a[0] * b[1] - b[0] * a[1]
		x += (a[0] + b[0]) * f
		y += (a[1] + b[1]) * f
		area += f * 3
		b = a
	if area == 0:
		return Cell.new(points[0][0], points[0][1], 0, polygon)
	return Cell.new(x / area, y / area, 0, polygon)

	pass


func polylabel(polygon, precision=1.0, debug = false, with_distance = false):
	# find bounding box
	var first_item = polygon[0][0]
	var min_x = first_item[0]
	var min_y = first_item[1]
	var max_x = first_item[0]
	var max_y = first_item[1]
	for p in polygon[0]:
		if p[0] < min_x:
			min_x = p[0]
		if p[1] < min_y:
			min_y = p[1]
		if p[0] > max_x:
			max_x = p[0]
		if p[1] > max_y:
			max_y = p[1]

	var width = max_x - min_x
	var height = max_y - min_y
	var cell_size = min(width, height)
	var h = cell_size / 2.0

	var cell_queue = []

	if cell_size == 0:
		if with_distance:
			return [[min_x, min_y], null]
		else:
			return [min_x, min_y]

	# cover polygon with initial cells
	var x = min_x
	while x < max_x:
		var y = min_y
		while y < max_y:
			var c = Cell.new(x + h, y + h, h, polygon)
			y += cell_size
			cell_queue.append([-c.max, Time.get_unix_time_from_system(), c])
		x += cell_size

	var best_cell = _get_centroid_cell(polygon)

	var bbox_cell = Cell.new(min_x + width / 2, min_y + height / 2, 0, polygon)
	if bbox_cell.d > best_cell.d:
		best_cell = bbox_cell

	var num_of_probes = cell_queue.size()
	while cell_queue.size() > 0:
		var cell = cell_queue.pop_front()

		if cell.d > best_cell.d:
			best_cell = cell

			if debug:
				print('found best {} after {} probes'.format(
					round(1e4 * cell.d) / 1e4, num_of_probes))

		if cell.max - best_cell.d <= precision:
			continue

		h = cell.h / 2
		var c = Cell.new(cell.x - h, cell.y - h, h, polygon)
		cell_queue.append([-c.max, Time.get_unix_time_from_system(), c])
		c = Cell.new(cell.x + h, cell.y - h, h, polygon)
		cell_queue.append([-c.max, Time.get_unix_time_from_system(), c])
		c = Cell.new(cell.x - h, cell.y + h, h, polygon)
		cell_queue.append([-c.max, Time.get_unix_time_from_system(), c])
		c = Cell.new(cell.x + h, cell.y + h, h, polygon)
		cell_queue.append([-c.max, Time.get_unix_time_from_system(), c])
		num_of_probes += 4

	if debug:
		print('num probes: {}'.format(num_of_probes))
		print('best distance: {}'.format(best_cell.d))
	if with_distance:
		return [[best_cell.x, best_cell.y], best_cell.d]
	else:
		return [best_cell.x, best_cell.y]
