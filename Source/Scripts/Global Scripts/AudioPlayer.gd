extends Node

onready var music_player = $MusicPlayer
onready var sfx_player = $SFXPlayer

func play_music(music):
	music_player.stream = music
	music_player.pitch_scale = 0.8
	music_player.play()

func stop_music():
	music_player.stop()

func play_effect(effect):
	sfx_player.stream = effect
	sfx_player.play()
