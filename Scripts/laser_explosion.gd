extends Node3D

var final_size : Vector3 = Vector3(10, 10, 10)
var size_increase_time : float = 0.4
var color_slide_time : float = 0.2

@onready var sphere = $Sphere

func _ready() -> void:
	look_at(Vector3(randfn(0, 1), randfn(0, 1), randfn(0, 1)).normalized())

	var tween = get_tree().create_tween().bind_node(sphere).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	tween.set_parallel()
	tween.tween_property(sphere, "scale", final_size, size_increase_time)
	tween.tween_property(sphere.mesh.material, "shader_parameter/noise_vertex_multiplier", 0.2, size_increase_time)
	tween.tween_property(sphere.mesh.material, "shader_parameter/color_2", Color(1.0, 1.0, 1.0, 0.49), color_slide_time)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
