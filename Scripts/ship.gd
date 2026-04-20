extends Node3D

@onready var laser_scene = preload("res://Scenes/laser.tscn")
@onready var loading_font = preload("res://Resources/Anta-Regular.ttf")
@onready var explosion_prefab = preload("res://Scenes/explosion.tscn")
@onready var loading_viewport = $Loading
@onready var ship_data_viewport = $ShipDataViewport
@onready var game_data_viewport = $GameDataViewport

var director : Node = null

# var screen: MeshInstance3D
var screen_feed
var ship_data_feed
var game_data_feed

static var destroyed_ships = 0
static var delivered_ships = 0

var ship_name : String
var ammo = 3

class screen extends Node:
	var viewport: SubViewport
	var material: ShaderMaterial
	var buffer: Array = []
	var ship: Node

	func _init(_viewport: SubViewport, _ship: Node, loading_viewport: SubViewport) -> void:
		self.viewport = _viewport
		self.ship = _ship
		
		
		_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		
		var shader = load("res://Resources/screen_shader.gdshader")
		self.material = ShaderMaterial.new()
		self.material.shader = shader
		self.material.set_shader_parameter("display_texture", loading_viewport.get_texture())

	func capture() -> void:
		while true:
			await (get_tree().create_timer(1.0 / self.ship.fps).timeout)
			var image = self.viewport.get_texture().get_image()
			self.buffer.append(image.duplicate())

	func render() -> void:
		while true:
			await (get_tree().create_timer(1.0 / self.ship.fps).timeout)
			if self.buffer == null or self.buffer.size() < self.ship.delay * self.ship.fps:
				continue

			if self.material == null:
				continue

			var delayed_texture := ImageTexture.create_from_image(self.buffer.pop_front())
			self.material.set_shader_parameter("display_texture", delayed_texture)

	func start() -> void:
		capture()
		render()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SubViewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	ship_data_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.area_entered.connect(_on_area_entered)

	# randomly generate name of the form XX-000
	ship_name = char(randi_range(65, 90)) + char(randi_range(65, 90)) + "-" + str(randi_range(0, 9)) + str(randi_range(0, 9)) + str(randi_range(0, 9))
	
	ship_name_label.text = ship_name

	screen_feed = screen.new($SubViewport, self, loading_viewport)
	add_child(screen_feed)
	screen_feed.start()

	ship_data_feed = screen.new(ship_data_viewport, self, loading_viewport)
	add_child(ship_data_feed)
	ship_data_feed.start()
	
	game_data_feed = screen.new(game_data_viewport, self, loading_viewport)
	add_child(game_data_feed)
	game_data_feed.start()
	
@onready var ship_name_label = $ShipDataViewport/CanvasLayer/Control/MarginContainer/GridContainer/HBoxContainer/VBoxContainer/TextureRect/MarginContainer/VBoxContainer/Label2
@onready var ammo_name_label = $ShipDataViewport/CanvasLayer/Control/MarginContainer/GridContainer/HBoxContainer/VBoxContainer/TextureRect2/MarginContainer/VBoxContainer/Label4
@onready var delay_name_label = $ShipDataViewport/CanvasLayer/Control/MarginContainer/GridContainer/HBoxContainer/VBoxContainer2/TextureRect/MarginContainer/HBoxContainer/Label3
@onready var compass_rect = $ShipDataViewport/CanvasLayer/Control/MarginContainer/GridContainer/HBoxContainer/VBoxContainer2/TextureRect2/MarginContainer/VBoxContainer/TextureRect

@onready var time_label = $GameDataViewport/CanvasLayer/Control/MarginContainer/HBoxContainer/answers/Label
@onready var active_ships_label = $GameDataViewport/CanvasLayer/Control/MarginContainer/HBoxContainer/answers/Label2
@onready var delivered_ships_label = $GameDataViewport/CanvasLayer/Control/MarginContainer/HBoxContainer/answers/Label3
@onready var destroyed_ships_label =  $GameDataViewport/CanvasLayer/Control/MarginContainer/HBoxContainer/answers/Label4

@export var delay = 2.0
@export var fps = 15

@export var velocity = 1.0
@export var turn_amount_degrees := 45.0
@export var turn_duration := 0.25

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

		if material == null:
			continue

		if loading_viewport != null:
			loading_viewport.queue_free()
			loading_viewport = null

		var delayed_texture := ImageTexture.create_from_image(buffer.pop_front())
		material.set_shader_parameter("display_texture", delayed_texture)

func shoot():
	if ammo > 0:
		var laser = laser_scene.instantiate()
		laser.global_transform = global_transform
		get_tree().root.get_child(0).add_child(laser)
		laser.setup(self)
		ammo -= 1
		return true
	else:
		return false

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("obstacle"):
		print("Collided with obstacle:", body.get_parent().name)

		var new_explosion = explosion_prefab.instantiate()
		get_tree().root.add_child(new_explosion)
		new_explosion.position = position
		destroyed_ships += 1
		
		queue_free()

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("goal"):
		print("Reached goal area:", area.get_parent().name)
		delivered_ships += 1
		queue_free()


func _process(delta: float) -> void:
	position += -transform.basis.z * velocity * delta
	ammo_name_label.text = str(ammo)
	delay_name_label.text = str(delay)
	
	time_label.text = str(int(Time.get_ticks_msec()*.001), " secs")
	active_ships_label.text = str($"..".ships.size())
	delivered_ships_label.text = str(delivered_ships)
	destroyed_ships_label.text = str(destroyed_ships)

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
