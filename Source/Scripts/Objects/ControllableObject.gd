extends KinematicBody2D

export var is_active = true setget set_active
export var is_controlled = false setget set_control

signal switch_control(new_host)

func _init(control):
	self.is_active = true
	self.is_controlled = control

func _input_event(_viewport, event, _shape_idx):
	if is_active == true:
		if event.is_action_pressed("p_action"):
			emit_signal("switch_control", self)

func set_active(value):
	is_active = value
	if is_active == false:
		$Sprite.modulate = Color.black
		set_process(false)

func set_control(value):
	is_controlled = value
	if is_controlled == true:
		$Camera2D.current = true
	else:
		$Camera2D.current = false
