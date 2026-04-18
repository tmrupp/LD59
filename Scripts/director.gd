@tool
extends Node3D

@onready var asteroid_prefab = preload("res://Scenes/asteroid.tscn")
@onready var ship_prefab = preload("res://Scenes/ship.tscn")

# ==== inspector exports/controls ====
@export_group("Asteroids")
@export var asteroid_count_desired : int = 50
@export var asteroid_field_center : Vector3 # center of cuboid containing asteroids
@export var asteroid_field_extents : Vector3 # length/width/height of cuboid containing asteroids
@export var asteroid_field_perturbation : float

@export_tool_button("Generate Asteroids")
var button_1 = init_asteroids

@export_tool_button("Clear Asteroids")
var button_2 = clear_asteroids


@export_group("Ship Spawn")
@export var ship_spawn_center : Vector3
@export var ship_spawn_extents : Vector3
@export_group("")
# ====================================

var asteroids : Array = []
var ships : Array = []

func _ready() -> void:
	if not Engine.is_editor_hint():
		init_asteroids()

func init_asteroids():
	# approximately how many asteroids in each dimensions to distribute them in a 3d grid
	var x = pow(asteroid_count_desired * asteroid_field_extents.x * asteroid_field_extents.x / asteroid_field_extents.y / asteroid_field_extents.z, 1.0/3.0)
	var y = asteroid_field_extents.y / asteroid_field_extents.x * x
	var z = asteroid_field_extents.z / asteroid_field_extents.x * x

	x = int(round(x))
	y = int(round(y))
	z = int(round(z))

	var start_corner : Vector3 = asteroid_field_center - asteroid_field_extents / 2.0
	var increment : Vector3 = asteroid_field_extents / Vector3(x - 1, y - 1, z - 1)

	for i in range(x):
		for j in range(y):
			for k in range(z):
				var new_asteroid = asteroid_prefab.instantiate()
				add_child(new_asteroid)
				asteroids.append(new_asteroid)

				new_asteroid.position = start_corner + increment * Vector3(i, j, k)

				# randomly alter the position
				var random_perturbation = asteroid_field_perturbation * get_random_on_unit_sphere()
				new_asteroid.position += random_perturbation

				# randomly set rotation
				new_asteroid.look_at(new_asteroid.position + get_random_on_unit_sphere())

				# set scale
				new_asteroid.scale *= randfn(4, 2)

func spawn_ship():
	pass

func clear_asteroids():
	print("Clearing asteroids")
	for asteroid in asteroids:
		asteroid.queue_free()

func get_random_on_unit_sphere():
	return Vector3(randfn(0, 1), randfn(0, 1), randfn(0, 1)).normalized()
