extends "res://Source/Scripts/Objects/Character.gd"

onready var light = $Light2D
onready var player_collision = $LightArea/CollisionShape2D
onready var light_area = $LightArea
onready var raycast = $LightCast

var global_player_polygon
var player_area

export var brightness = 0 setget set_brightness

var in_light = false
var lights = []
var in_red_light = false
var red_lights = []

var detectability = 0.25

signal dead

#Just initalizes with preset stuff
func _init().(true, 500, 150):
	pass

func _ready():
	var player_polygon = player_collision.get_shape()
	global_player_polygon = PoolVector2Array()
	for point in player_polygon.points:
		var global_point = global_position + point.rotated(global_rotation)
		global_player_polygon.append(global_point)
	player_area = Helper.get_polygon_area(player_polygon.points)

func _enter_tree():
	emit_signal("switch_control", self) #Makes the Player Character the initial control
	PlayerInput.player_character = self

func _process(_delta):
	detectability = 0.45 + brightness
	if in_light == true:
		for light_shape in lights:
			var overlap = calculate_intersect(light_shape)
			if overlap != null:
				var area = Helper.get_polygon_area(overlap)
				var ratio = float(player_area)/float(area)
				detectability += ratio/2
				if red_lights.has(light):
					brightness += ratio/10

func calculate_intersect(light_shape):
	var light_polygon = light_shape.get_shape()
	var global_shape = PoolVector2Array()
	if light_polygon is CircleShape2D:
		var rad = light_polygon.radius
		var angle = 0
		while angle < 2*PI:
			var point = light_shape.get_global_position() + Vector2(rad*cos(angle), rad*sin(angle))
			global_shape.append(point)
			angle += 0.05*PI
	else:
		for point in light_polygon.points:
			var global_point = light_shape.get_global_position() + point.rotated(light_shape.get_global_rotation())
			global_shape.append(global_point)
		light_polygon = light_polygon.points
	var overlap = Geometry.intersect_polygons_2d(global_player_polygon, global_shape)
	if overlap.empty():
		return null
	return overlap[0]

func set_brightness(value):
	brightness = value
	light.energy = float(brightness)/100
	if brightness > 1:
		emit_signal("dead")

func _on_LightArea_area_shape_entered(_area_id, area, area_shape, _self_shape):
	var shape_owner = area.shape_find_owner(area_shape)
	var light_shape = area.shape_owner_get_owner(shape_owner)
	var space = get_world_2d().direct_space_state
	var result = space.intersect_ray(global_position, light_shape.get_global_position(), [self], raycast.collision_mask)
	if result["collider"].is_a_parent_of(light_shape):
		in_light = true
		lights.append(light_shape)
		if area.get_collision_layer_bit(4) == true:
			in_red_light = true
			red_lights.append(light_shape)

func _on_LightArea_area_shape_exited(_area_id, area, area_shape, _self_shape):
	var shape_owner = area.shape_find_owner(area_shape)
	var light_shape = area.shape_owner_get_owner(shape_owner)
	if lights.has(light_shape):
		lights.erase(light_shape)
		if lights.empty() == true:
			in_light = false
		if area.get_collision_layer_bit(4) == true:
			red_lights.erase(light_shape)
			if red_lights.empty() == true:
				in_red_light = false
