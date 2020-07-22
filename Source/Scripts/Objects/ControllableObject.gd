extends KinematicBody2D

onready var sprite = $Sprite
onready var control_effect = $ControlEffect
onready var camera = $Camera2D
onready var light_area_collision = $LightArea/CollisionShape2D
onready var light = $Light2D

var freeze = false
var is_moveable = false
var strech_location = Vector2.ZERO setget set_strech_location
export var is_active = true setget set_active
export var is_controlled : bool setget set_control
export var radius_of_control = 256
var control_target = null setget set_control_target
var in_range = false
var control_state = false
signal switch_control(new_host) #Signals switching to this object

func _init(control = false, moveable = false):
	is_moveable = moveable
	is_active = true
	is_controlled = control

func _ready():
	$ControlEffect.set_material($ControlEffect.get_material().duplicate())
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
		Main.remove_object_from_level()

func _enter_tree():
	var _error = self.connect("switch_control", Main, "switch_player_host")
	Main.add_object_to_level()

func _physics_process(_delta):
	if is_controlled == true and is_active == true and control_state == false:
		move_marker()
		if $takeOverTween.is_active() == false:
			if in_range == true:
				var target = $marker.position
				target = target.clamped(radius_of_control)
				$controlCast.cast_to = target
				if $controlCast.get_collider() != null:
					if $controlCast.get_collider().is_active == true and $controlCast.get_collider().is_controlled == false:
						set_control_target($controlCast.get_collider())
				else:
					set_control_target(null)
			else:
				
				set_control_target(null)
	if control_state == true:
		set_strech_location(control_target.global_position)

func move_marker(mouse_control,move_vector = Vector2.ZERO,delta = 0):
	if mouse_control == true:
		$marker.position = get_local_mouse_position()
	else:
		$marker.position += move_vector * delta
	if global_position.distance_to($marker.global_position) < radius_of_control:
		$marker.modulate = Color(1,1,1)
		in_range = true
	else:
		$marker.modulate = Color(1,0,0)
		in_range = false
	$marker.rotation = -rotation
		
func make_target(make):
	if make == true:
		$Sprite.modulate = Color(0.113725, 0.027451, 0.329412)
	else:
		$Sprite.modulate = Color(1,1,1)

func set_control_target(value):
	if control_target != null and control_target != value:
		control_target.make_target(false)
		control_target = null
	if value != null:
		value.make_target(true)
		control_target = value
	

func _input(event):
	if is_controlled == true and is_active == true:
		if control_target != null and event.is_action_pressed("p_action"):
			start_take_over(control_target)
#			_on_takeOverTween_tween_completed()

func start_take_over(target):
#	$ControlEffect.scale.x = 0.5
	$ControlLine.visible = true
	$takeOverTween.interpolate_method(self,'set_strech_location',global_position,target.global_position,0.5)
	$takeOverTween.start()
	control_target.freeze = true
#	$ControlEffect.material.set_shader_param('need_strech',true)
	set_process(false)
#Sets the is_active variable
func set_active(value):
	is_active = value
	if is_active == false:
		sprite.modulate = Color.black #Turns the character dark
		set_process(false) #Turns off process so the object stops
		light.enabled = false
		light_area_collision.disabled = true
		Main.remove_object_from_level()
		$ControlEffect.visible = false
		$ControlLine.visible = false
		control_state = false

func _notification(what):
	match what:
		NOTIFICATION_PAUSED:
			$ControlEffect.visible = false

#Sets the is_controlled variable
func set_control(value):
	is_controlled = value
	if is_controlled == true:
		$ControlEffect.visible = true
		set_strech_location(Vector2.ZERO)
		$ControlLine.visible = false
		control_state = false
		freeze = false
		set_process(true)
		$marker.visible = true
		$Camera2D.current = true #Sets the camera to the current controlled object
	else:
		$ControlEffect.visible = true
		$marker.visible = false
		$Camera2D.current = false #Turns object's camera off when not controlled

func _exit_tree():
	queue_free()


func set_strech_location(value):
	value = to_local(value)
	$ControlLine.extend_to = value
#	$ControlEffect.material.set_shader_param('target_strech',value)
	strech_location = value
#	$Camera2D.position = (value)
	
func _on_takeOverTween_tween_completed(_object = null, _key = null):
	emit_signal('switch_control',control_target)
	control_state = true
#	$Camera2D.position = Vector2(0,0)
