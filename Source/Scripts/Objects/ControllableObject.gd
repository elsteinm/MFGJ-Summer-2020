extends KinematicBody2D

onready var sprite = $Sprite

export var is_active = true setget set_active
export var is_controlled = false setget set_control

signal switch_control(new_host) #Signals switching to this object

func _init(control):
	self.is_active = true
	self.is_controlled = control

func _input_event(_viewport, event, _shape_idx):
	if is_active == true:
		if event.is_action_pressed("p_action"): #When the object is pressed
			emit_signal("switch_control", self)

#Sets the is_active variable
func set_active(value):
	is_active = value
	if is_active == false:
		$Sprite.modulate = Color.black #Turns the character dark
		set_process(false) #Turns off process so the object stops

#Sets the is_controlled variable
func set_control(value):
	is_controlled = value
	if is_controlled == true:
		$Camera2D.current = true #Sets the camera to the current controlled object
	else:
		$Camera2D.current = false #Turns object's camera off when not controlled
