extends Node3D

@onready var laser_scene = preload("res://Scenes/laser.tscn")
@onready var loading_font = preload("res://Resources/Anta-Regular.ttf")
@onready var loading_viewport = $Loading

var screen: MeshInstance3D
var screen_material: ShaderMaterial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SubViewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.area_entered.connect(_on_area_entered)

	screen = get_node_or_null("../ControlCenter/Screen1") as MeshInstance3D
	if screen == null:
		push_warning("Ship screen mesh not found at ../ControlCenter/Screen1")
		return
	
	var shader = preload("res://Resources/screen_shader.gdshader")
	screen_material = ShaderMaterial.new()
	screen_material.shader = shader
	screen_material.set_shader_parameter("display_texture", loading_viewport.get_texture())

	screen.set_surface_override_material(0, screen_material)

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

		if screen_material == null:
			continue

		if loading_viewport != null:
			loading_viewport.queue_free()
			loading_viewport = null

		var delayed_texture := ImageTexture.create_from_image(buffer.pop_front())
		screen_material.set_shader_parameter("display_texture", delayed_texture)

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
			KEY_SPACE:
				shoot()

func shoot():
	var laser = laser_scene.instantiate()
	laser.global_transform = global_transform
	get_tree().root.get_child(0).add_child(laser)
	laser.setup(self)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("obstacle"):
		print("Collided with obstacle:", body.get_parent().name)
		queue_free()

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("goal"):
		print("Reached goal area:", area.get_parent().name)
		queue_free()


func _process(delta: float) -> void:
	position += -transform.basis.z * velocity * delta

# v should be Vector3.UP, DOWN, LEFT, RIGHT
func turn(v: Vector3):
	rotate_object_local(v, deg_to_rad(45))
