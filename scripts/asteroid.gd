extends Node3D

@export var velocity = 1.0

func change_color ():
	await (get_tree().create_timer(2).timeout)
	
	var mesh_instance: MeshInstance3D = $MeshInstance3D
	var mat := mesh_instance.get_active_material(0) as StandardMaterial3D
	
	mat = mat.duplicate() as StandardMaterial3D
	mesh_instance.set_surface_override_material(0, mat)

	mat.albedo_color = Color.RED

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_color()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += -transform.basis.z * velocity * delta
	pass
