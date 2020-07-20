extends KinematicBody2D

onready var sprite = $Sprite
onready var control_effect = $ControlEffect
onready var camera = $Camera2D
onready var light_area_collision = $LightArea/CollisionShape2D
onready var light = $Light2D

var is_moveable = false
var list_of_targets = []
export var is_active = true setget set_active
export var is_controlled : bool setget set_control
export var radius_of_control = 64
var control_target = null setget set_control_target
signal switch_control(new_host) #Signals switching to this object

func _init(control = false, moveable = false):
	is_moveable = moveable
	is_active = true
	is_controlled = control

func _ready():
	if is_controlled == true:
		$ControlEffect.visible = true
		$Camera2D.current = true #Sets the camera to the current controlled object
	else:
		$ControlEffect.visible = false
		$Camera2D.current = false #Turns object's camera off when not controlled
	
	if is_active == false:
		sprite.modulate = Color.black #Turns the character dark
		set_process(false) #Turns off process so the object stops
		light.enabled = false
		light_area_collision.disabled = true
		Main.remove_object_from_level(self)

func _enter_tree():
	var _error = self.connect("switch_control", Main, "switch_player_host")
	Main.add_object_to_level(self)

func _physics_process(delta):
	if is_controlled == true and is_active == true:
		move_marker()
		var target = $marker.position.clamped(128)
		
		$controlCast.cast_to = $marker.position
		if $controlCast.get_collider() != null:
			set_control_target($controlCast.get_collider())
			

func move_marker():
	if Main.mouse_control == true:
		$marker.position = get_local_mouse_position()
	else:
		if Input.is_action_pressed("ui_right"):
			$marker.position.x += 2
		if Input.is_action_pressed("ui_left"):
			$marker.position.x -= 2
		if Input.is_action_pressed("ui_down"):
			$marker.position.y += 2
		if Input.is_action_pressed("ui_up"):
			$marker.position.y -= 2
	

func make_target(make):
	if make == true:
		$Sprite.material.set_shader_param('activated',true)
	else:
		$Sprite.material.set_shader_param('activated',false)

func set_control_target(value):
	if control_target != null and control_target != value:
		control_target.make_target(false)
	if value != null:
		value.make_target(true)
		control_target = value
	

func _input(event):
	if is_controlled == true and is_active == true:
		if control_target != null and event.is_action_pressed("p_action"):
			emit_signal('switch_control',control_target)
#func _input_event(_viewport, event, _shape_idx):
#	if is_active == true:
#		if event.is_action_pressed("p_action"): #When the object is pressed
#			emit_signal("switch_control", self)

#Sets the is_active variable
func set_active(value):
	is_active = value
	if is_active == false:
		sprite.modulate = Color.black #Turns the character dark
		set_process(false) #Turns off process so the object stops
		light.enabled = false
		light_area_collision.disabled = true
		Main.remove_object_from_level(self)

func _notification(what):
	match what:
		NOTIFICATION_PAUSED:
			$ControlEffect.visible = false

#Sets the is_controlled variable
func set_control(value):
	is_controlled = value
	if is_controlled == true:
		$ControlEffect.visible = true
		$Camera2D.current = true #Sets the camera to the current controlled object
	else:
		$ControlEffect.visible = false
		$Camera2D.current = false #Turns object's camera off when not controlled

func _exit_tree():
	queue_free()


func _on_controlArea_body_entered(body):
	list_of_targets.append(body)


func _on_controlArea_body_exited(body):
	list_of_targets.remove(body)
