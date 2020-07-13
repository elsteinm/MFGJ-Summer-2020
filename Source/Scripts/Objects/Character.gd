extends "res://Source/Scripts/Objects/ControllableObject.gd"

var acceleration
var max_speed
var TURN_SPEED = 0.5
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
	velocity = move_and_slide(velocity)
	rotation += (get_local_mouse_position().angle()+PI/2) *TURN_SPEED
