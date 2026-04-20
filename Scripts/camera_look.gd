extends Node3D

@onready var camera = $Camera3D

const mouse_sensitivity_vert : float = 0.001
const mouse_sensitivity_horiz : float = 0.0005

@export var zoom_duration : float = .2
@export var zoom_amount : float = 50.0

func zoom(amount: float) -> void:
	
	var zoom_tween = create_tween()
	zoom_tween.tween_property(camera, "fov", clampf(camera.fov - amount, 20, 90), zoom_duration)
	zoom_tween.play()

var x_angle_clamp = Vector2(-deg_to_rad(60), deg_to_rad(30))
var y_angle_clamp = Vector2(-deg_to_rad(30), deg_to_rad(30))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity_horiz)
		camera.rotate_x(-event.relative.y * mouse_sensitivity_vert)

		rotation.y = clampf(rotation.y, y_angle_clamp.x, y_angle_clamp.y)
		camera.rotation.x = clampf(camera.rotation.x, x_angle_clamp.x, x_angle_clamp.y)
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			zoom(zoom_amount)
		elif event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
			zoom(-zoom_amount)
