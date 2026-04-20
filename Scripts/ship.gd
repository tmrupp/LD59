extends Node3D

@onready var laser_scene = preload("res://Scenes/laser.tscn")
@onready var loading_font = preload("res://Resources/Anta-Regular.ttf")
@onready var explosion_prefab = preload("res://Scenes/explosion.tscn")
@onready var loading_viewport = $Loading
@onready var compass_viewport = $Compass

var director : Node = null

# var screen: MeshInstance3D
var screen_material: ShaderMaterial
var compass_material: ShaderMaterial

var ship_name : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SubViewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	compass_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.area_entered.connect(_on_area_entered)

	# screen = get_node_or_null("../ControlCenter/Screen1") as MeshInstance3D
	# if screen == null:
	# 	push_warning("Ship screen mesh not found at ../ControlCenter/Screen1")
	# 	return
	
	var shader = preload("res://Resources/screen_shader.gdshader")
	screen_material = ShaderMaterial.new()
	screen_material.shader = shader
	screen_material.set_shader_parameter("display_texture", loading_viewport.get_texture())
	
	compass_material = ShaderMaterial.new()
	compass_material.shader = shader
	compass_material.set_shader_parameter("display_texture", compass_viewport.get_texture())

	#screen.set_surface_override_material(0, screen_material)

	# randomly generate name of the form XX-000
	ship_name = char(randi_range(65, 90)) + char(randi_range(65, 90)) + "-" + str(randi_range(0, 9)) + str(randi_range(0, 9)) + str(randi_range(0, 9))

	capture(feed_buffer, $SubViewport)
	render(feed_buffer, screen_material)
	
	capture(compass_buffer, compass_viewport)
	render(compass_buffer, compass_material)

@export var delay = 2.0
@export var fps = 15

@export var velocity = 1.0
@export var turn_amount_degrees := 45.0
@export var turn_duration := 0.25

var feed_buffer = []
var compass_buffer = []
var turn_tween: Tween

func capture(buffer: Array, viewport: SubViewport) -> void:
	while true:
		await (get_tree().create_timer(1.0 / fps).timeout)
		var image = viewport.get_texture().get_image()
		buffer.append(image.duplicate())

func render(buffer: Array, material: ShaderMaterial) -> void:
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
		material.set_shader_parameter("display_texture", delayed_texture)

func shoot():
	var laser = laser_scene.instantiate()
	laser.global_transform = global_transform
	get_tree().root.get_child(0).add_child(laser)
	laser.setup(self)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("obstacle"):
		print("Collided with obstacle:", body.get_parent().name)

		var new_explosion = explosion_prefab.instantiate()
		get_tree().root.add_child(new_explosion)
		new_explosion.position = position
		
		queue_free()

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("goal"):
		print("Reached goal area:", area.get_parent().name)
		queue_free()


func _process(delta: float) -> void:
	position += -transform.basis.z * velocity * delta

func turn(v: Vector3):
	if turn_tween != null and turn_tween.is_valid():
		turn_tween.kill()

	var current_basis := transform.basis.orthonormalized()
	var turn_axis := current_basis.x if v.y != 0.0 else current_basis.y if v.x != 0.0 else Vector3.ZERO
	if turn_axis == Vector3.ZERO:
		return

	var turn_angle := deg_to_rad(turn_amount_degrees * (v.y - v.x))
	var target_quaternion := current_basis.rotated(turn_axis, turn_angle).orthonormalized().get_rotation_quaternion()

	turn_tween = create_tween()
	turn_tween.set_trans(Tween.TRANS_SINE)
	turn_tween.set_ease(Tween.EASE_OUT)
	turn_tween.tween_property(self, "quaternion", target_quaternion, turn_duration)
