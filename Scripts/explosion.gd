extends Node3D

@export var color_gradient : Gradient

var final_size : Vector3 = Vector3(50, 50, 50)
var size_increase_time : float = 7.5
var color_slide_time : float = 5.0
var color_variance_window : float = 0.25

@onready var sphere = $Sphere

func _ready() -> void:
	look_at(Vector3(randfn(0, 1), randfn(0, 1), randfn(0, 1)).normalized())

	var tween = get_tree().create_tween().bind_node(sphere).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.set_parallel()
	tween.tween_property(sphere, "scale", final_size, size_increase_time)
	tween.tween_property(sphere.mesh.material, "shader_parameter/vertex_adjust", 0.1, size_increase_time)
	tween.tween_method(set_color_in_shader_via_gradient, 0.0, 1.0 + color_variance_window, color_slide_time).set_trans(Tween.TRANS_QUART)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)

func set_color_in_shader_via_gradient(val : float):
	sphere.mesh.material.set_shader_parameter("color_at_0", color_gradient.sample(clampf(val - color_variance_window, 0.0, 1.0)))
	sphere.mesh.material.set_shader_parameter("color_at_1", color_gradient.sample(clampf(val, 0.0, 1.0)))
