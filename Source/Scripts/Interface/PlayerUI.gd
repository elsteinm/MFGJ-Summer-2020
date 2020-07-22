extends CanvasLayer

onready var time_label = $TimeLabel
onready var progress_label = $ProgressLabel
onready var tutorial_container = $TutorialContainer

func update_time(time):
	time_label.text = time

func update_progress(progress):
	progress_label.text = progress

func set_tutorial(commands):
	if commands.empty() != true:
		for command in commands:
			var control = Settings.controls[command]
			var control_label = Label.new()
			control_label.text = control
			control_label.align = Label.ALIGN_CENTER
			control_label.valign = Label.ALIGN_CENTER
			tutorial_container.add_child(control_label)
			var com_name = Helper.command_names[command]
			var command_label = Label.new()
			command_label.text = com_name
			command_label.align = Label.ALIGN_CENTER
			command_label.valign = Label.ALIGN_CENTER
			tutorial_container.add_child(command_label)
		tutorial_container.set_anchors_and_margins_preset(Control.PRESET_CENTER_BOTTOM)
