extends "res://Source/Scripts/Objects/Character.gd"

onready var light = $Light2D
onready var player_collision = $LightArea/CollisionShape2D
onready var light_area = $LightArea

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
		for light in lights:
			var player_polygon = player_collision.get_shape()
			var light_collision = light["collision"]
			var light_polygon = light_collision.get_shape()
#			var overlap_1 = polygon_1.collide_and_get_contacts(tri_1.get_global_transform(), light_polygon, light_collision.get_global_transform())
#			var space_state = get_world_2d().direct_space_state
#			for point in polygon_1.points:
#				var global_point = global_position + point.rotated(global_rotation)
#				var result = space_state.intersect_point(global_point, 32, [], light_area.collision_mask, true, true)
#				for object in result:
#					if object["collider"] == light["area"]:
#						overlap_1.append(global_point)
#			var vertices = PoolVector2Array(overlap_1)
#			var intersection = ConvexPolygonShape2D.new()
#			intersection.points = vertices
			if light_polygon is CircleShape2D:
				var rad = light_polygon.radius
				var temp_polygon = PoolVector2Array()
				var angle = 0
				while angle < 2*PI:
					var point = light_collision.get_global_position() + Vector2(rad*cos(angle), rad*sin(angle))
					temp_polygon.append(point)
					angle += 0.05*PI
				light_polygon = temp_polygon
			else:
				light_polygon = light_polygon.points
			var global_player_polygon = PoolVector2Array()
			for point in player_polygon.points:
				var global_point = global_position + point.rotated(global_rotation)
				global_player_polygon.append(global_point)
			var overlap = Geometry.intersect_polygons_2d(global_player_polygon, light_polygon)
			var area = Helper.get_polygon_area(overlap[0])
			var player_area = Helper.get_polygon_area(player_polygon.points)
			var a = area
#			var space_state = get_world_2d().direct_space_state
#			var query = Physics2DShapeQueryParameters.new()
#			query.shape_rid = player_polygon.get_rid()
#			query.collide_with_areas = true
#			query.exclude = [self]
#			query.collision_layer = light_area.collision_mask
#			var overlap = space_state.intersect_shape(query)
#			var a = overlap

func set_brightness(value):
	brightness = value
	light.energy = float(brightness)/100

func _on_LightArea_area_shape_entered(area_id, area, area_shape, self_shape):
	if area.get_collision_layer_bit(3) == true:
		in_light = true
		var shape_owner = area.shape_find_owner(area_shape)
		var light_shape = area.shape_owner_get_owner(shape_owner)
		var light = {
			"area": area,
			"collision": light_shape
		}
		lights.append(light)
	if area.get_collision_layer_bit(4) == true:
		pass

func _on_LightArea_area_shape_exited(area_id, area, area_shape, self_shape):
	pass # Replace with function body.
