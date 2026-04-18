extends Node3D

@onready var views = $"../CanvasLayer/Control/ShipCameraViews"
@onready var ship_view_scene = preload("res://ship_view.tscn")
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
@export var fps = 4

var buffer = []
func capture() -> void:
	while true:
		await (get_tree().create_timer(1.0 / fps).timeout)
		var image = $SubViewport.get_texture().get_image()
		if image == null:
			continue
		buffer.append(image.duplicate())

func render() -> void:
	while true:
		await (get_tree().create_timer(1.0 / fps).timeout)
		print("t-1")
		if buffer == null or buffer.size() < delay * fps:
			print("t0")
			continue
		print("t1")
			
		var texture = ImageTexture.create_from_image(buffer.pop_front())
			
		view.texture = texture
	
