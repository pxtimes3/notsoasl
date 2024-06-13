extends Node

## Looks for needle in a haystack filled with Vector3
#
func findInVector3Array(needle : float, haystack : Array, dimension = null):
	for n in haystack:
		if dimension != null:
			if n[dimension] == needle:
				return n
		else:
			if n.x == needle:
				return n
			if n.y == needle:
				return n
			if n.z == needle:
				return n


func compute2DPolygonCentroid(vertices : Array):
	var vertexCount := vertices.size()
	var centroid := Vector2.ZERO
	var signedArea := 0.0
	var x0 := 0.0	# current vertex X
	var y0 := 0.0	# current vertex Y
	var x1 := 0.0   # next vertex X
	var y1 := 0.0	# next vertex Y
	var a  := 0.0	# partial signed area
	
	var lastdex := vertexCount - 1
	# const Point2D* prev = &(vertices[lastdex]);
	var prev = vertices[vertices.size() - 1]
	var next 
	
	for i in vertexCount:
		# next = &(vertices[i]);
		next = vertices[i]
		x0 = prev.x
		# prints(i, "x0", x0)
		y0 = prev.y
		# prints(i, "y0", y0)
		x1 = vertices[i].x
		# prints(i, "x1", x1)
		y1 = vertices[i].y
		# prints(i, "y1", y1)
		a = (x0 * y1) - (x1 * y0);
		# prints(i, "a", a)
		signedArea += a;
		# prints(i, "signedArea",signedArea)
		centroid.x += (x0 + x1) * a;
		# prints(i, "centroid.x",centroid.x)
		centroid.y += (y0 + y1) * a;
		# prints(i, "centroid.y",centroid.y)
		prev = next;
		
	signedArea = signedArea * 0.5;
	centroid.x = centroid.x / (6 * signedArea);
	centroid.y = centroid.y / (6 * signedArea);
	
	# prints("signedArea", signedArea)
	# prints("centroid", centroid)

	return centroid;
