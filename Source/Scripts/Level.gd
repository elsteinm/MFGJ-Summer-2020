extends Node2D

func _init():
	var _error
	_error = PlayerInput.connect("finish_level", self, "finish")

func _ready():
	var PlayerCharacter = load("res://Source/Scenes/Objects/PlayerCharacter.tscn")
	var p1 = PlayerCharacter.instance()
	var p2 = PlayerCharacter.instance()
	p2.is_controlled = false
	p1.connect("switch_control", self, "switch_player_host")
	p2.connect("switch_control", self, "switch_player_host")
	
	self.add_child(p1)
	self.add_child(p2)
	PlayerInput.control = p1

func switch_player_host(new_host):
	PlayerInput.control = new_host

func finish():
	PlayerInput.queue_free()
	self.queue_free()
