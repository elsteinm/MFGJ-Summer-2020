extends "res://Source/Scripts/Objects/ControllableObject.gd"

var TURN_SPEED = 0.5

var acceleration
var max_speed
var velocity
#Initialize with characters speed and stuff
func _init(control = false, acc = 500, max_sp = 100).(control, true):
	acceleration = acc
	max_speed = max_sp
	
	velocity = Vector2.ZERO

func check_if_can_turn(angle_to_add):
	var tranform = get_transform()
	tranform = tranform.rotated(angle_to_add)
	return test_move(transform, Vector2.ZERO)

#Move the character with an input vector recieved from PlayerInput
func move(input, delta):
	if input != Vector2.ZERO: #If there is movement, do the moving calculations
		velocity = velocity.move_toward(input * max_speed, acceleration * delta)
	else: #Otherwise, slow down cause friction
		velocity = velocity.move_toward(Vector2.ZERO, Helper.FRICTION * delta)
	velocity = move_and_slide(velocity) #Move
	if marker != null and global_position.distance_to(marker.global_position) > 0.5:
		self.rotation += (get_angle_to(marker.global_position)+PI/2) *TURN_SPEED #Direction rotation

func set_rotation(value):
	if check_if_can_turn(value) == true:
		.set_rotation(value)
