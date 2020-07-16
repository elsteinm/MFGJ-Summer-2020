extends "res://Source/Scripts/Objects/Character.gd"

onready var light = $Light2D
onready var player_collision = $LightArea/CollisionShape2D

export var brightness = 0 setget set_brightness

var in_light = false
var lights = []

var detectability = 0.1

#Just initalizes with preset stuff
func _init().(true, 500, 150):
	pass

func _enter_tree():
	emit_signal("switch_control", self) #Makes the Player Character the initial control
	PlayerInput.player_character = self

func _process(delta):
	if in_light == true:
		for shape in lights:
			var player_shape = player_collision.get_shape()
			var light_collision = shape_owner_get_owner(shape_find_owner(shape))
			var overlap = player_shape.collide_and_get_contacts(player_collision.get_transform(), light_collision.get_shape(), light_collision.get_transform())
	

func set_brightness(value):
	brightness = value
	light.energy = float(brightness)/100

func _on_LightArea_area_shape_entered(area_id, area, area_shape, self_shape):
	if area.get_collision_layer_bit(3) == true:
		in_light = true
		lights.append(area_shape)
	if area.get_collision_layer_bit(4) == true:
		pass

func _on_LightArea_area_shape_exited(area_id, area, area_shape, self_shape):
	pass # Replace with function body.
