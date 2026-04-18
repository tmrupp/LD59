extends Node3D

@export var velocity = 0.001
@export var rotational_velocity : float = 0
@export var rotational_axis : Vector3 = Vector3.UP # assumed to be normalized

func change_color ():
	await (get_tree().create_timer(2).timeout)
	
	var mesh_instance: MeshInstance3D = $MeshInstance3D
	var mat := mesh_instance.get_active_material(0) as StandardMaterial3D
	
	mat = mat.duplicate() as StandardMaterial3D
	mesh_instance.set_surface_override_material(0, mat)

	mat.albedo_color = Color.RED

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	position += -transform.basis.z * velocity * delta

	rotate(rotational_axis, rotational_velocity * delta)
