extends Node3D

@onready var camera = $Camera3D

const mouse_sensitivity_vert : float = 0.001
const mouse_sensitivity_horiz : float = 0.0005

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity_horiz)
		camera.rotate_x(-event.relative.y * mouse_sensitivity_vert)

		rotation.y = clampf(rotation.y, -deg_to_rad(15), deg_to_rad(15))
		camera.rotation.x = clampf(camera.rotation.x, -deg_to_rad(45), deg_to_rad(0))
