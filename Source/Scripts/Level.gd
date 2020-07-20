extends Node2D

onready var player = $PlayerCharacter
onready var tween = $Tween

var level_music = load("res://Resources/Audio/Music/Kevin MacLeod - Envision.ogg")

var objects : Array = []
var object_number = 0
var objects_dimmed = 0

var enemies

func _init():
	Main.current_level = self
	PlayerInput.playing = true

func _ready():
	get_tree().call_group("enemy", "get_nav", $Navigation2D)
	enemies = get_tree().get_nodes_in_group("enemy")

func _process(_delta):
	var shortest_distance = 150
	for enemy in enemies:
		if enemy.is_active == true:
			var distance_from_player = player.global_position.distance_to(enemy.global_position)
			if distance_from_player < shortest_distance:
				shortest_distance = distance_from_player
	var pitch = 0.8 + (float(150 - shortest_distance)/float(100))*0.7
	AudioPlayer.music_pitch = pitch

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
