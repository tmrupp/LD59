extends Node3D

@onready var views = $"../CanvasLayer/Control/ShipCameraViews"
@onready var ship_view_scene = preload("res://scenes/ship_view.tscn")
var view: TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SubViewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	view = ship_view_scene.instantiate()
	view.add_to_group("ship_view")
	views.add_child(view)

	capture()
	render()

@export var delay = 2.0
@export var fps = 15

@export var velocity = 1.0
#var direction: Vector3 = Vector3.FORWARD

var buffer = []
func capture() -> void:
	while true:
		await (get_tree().create_timer(1.0 / fps).timeout)
		var image = $SubViewport.get_texture().get_image()
		buffer.append(image.duplicate())

func render() -> void:
	while true:
		await (get_tree().create_timer(1.0 / fps).timeout)
		if buffer == null or buffer.size() < delay * fps:
			continue
			
		view.texture = ImageTexture.create_from_image(buffer.pop_front())

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_W:
				turn(Vector3.RIGHT)
			KEY_S:
				turn(Vector3.LEFT)
			KEY_A:
				turn(Vector3.UP)
			KEY_D:
				turn(Vector3.DOWN)


func _process(delta: float) -> void:
	position += -transform.basis.z * velocity * delta

# v should be Vector3.UP, DOWN, LEFT, RIGHT
func turn(v: Vector3):
	rotate_object_local(v, deg_to_rad(45))
	print("turing")
