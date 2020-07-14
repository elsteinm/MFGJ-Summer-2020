extends Node2D

var objects : Array = []

func _init():
	Main.current_level = self
	var _error
	_error = PlayerInput.connect("finish_level", self, "check_objectives")

func add_object(o):
	objects.append(o)

func remove_object(o):
	objects.erase(o)

func check_objectives():
	if objects.empty() == true:
		return true
	return false

#func _process(delta):
#	guard_test_function()

#func guard_test_function():
#	if Input.is_action_just_pressed("p_action"):
#		var path = $Navigation2D.get_simple_path($EnemyCharacter.get_global_position(),get_global_mouse_position(), false)
#		path.remove(0)
#		print(path)
#		$EnemyCharacter.path_points = path
#		$EnemyCharacter.path_index = 0
