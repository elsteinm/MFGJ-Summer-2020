extends Node

const FRICTION = 750 #Floor friction
const LEVELS = 2020 #Number of levels in the game

func get_polygon_area(points : PoolVector2Array):
	var i = 0
	var n = points.size()
	var sum = 0
	for point in points:
		var next = i+1
		if next == n:
			next = 0
		var next_point = points[next]
		var x_sum = next_point.x + point.x
		var y_sum = next_point.y - point.y
		sum += x_sum*y_sum
		i += 1
	return 0.5*abs(sum)
