tool
extends TileMap

export(bool) var generate = false setget generate_occlusion
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func generate_occlusion(_value):
	var used = get_used_rect()
	used.position = used.position - Vector2(4,4)
	used.size = used.size + Vector2(8,8)
	for i in range(used.size.x):
		for j in range(used.size.y):
			if get_cell(used.position.x + i,used.position.y + j) != 0:
				set_cell(i + used.position.x,used.position.y + j,1)
