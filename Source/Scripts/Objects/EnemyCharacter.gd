extends "res://Source/Scripts/Objects/Character.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed = 0
var min_distance = 10
var path_points
func _init().(false, 500, 150):
	pass
func _physics_process(delta):	
	if is_active == true and is_controlled == false:
		if path_points != null and path_points.size()>0:
			move_on_path(delta)
		
func move_on_path(delta):
	var current_location = to_global(position)
	for i in range(path_points.size()):
		var next = to_global(path_points[0])
	#need to check whether the point is far enough. if it's close, remove it and move to next
	#if it isn't close, move and slide towards it.
		if (next - current_location).length() > min_distance:
			var direction = (next - current_location).normalized()
			speed = clamp(speed+ acceleration,0,max_speed)
			velocity = direction * speed
		#	rotation += get_angle_to(next)
			var actual_vel = move_and_slide(velocity)

			#print(global_rotation)
			#global_rotation = global_position.angle_to_point(next)
#			if check_if_can_turn(position.angle_to(next)):
#				global_rotation += position.angle_to(next)
			break
		else:
			path_points.remove(0)
