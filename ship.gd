extends Node3D

@onready var views = $"../CanvasLayer/Control/ShipCameraViews"
@onready var ship_view_scene = preload("res://ship_view.tscn")
var view

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	view = ship_view_scene.instantiate()
	view.add_to_group("ship_view")
	views.add_child(view)
	view.texture = null # $SubViewport.get_texture()

	capture()
	render()

@export var delay = 2.0
@export var fps = 4

var buffer = []
func capture() -> void:
	while true:
		await (get_tree().create_timer(1.0 / fps).timeout)
		buffer.append($SubViewport.get_texture().get_image())

func render() -> void:
	while true:
		await (get_tree().create_timer(1.0 / fps).timeout)
		print("t-1")
		if buffer == null:
			print("t0")
			return
			
		var texture = ImageTexture.create_from_image(buffer.pop_back())
			
		view.texture = texture
	
