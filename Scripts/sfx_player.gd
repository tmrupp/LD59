class_name SFXPlayer
extends Node

static var instance : SFXPlayer = null

@onready var explosion: AudioStreamPlayer = $Explosion
@onready var key_press_1: AudioStreamPlayer = $KeyPress1
@onready var key_press_2: AudioStreamPlayer = $KeyPress2

func _ready() -> void:
	instance = self

static func get_instance():
	return instance

func play_explosion():
	explosion.play()

func play_key_press():
	key_press_1.pitch_scale = randf_range(1.0, 1.5)
	key_press_1.play()
