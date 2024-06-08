extends Node

enum DIR {
	XMAX = 1, XMIN = 2, ZMAX = 3, ZMIN = 4, YMAX = 5, YMIN = 6
}


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


## Sorts an array with Vector3s by directions
#
func sortV3Array(array : Array, direction : DIR, num : int = 0, y : int = 0):
	if direction == DIR.XMAX:
		array.sort_custom(func(a, b): return a.x > b.x)
	if direction == DIR.XMIN:
		array.sort_custom(func(a, b): return a.x < b.x)
		
	if direction == DIR.ZMAX:
		array.sort_custom(func(a, b): return a.z > b.z)
	if direction == DIR.ZMIN:
		array.sort_custom(func(a, b): return a.z < b.z)
	
	if direction == DIR.YMAX:
		array.sort_custom(func(a, b): return a.y > b.y)
	if direction == DIR.YMIN:
		array.sort_custom(func(a, b): return a.y < b.y)
	
	if y > 0:
		for n in array:
			n.y = y
	
	if num == 1:
		return array[0]
	if num > 1:
		return array.slice(0, num)
		
	return array


func centroidFromVector3Nodes(nodes : Array):
	## find inner nodes
	var xmax = sortV3Array(nodes, 1, 1)
	var xmin = sortV3Array(nodes, 1, 1)
	var zmax = sortV3Array(nodes, 5, 1)
	var zmin = sortV3Array(nodes, 6, 1)
	pass


"""
#include <iostream>

using namespace std;

struct Point2D
{
	double x;
	double y;
};

Point2D compute2DPolygonCentroid(const Point2D* vertices, int vertexCount)
{
	Point2D centroid = {0, 0};
	double signedArea = 0.0;
	double x0 = 0.0; // Current vertex X
	double y0 = 0.0; // Current vertex Y
	double x1 = 0.0; // Next vertex X
	double y1 = 0.0; // Next vertex Y
	double a = 0.0;  // Partial signed area

	int lastdex = vertexCount-1;
	const Point2D* prev = &(vertices[lastdex]);
	const Point2D* next;

	// For all vertices in a loop
	for (int i=0; i<vertexCount; ++i)
	{
		next = &(vertices[i]);
		x0 = prev->x;
		y0 = prev->y;
		x1 = next->x;
		y1 = next->y;
		a = x0*y1 - x1*y0;
		signedArea += a;
		centroid.x += (x0 + x1)*a;
		centroid.y += (y0 + y1)*a;
		prev = next;
	}

	signedArea *= 0.5;
	centroid.x /= (6.0*signedArea);
	centroid.y /= (6.0*signedArea);

	return centroid;
}

int main()
{
	Point2D polygon[] = {{0.0,0.0}, {0.0,10.0}, {10.0,10.0}, {10.0,0.0}};
	size_t vertexCount = sizeof(polygon) / sizeof(polygon[0]);
	Point2D centroid = compute2DPolygonCentroid(polygon, vertexCount);
	std::cout << "Centroid is (" << centroid.x << ", " << centroid.y << ")\n";
}
"""
