extends "res://Source/Scripts/Objects/Character.gd"

export var health = 50

#Just initalizes with preset stuff
func _init().(true, 500, 150):
	pass

func _enter_tree():
	emit_signal("switch_control", self) #Makes the Player Character the initial control
