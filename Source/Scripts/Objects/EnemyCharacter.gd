extends "res://Source/Scripts/Objects/Character.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var path_points : PoolVector2Array

func _process(delta):
	if is_active and is_controlled == false:
		if path_points.size() >0:
			move_on_path(delta)
		
func move_on_path(delta):
	var current_location = position
	for i in range(path_points.size()):
		pass
	#need to check whether the point is far enough. if it's close, remove it and move to next
	#if it isn't close, move and slide towards it.
	#	if current_location - path_points[0] > :
	#		pass
	#	else:
	#		path_points.remove(0)
