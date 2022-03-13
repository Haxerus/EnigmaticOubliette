extends Node2D

var random = null
var map_size = null
var nav_map = null

# Called when the node enters the scene tree for the first time.
func _ready():
	random = RandomNumberGenerator.new()
	random.randomize()
	
	generate_map()
	generate_astar()
	random_spawn()

func generate_map():
	var size_x = random.randi_range(15, 35)
	var size_y = random.randi_range(15, 35)
	map_size = Vector2(size_x, size_y)
	
	$Map.clear()
	
	for i in range(map_size.x):
		for j in range(map_size.y):
			var tile_id = 0
			
			if i == 0 or i == map_size.x - 1:
				tile_id = 1
			
			if j == 0 or j == map_size.y - 1:
				tile_id = 1
			
			$Map.set_cellv(Vector2(i, j), tile_id)


func generate_astar():
	nav_map = AStar2D.new()
	
	for i in range(map_size.x):
		for j in range(map_size.y):
			if $Map.get_cell(i, j) != 1:
				nav_map.add_point(i + j * map_size.x, Vector2(i, j))
	
	for i in range(map_size.x):
		for j in range(map_size.y):
			if $Map.get_cell(i, j) != 1:
				# UP
				_connect_map_point(Vector2(i, j), Vector2(0, -1)) 
				
				# LEFT
				_connect_map_point(Vector2(i, j), Vector2(-1, 0)) 
				
				# DOWN
				_connect_map_point(Vector2(i, j), Vector2(0, 1))
				
				# RIGHT
				_connect_map_point(Vector2(i, j), Vector2(1, 0))

func _connect_map_point(point, offset):
	if $Map.get_cellv(point + offset) == 0:
		var p1 = point.x + point.y * map_size.x
		var p2 = (point.x + offset.x) + (point.y + offset.y) * map_size.x
		if not nav_map.are_points_connected(p1, p2):
			nav_map.connect_points(p1, p2)

func random_spawn():
	var spawn_x = random.randi_range(1, map_size.x - 2)
	var spawn_y = random.randi_range(1, map_size.y - 2)
	
	$Player.position = $Map.map_to_world(Vector2(spawn_x, spawn_y)) + $Map.cell_size / 2
	
func move_player_path(path):
	for p in path:
		$Player.target = $Map.map_to_world(nav_map.get_point_position(p)) + $Map.cell_size / 2
		yield($Player, "move_finished")

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"): 
		generate_map()
		random_spawn()


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var tile_pos = $Map.world_to_map(get_global_mouse_position())
			var player_pos = $Map.world_to_map($Player.position)
			
			var target_id = tile_pos.x + tile_pos.y * map_size.x
			var player_id = player_pos.x + player_pos.y * map_size.x
			
			move_player_path(nav_map.get_id_path(player_id, target_id))
