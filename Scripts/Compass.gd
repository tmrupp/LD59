extends MeshInstance3D

@onready var ship = $"../.."
var goal: Node3D


func _ready() -> void:
	goal = get_tree().current_scene.get_node_or_null("Goal")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if goal == null or not is_instance_valid(goal):
		return

	var to_goal = (goal.global_position - ship.global_position).normalized()
	if to_goal.is_zero_approx():
		return

	var local_dir = ship.global_basis.inverse() * to_goal
	var yaw = atan2(local_dir.x, -local_dir.z)
	var pitch = asin(clampf(local_dir.y, -1.0, 1.0))
	rotation = Vector3(deg_to_rad(-90) + pitch, 0.0, -yaw)
