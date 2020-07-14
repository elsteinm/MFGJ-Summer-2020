extends "res://Source/Scripts/Objects/Character.gd"

#Just initalizes with preset stuff
func _init().(true, 500, 150):
	pass

func _enter_tree():
	PlayerInput.control = self #Makes the Player Character the initial control
