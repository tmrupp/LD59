extends Node3D

@onready var tv_static_material = preload("res://Resources/tv_static.tres")

@onready var director = $"../Director"
@onready var screen_1 = $"ControlCenter/Screen1"
@onready var screen_2 = $"ControlCenter/Screen2"
@onready var screen_3 = $"ControlCenter/Screen3"

@onready var ship_screen = screen_2 # $"ControlCenter/Screen2"
@onready var compass_screen = screen_3 # $"ControlCenter/Screen2"

@onready var all_screens = [screen_1, screen_2, screen_3]

var currently_watching = false
var current_ship = null
var buttons = ["Buttons", "Buttons_001", "Buttons_002", "Buttons_003", "Buttons_004", "Buttons_005", "Buttons_006", "Buttons_007", "Buttons_008"]
func _ready() -> void:
	static_all_screens()

	left_click_connect($"ControlCenter/Switching Ships Button/StaticBody3D", change_ship_screen.bind(true))
	left_click_connect($"ControlCenter/Switching Ships Button_001/StaticBody3D", change_ship_screen.bind(false))

	for idx in range(buttons.size()):
		#print("%d: Connecting button: %s" % [idx, buttons[idx]])
		var n = "ControlCenter/%s/StaticBody3D" % buttons[idx]
		if has_node(n):
			left_click_connect(get_node(n), grid_button_pressed.bind(idx))

func grid_button_pressed(idx: int):
	#print("Grid button pressed: %d" % idx)
	if current_ship == null or not is_instance_valid(current_ship):
		return
	match idx:
		1: turn_selected_ship(Vector3.UP)
		3: turn_selected_ship(Vector3.RIGHT)
		5: turn_selected_ship(Vector3.LEFT)
		7: turn_selected_ship(Vector3.DOWN)
		4: shoot_selected_ship()

func shoot_selected_ship():
	current_ship.shoot()
	
func turn_selected_ship(direction: Vector3):
	current_ship.turn(direction)
	
func populate_screens(ship):
	ship_screen.set_surface_override_material(0, ship.screen_feed.material)
	compass_screen.set_surface_override_material(0, ship.ship_data_feed.material)

func _process(_delta: float) -> void:
	# clean dead ships from the director's list first
	director.ships = director.ships.filter(func(s): return is_instance_valid(s))
	
	if current_ship != null and not is_instance_valid(current_ship):
		currently_watching = false
		current_ship = null
		static_all_screens()
		
	
	# automatically start watching a ship's camera feed if we're not watching one right now
	if not currently_watching and len(director.ships) > 0:
		#print("found a screen to watch!")
		var ship = director.ships[0]
		currently_watching = true
		current_ship = ship
		ship_screen.set_surface_override_material(0, tv_static_material)
		get_tree().create_timer(0.1).timeout.connect(func():
			if is_instance_valid(ship):
				populate_screens(ship)
		)
	
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
		ship_screen.set_surface_override_material(0, tv_static_material)
		var ship = current_ship
		get_tree().create_timer(0.1).timeout.connect(func():
			if ship != null and is_instance_valid(ship):
				populate_screens(ship)
			else:
				print("SHIP NOT VALID TO SWITCH TO (2)")
		)

# used to connect the signal of left clicking on something to a specific action
func left_click_connect(node : Node, callable : Callable):
	if node == null:
		return

	#print("connecting left click for node: %s" % node.name)
		
	node.input_event.connect(
		func(_camera, event, _event_position, _normal, _shape_idx):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				callable.call()
	)
