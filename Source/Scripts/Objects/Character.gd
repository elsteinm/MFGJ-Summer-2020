extends "res://Source/Scripts/Objects/ControllableObject.gd"

var acceleration
var max_speed

var velocity

func _init(acc, max_sp):
	acceleration = acc
	max_speed = max_sp
	
	velocity = Vector2.ZERO

func move(input, delta):
	if input != Vector2.ZERO:
		velocity = velocity.move_toward(input * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, Constants.FRICTION * delta)
	rotation += (get_local_mouse_position().angle()+PI/2) *0.5
	velocity = move_and_slide(velocity)
