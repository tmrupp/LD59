extends Node3D

@onready var explosion_prefab = preload("res://Scenes/explosion.tscn")

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_SPACE):
		var new_explosion = explosion_prefab.instantiate()
		add_child(new_explosion)
		new_explosion.position = Vector3.ZERO
