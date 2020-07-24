extends Node

var MainMenu = preload("res://Source/Scenes/Interface/MainMenu.tscn")
var LevelSelectMenu = preload("res://Source/Scenes/Interface/LevelSelectMenu.tscn")
var SettingsMenu = preload("res://Source/Scenes/Interface/SettingsMenu.tscn")
var PauseScreen = preload("res://Source/Scenes/Interface/PauseScreen.tscn")
var LevelFinishedScreen = preload("res://Source/Scenes/Interface/LevelFinishedScreen.tscn")
var GameOverScreen = preload("res://Source/Scenes/Interface/GameOverScreen.tscn")

var end_level_effect = load("res://Resources/Audio/SFX/Envision-EndEffect.wav")

const FRICTION = 750 #Floor friction
const LEVELS = 15 #Number of levels in the game

enum Commands {
	DIM = 0,
	CHANGE = 1,
	MOVE = 2,
	AIM = 3,
	PAUSE = 4
}
var command_names = Commands.keys()

var level_tutorials = {
	1: [Commands.DIM],
	2: [Commands.DIM, Commands.AIM, Commands.CHANGE],
	3: [Commands.AIM, Commands.CHANGE],
	4: [Commands.MOVE],
	5: [],
	6: [],
	7: [],
	8: [],
	9: [],
	10: [],
	11: [],
	12: [],
	13: [],
	14: [],
	15: []
}

func get_polygon_area(points : PoolVector2Array):
	var i = 0
	var n = points.size()
	var sum = 0
	for point in points:
		var next = i+1
		if next == n:
			next = 0
		var next_point = points[next]
		var x_sum = next_point.x + point.x
		var y_sum = next_point.y - point.y
		sum += x_sum*y_sum
		i += 1
	return 0.5*abs(sum)
