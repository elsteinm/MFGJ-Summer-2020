extends CanvasLayer

onready var time_label = $Panel/TimeLabel
onready var progress_label = $Panel/ProgressLabel

func update_time(time):
	time_label.text = time

func update_progress(progress):
	progress_label.text = progress
