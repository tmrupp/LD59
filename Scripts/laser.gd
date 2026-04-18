extends Node3D

@export var velocity = 5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += -transform.basis.z * velocity * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("obstacle"):
		queue_free()

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("obstacle"):
		queue_free()
