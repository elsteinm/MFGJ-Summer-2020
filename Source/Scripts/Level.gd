extends Node2D

var objects : Array = []
var object_number = 0
var objects_dimmed = 0

func _init():
	Main.current_level = self

func add_object(o):
	object_number += 1
	objects.append(o)

func remove_object(o):
	objects_dimmed += 1
	objects.erase(o)

#func _process(delta):
#	guard_test_function()

#func guard_test_function():
#	if Input.is_action_just_pressed("p_action"):
#		var path = $Navigation2D.get_simple_path($EnemyCharacter.get_global_position(),get_global_mouse_position(), false)
#		path.remove(0)
#		print(path)
#		$EnemyCharacter.path_points = path
#		$EnemyCharacter.path_index = 0
