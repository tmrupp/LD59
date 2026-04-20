extends Node3D

@onready var laser_explosion_prefab = preload("res://Scenes/laser_explosion.tscn")

@export var velocity = 10
var origin

func _ready() -> void:
	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.area_entered.connect(_on_area_entered)

	# remove self after an extended period of time
	get_tree().create_timer(90).timeout.connect(func(): queue_free())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += -transform.basis.z * velocity * delta

func collide(body):
	var parent = body.get_parent()
	print("parent:", parent, "origin:", origin, " body=", body)
	if parent != origin:
		if body.is_in_group("obstacle"):
			print("collided")

			var new_laser_explosion = laser_explosion_prefab.instantiate()
			get_tree().root.add_child(new_laser_explosion)
			new_laser_explosion.position = position

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
