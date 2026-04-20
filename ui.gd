extends CanvasLayer

@onready var volume_slider = $Control/MarginContainer/HBoxContainer/VBoxContainer2/TextureRect/MarginContainer/VBoxContainer/HSlider

@onready var start_resume_button = $Control/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2/TextureRect/MarginContainer/VBoxContainer/Button
@onready var restart_button = $Control/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2/TextureRect/MarginContainer/VBoxContainer/Button2
@onready var quit_button = $Control/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2/TextureRect/MarginContainer/VBoxContainer/Button3

func toggle ():
	start_resume_button.text = "Resume"

	self.visible = not self.visible
	print("hi")
	if self.visible:
		$"..".process_mode = Node.PROCESS_MODE_DISABLED
	else:
		$"..".process_mode = Node.PROCESS_MODE_INHERIT

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle()
		
func restart ():
	get_tree().reload_current_scene.call_deferred()
	
func volume(_x=true):
	var val = volume_slider.value/100
	print(val)
	$"../Music".volume_linear = val
	
func game_end():
	restart_button.show()
	start_resume_button.hide()
	toggle()

func _ready() -> void:
	start_resume_button.pressed.connect(toggle)
	quit_button.pressed.connect(get_tree().quit)
	restart_button.pressed.connect(restart)

	restart_button.hide()

	$"..".process_mode = Node.PROCESS_MODE_DISABLED
	volume_slider.drag_ended.connect(volume)
	volume_slider.value = 25
	volume()
