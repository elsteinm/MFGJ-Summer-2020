extends Node

var player_character
#var last_control
var control setget set_control #The object the player is currently controlling
var control_queue = Array() #The queue of previously controlled objects
var playing = false setget set_playing
var current_level
signal switch_control(new_host) #Switches control over to the new host
signal finish_level #Signals the player turning off the player character to finish the level


func _physics_process(delta):
	if playing == false:
		return
	var input_vector = Vector2.ZERO
	if control.is_moveable == true:
		#Gets the direction the player wants to move
		input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		if Settings.control_type == Settings.ControlType.KEYBOARD_MOUSE:
			input_vector.x += Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
			input_vector.y += Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")			
		input_vector = input_vector.normalized()
		control.move(input_vector, delta)
	current_level.move_camera(control.global_position)
	if Settings.control_type == Settings.ControlType.KEYBOARD:
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		current_level.move_marker(false,input_vector,delta)
	else:
		current_level.move_marker(true) 
#		if last_control != null:
#			last_control.set_strech_location(last_control.global_position.distance_to(control.global_position))
	#Turn off command
	if Input.is_action_just_pressed("p_turn_off"):
		if control != null and control.returning != null:
			turn_off()

func set_playing(value):
	playing = value
	if playing == false:
		pass
		control = null
		control_queue = Array()

#Sets the control variable
func set_control(character):
	if character != null && !control_queue.has(character):
		if control != null:
			control.is_controlled = false #Turn off previous object's control variable
#			last_control = control
		control = character #Set new object
		control.is_controlled = true
		if current_level != null:
			current_level.move_camera(control.global_position)
			current_level.get_node("Marker").global_position = control.global_position
		control_queue.push_front(control) #Push new object into our object queue

#Turns off the current object and switches to the last one
func turn_off():
	if control != null:
		control.is_active = false #Turn off object
		control_queue.pop_front() #Remove from queue
		if control_queue.empty(): #If we have nothing left in the queue
			set_process(false) #Turn off PlayerInput process
			emit_signal("finish_level") #Finish the level
		else:
			control_queue.front().reverse_control_line()
func move_camera(value):
	if current_level != null:
		current_level.move_camera(value)
func remove_first_after_return():
	emit_signal("switch_control", control_queue.pop_front()) #Set the new controlled object with the one before the object we just turned off
