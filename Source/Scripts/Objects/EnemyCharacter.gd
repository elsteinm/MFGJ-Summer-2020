extends "res://Source/Scripts/Objects/Character.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed = 0
var min_distance = 10
var path_points
func _init().(false, 500, 150):
	pass
func _process(delta):
	
	if is_active == true and is_controlled == false:
		if path_points != null and path_points.size()>0:
			move_on_path(delta)
		
func move_on_path(delta):
	var current_location = position
	for i in range(path_points.size()):
		var next = to_local(path_points[0])
	#need to check whether the point is far enough. if it's close, remove it and move to next
	#if it isn't close, move and slide towards it.
		if (current_location - next).length() > min_distance:
			var direction = (current_location-next).normalized()
			speed = clamp(speed+ acceleration,0,max_speed)
			velocity = direction * speed
			move_and_slide(velocity)
			break
		else:
			path_points.remove(0)
