extends Node

var control setget set_control
var control_queue = Array()

signal finish_level

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	control.move(input_vector, delta)
	
	if Input.is_action_just_pressed("p_turn_off"):
		turn_off()

func set_control(character):
	if character != null && !control_queue.has(character):
		if control != null:
			control.is_controlled = false
		control = character
		control.is_controlled = true
		control_queue.push_front(control)

func turn_off():
	if control != null:
		control.is_active = false
		control_queue.pop_front()
		if control_queue.empty():
			set_process(false)
			emit_signal("finish_level")
		else:
			set_control(control_queue.pop_front())
