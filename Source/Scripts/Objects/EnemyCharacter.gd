extends "res://Source/Scripts/Objects/Character.gd"

onready var tween = $Tween

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed = 0
var min_distance = 10
var path_points
var path_index = 0

func _init().(false, 500, 150):
	pass
func _physics_process(delta):
	#if the character isn't controlled by player and is active	
	if is_active == true and is_controlled == false:
		#if there is a path the character needs to go on
		if path_points != null and path_points.size()>0 and path_index < path_points.size():
			move_on_path(delta)
		
func move_on_path(delta):
	#move vector is target of movement
	var move_vector = path_points[path_index] - global_position
	#if we are close to next point, move to the next one
	if move_vector.length() < min_distance:
		path_index += 1
	else:
		#calculate new speed with accelration, maxed at max speed
		speed = clamp(speed + acceleration,0,max_speed)
		move_and_slide(move_vector.normalized() * speed)
		#turn to where we are going
		#TODO - smooth rotation
		look_at(path_points[path_index]+move_vector)
#repeated function to remove the addition of PI/2 in the rotation
func move(input, delta):
	if input != Vector2.ZERO: #If there is movement, do the moving calculations
		velocity = velocity.move_toward(input * max_speed, acceleration * delta)
	else: #Otherwise, slow down cause friction
		velocity = velocity.move_toward(Vector2.ZERO, Constants.FRICTION * delta)
	velocity = move_and_slide(velocity) #Move
	self.rotation += (get_local_mouse_position().angle()) *TURN_SPEED #Direction rotation

#		var facing_vector = to_global(Vector2(cos(rotation), sin(rotation)))
#		look_at(facing_vector.linear_interpolate(path_points[path_index], 0.1))
#	look_at(lerp(Vector2(cos(rotation), sin(rotation)), path_points[path_index] + move_vector.normalized(), 0.5))
#	var current_location = to_global(position)
#	animationTree.set("parameters/blend_position", vector)
#	for i in range(path_points.size()):
#		var next = to_global(path_points[0])
#	need to check whether the point is far enough. if it's close, remove it and move to next
#	if it isn't close, move and slide towards it.
#		if (next - current_location).length() > min_distance:
#			var direction = (next - current_location).normalized()
#			speed = clamp(speed+ acceleration,0,max_speed)
#			velocity = direction * speed
#			rotation += get_angle_to(next)
#			var actual_vel = move_and_slide(velocity)
#			print(global_rotation)
#			global_rotation = global_position.angle_to_point(next)
#			if check_if_can_turn(position.angle_to(next)):
#				global_rotation += position.angle_to(next)
#			break
#		else:
#			path_points.remove(0)
