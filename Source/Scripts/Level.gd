extends Node2D

var objects : Array = []
var object_number = 0
var objects_dimmed = 0

func _init():
	Main.current_level = self
	PlayerInput.playing = true
func _ready():
	get_tree().call_group("enemy", "get_nav",$Navigation2D)
#Add object to objectives array
func add_object(o):
	object_number += 1
	objects.append(o)

#Remove object from objectives array
func remove_object(o):
	objects_dimmed += 1
	objects.erase(o)

func _exit_tree():
	queue_free()
