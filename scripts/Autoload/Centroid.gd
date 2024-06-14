class_name Centroid
extends Node2D

var tolerance = 1e-2

func calc(vertices : Array):
	var centroid = calculate_centroid(vertices)
	## print("Initial centroid:", centroid)
	
	var filtered_vertices = []
	for vertex in vertices:
		if not is_point_inside_polygon(vertex, vertices):
			filtered_vertices.append(vertex)

	centroid = calculate_centroid(filtered_vertices)
	## print("Representative center:", centroid)
	
	return centroid

func calculate_centroid(points, vector3 : float = 0.0):
	var centroid = Vector2.ZERO
	var count = points.size()
	
	if count == 0:
		return centroid
	
	for point in points:
		centroid += point
	
	centroid /= count
	if vector3 != 0.0:
		centroid.x = roundTo(centroid.x)
		centroid.y = vector3
		centroid.z = roundTo(centroid.y)
	centroid.x = roundTo(centroid.x)
	centroid.y = roundTo(centroid.y)
	return centroid

func roundTo(value : float, tolerance = tolerance):
	var newValue = float(
			String.num(
				value, 
				int(str(tolerance).reverse())
			)
		)
	return newValue

func is_point_inside_polygon(point, polygon, tolerance = tolerance):
	var count = polygon.size()
	var inside = false
	
	for i in range(count):
		var j = (i + 1) % count
		var pi = polygon[i]
		var pj = polygon[j]
		
		if abs(pi.y - point.y) < tolerance or abs(pj.y - point.y) < tolerance:
			if min(pi.x, pj.x) <= point.x and point.x <= max(pi.x, pj.x):
				inside = not inside
		elif ((pi.y > point.y) != (pj.y > point.y)) and \
			 (point.x < (pj.x - pi.x) * (point.y - pi.y) / (pj.y - pi.y) + pi.x):
			inside = not inside
	
	return inside

func is_polygon_clockwise(polygon):
	var count = polygon.size()
	var signed_area = 0.0
	
	for i in range(count):
		var j = (i + 1) % count
		var pi = polygon[i]
		var pj = polygon[j]
		signed_area += (pj.x - pi.x) * (pi.y + pj.y)
	
	return signed_area < 0

func orient_polygon_counterclockwise(polygon):
	if is_polygon_clockwise(polygon):
		polygon.invert()
	return polygon
