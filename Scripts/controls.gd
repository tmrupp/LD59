extends Node3D

@onready var tv_static_material = preload("res://Resources/tv_static.tres")

@onready var director = $"../Director"
@onready var screen_1 = $"ControlCenter/Screen1"
@onready var screen_2 = $"ControlCenter/Screen2"
@onready var screen_3 = $"ControlCenter/Screen3"

@onready var all_screens = [screen_1, screen_2, screen_3]

var currently_watching = false
var current_ship = null

func _ready() -> void:
	static_all_screens()

	left_click_connect($"ControlCenter/Switching Ships Button/StaticBody3D", change_ship_screen.bind(true))
	left_click_connect($"ControlCenter/Switching Ships Button_001/StaticBody3D", change_ship_screen.bind(false))

func _process(_delta: float) -> void:
	# automatically start watching a ship's camera feed if we're not watching one right now
	if not currently_watching and len(director.ships) > 0:
		print("found a screen to watch!")
		screen_1.set_surface_override_material(0, director.ships[0].screen_material)
		currently_watching = true
		current_ship = director.ships[0]
	
	# static out the monitor if there are no ship cameras to watch
	if currently_watching and len(director.ships) < 1:
		print("no more screens to watch!")
		static_all_screens()
		currently_watching = false
		current_ship = null

func static_all_screens():
	for screen in all_screens:
		screen.set_surface_override_material(0, tv_static_material)

# function called when a button is pushed
func change_ship_screen(forward : bool):
	if current_ship == null or not currently_watching or len(director.ships) <= 1:
		return
	
	var found_index = -1
	for i in range(len(director.ships)):
		if director.ships[i] == current_ship:
			found_index = i
			break
	if found_index != -1:
		var next_index = (found_index + (1 if forward else -1)) % len(director.ships)
		current_ship = director.ships[next_index]
		# show static for 0.1 seconds then show the new camera view
		screen_1.set_surface_override_material(0, tv_static_material)
		get_tree().create_timer(0.1).timeout.connect(func():
			screen_1.set_surface_override_material(0, current_ship.screen_material)
		)

# used to connect the signal of left clicking on something to a specific action
func left_click_connect(node : Node, callable : Callable):
	node.input_event.connect(
		func(_camera, event, _event_position, _normal, _shape_idx):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				callable.call()
	)
