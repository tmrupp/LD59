extends Node3D

@export var velocity = 5
var origin

func _ready() -> void:
	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.area_entered.connect(_on_area_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += -transform.basis.z * velocity * delta

func collide(body):
	var parent = body.get_parent()
	print("parent:", parent, "origin:", origin, " body=", body)
	if parent != origin:
		if body.is_in_group("obstacle"):
			print("collided")
			queue_free()
			parent.queue_free()
		
func _on_body_entered(body: Node) -> void:
	print("laser body entered:", body)
	collide(body)
	
func _on_area_entered(area: Area3D) -> void:
	print("laser body entered:", area)
	collide(area)
		
func setup(o):
	origin = o
