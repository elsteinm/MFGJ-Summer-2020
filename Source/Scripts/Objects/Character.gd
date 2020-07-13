extends "res://Source/Scripts/Objects/ControllableObject.gd"

var TURN_SPEED = 0.5

var acceleration
var max_speed
var velocity

#Initialize with characters speed and stuff
func _init(control, acc, max_sp).(control):
	acceleration = acc
	max_speed = max_sp
	
	velocity = Vector2.ZERO

<<<<<<< HEAD
func check_if_can_turn(angle_to_add):
	var tranform = get_transform()
	tranform = tranform.rotated(angle_to_add)
	return test_move(transform, Vector2.ZERO)
=======
#Move the character with an input vector recieved from PlayerInput
>>>>>>> 60454b7725b82b80e23e7b467e1d6bcbd11fa151
func move(input, delta):
	if input != Vector2.ZERO: #If there is movement, do the moving calculations
		velocity = velocity.move_toward(input * max_speed, acceleration * delta)
	else: #Otherwise, slow down cause friction
		velocity = velocity.move_toward(Vector2.ZERO, Constants.FRICTION * delta)
	velocity = move_and_slide(velocity) #Move
	self.rotation += (get_local_mouse_position().angle()+PI/2) *TURN_SPEED #Direction rotation
