extends Node2D

onready var ui = $PlayerUI
onready var player = $PlayerCharacter

var level_music = load("res://Resources/Audio/Music/Envision-Loop.ogg")

var object_number = 0
var objects_dimmed = 0
var progress = "0/1"

var enemies

var timer_ms = 0
var timer_sec = 0
var timer_min = 0
var time = "0:0:0"

func _init():
	Main.current_level = self
	PlayerInput.playing = true

func _ready():
	get_tree().call_group("enemy", "get_nav", $Navigation2D)
	enemies = get_tree().get_nodes_in_group("enemy")
	AudioPlayer.play_music(level_music)
	AudioPlayer.music_pitch = 0.8
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	ui.update_time(time)
	ui.update_progress(progress)
	
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
func add_object():
	object_number += 1
	progress = str(object_number) + "/" + str(objects_dimmed)

#Remove object from objectives array
func remove_object():
	objects_dimmed += 1
	progress = str(object_number) + "/" + str(objects_dimmed)
	ui.update_progress(progress)

func set_tutorial(command):
	ui.set_tutorial(command)

func _on_LevelTimer_timeout():
	timer_ms += 1
	if timer_ms > 99:
		timer_ms = 0
		timer_sec += 1
	if timer_sec > 59:
		timer_sec = 0
		timer_min +=1
	time = str(timer_min) + ":" + str(timer_sec) + ":" + str(timer_ms)
	ui.update_time(time)

func _exit_tree():
	queue_free()
