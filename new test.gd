extends "res://Source/Scripts/Level.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _process(delta):
	if Input.is_action_just_pressed("p_action"):
		var path = $Navigation2D.get_simple_path($EnemyCharacter.global_position,get_global_mouse_position(), false)
		$EnemyCharacter.path_points = path
		$EnemyCharacter.path_index = 0
