extends Node

onready var music_player = $MusicPlayer
onready var sfx_player = $SFXPlayer

var music_bus
var sfx_bus

var music_pitch setget set_music_pitch

func _ready():
	music_bus = AudioServer.get_bus_index("MusicBus")
	sfx_bus = AudioServer.get_bus_index("SFXBus")
	self.music_pitch = 0.8

func play_music(music):
	music_player.stream = music
	music_player.play()

func stop_music():
	music_player.stop()

func play_effect(effect):
	sfx_player.stream = effect
	sfx_player.play()

func set_music_pitch(value):
	music_pitch = value
	music_player.pitch_scale = music_pitch
	var pitch_effect = AudioServer.get_bus_effect(music_bus, 0)
	pitch_effect.pitch_scale = float(1)/float(value)
