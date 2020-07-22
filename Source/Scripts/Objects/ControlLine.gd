tool
extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(Vector2) var extend_to setget set_extenstion
export(int) var width = 5
var points
var color_array
var rect_of_line
var angle_to_rotate = 0
onready var collision = $CollisionShape2D
# Called when the node enters the scene tree for the first time.
func _ready():
	color_array = PoolColorArray()
	color_array.append(Color(1,1,1))
	points = PoolVector2Array()
	rect_of_line = Rect2(Vector2.ZERO,Vector2.ZERO)
	for _i in range(4):
		points.append(Vector2(0,0))
	collision.shape.extents = Vector2(0,0)
func set_extenstion(value):
	extend_to = value
	if collision == null:
		collision = $CollisionShape2D
	if rect_of_line == null:
		rect_of_line = Rect2(Vector2.ZERO,Vector2.ZERO)
	if points == null:
		points = PoolVector2Array()
		for _i in range(4):
			points.append(Vector2(0,0))
	if color_array == null:
		color_array = PoolColorArray()
		color_array.append(Color(1,1,1))
	if value != Vector2.ZERO:
		var angle_to_point = position.angle_to_point(value)
#		points[0] = position + Vector2(1,0).rotated(angle_to_point + PI/2) * width/2
#		points[1] = position + Vector2(1,0).rotated(angle_to_point - PI/2) * width/2
#		points[2] = value + Vector2(1,0).rotated(angle_to_point - PI/2) * width/2
#		points[3] = value + Vector2(1,0).rotated(angle_to_point + PI/2) * width/2		
		rect_of_line.position = Vector2(0,-width/2.0) #+ Vector2.DOWN.rotated(angle_to_point + PI/2) * width/2

		rect_of_line.size = Vector2(-position.distance_to(value),width)
		angle_to_rotate = angle_to_point
#		rect_of_line.end = value + Vector2(1,0).rotated(angle_to_point - PI/2) * width/2
#		rotation = -angle_to_point
		if collision != null:
			collision.shape.extents = Vector2(position.distance_to(value)/2.0,width/2.0)
#			collision.position.y = position.distance_to(value)/2
#			collision.position.x = 0
			collision.rotation = angle_to_point
			collision.position = Vector2.LEFT.rotated(angle_to_point) * position.distance_to(value)/2
#	var angle_to_point = position.angle_to_point(value)
#	points[0] = position + Vector2(1,0).rotated(angle_to_point + PI/2) * width/2
#	points[1] = position + Vector2(1,0).rotated(angle_to_point - PI/2) * width/2
#	points[2] = value + Vector2(1,0).rotated(angle_to_point + PI/2) * width/2
#	points[3] = value + Vector2(1,0).rotated(angle_to_point + PI/2) * width/2
#	collision.shape.extents = Vector2(position.distance_to(value)/2,width/2)
#	collision.position.x = position.distance_to(value)/2
#	collision.rotation = angle_to_point
	else:
		rect_of_line.size = Vector2.ZERO
	update()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _draw():
	draw_set_transform(Vector2.ZERO,angle_to_rotate,Vector2(1,1))
	draw_rect(rect_of_line,Color(1,1,1))
