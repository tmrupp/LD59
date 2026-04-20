extends CanvasLayer

@onready var retry_button : Button = $Control/MarginContainer/VBoxContainer/HBoxContainer2/TextureRect/Button
@onready var quit_button : Button = $Control/MarginContainer/VBoxContainer/HBoxContainer2/TextureRect2/Button2

@onready var score_value_label: Label = $Control/MarginContainer/VBoxContainer/HBoxContainer/TextureRect/MarginContainer/HBoxContainer/Label2
@onready var time_value_label : Label = $Control/MarginContainer/VBoxContainer/HBoxContainer/TextureRect2/MarginContainer/HBoxContainer/Label4

func _ready() -> void:
	retry_button.pressed.connect(func(): get_tree().reload_current_scene.call_deferred())
	quit_button.pressed.connect(get_tree().quit)
	
	hide()
