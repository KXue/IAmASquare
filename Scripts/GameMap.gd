extends TileMap

export var block : Resource
export var next_scene : String
signal add_block
signal game_won

func _enter_tree():
	GameSingleton.set_map(self)

func _ready():
	pass	
#	connect("player_moved", GameSingleton.get_player(), "_on_player_moved")

func _on_player_moved():
	var immediate_area : Dictionary = generate_immediate_area(GameSingleton.get_player().get_connected_blocks())
	add_blocks_to_player(immediate_area)
	check_win_condition(immediate_area)

func to_map_scale(unit : Vector2):
	unit.x *= cell_size.x
	unit.y *= cell_size.y
	return unit

func round_position(position : Vector2):
	var x : float = position.x / cell_size.x
	var y : float = position.y / cell_size.y
	
	return Vector2(
		round(position.x / cell_size.x) * cell_size.x, 
		round(position.y / cell_size.y) * cell_size.y
	)

func can_move(movement : Vector2):
	movement.x = movement.x * cell_size.x
	movement.y = movement.y * cell_size.y
	
	var connected_blocks = GameSingleton.get_player().get_connected_blocks()
	for block in connected_blocks:
		if not is_open(round_position(block.global_position + movement)):
			return false
	return true

func is_open(new_position : Vector2):
	var new_coords = world_to_map(new_position)
	var cell_id = get_cellv(new_coords)
	return cell_id == -1 or tile_set.tile_get_name(cell_id) != "Wall"

func generate_immediate_area(blocks : Array):
	var immediate_area : Dictionary = {}
	
	for block in blocks:
		var coords = world_to_map(block.global_position)
		add_to_area(immediate_area, coords, true)
		
		add_to_area(immediate_area, coords + Vector2.UP, false)
		add_to_area(immediate_area, coords + Vector2.DOWN, false)
		add_to_area(immediate_area, coords + Vector2.LEFT, false)
		add_to_area(immediate_area, coords + Vector2.RIGHT, false)
	
	return immediate_area

func add_blocks_to_player(immediate_area : Dictionary):
	for key in immediate_area.keys():
		var cell_index = get_cellv(key)
		if not immediate_area[key] and cell_index != -1 and tile_set.tile_get_name(cell_index) == "Block":
			var new_block = block.instance()
			new_block.transform.origin = map_to_world(key, true)
			emit_signal("add_block", new_block)
			set_cellv(key, INVALID_CELL)

func add_to_area(area : Dictionary, position : Vector2, is_occupied : bool):
	if area.has(position):
		area[position] = is_occupied or area[position]

func check_win_condition(immediate_area : Dictionary):
	var goal_tile_id : int = tile_set.find_tile_by_name("Goal")
	var goal_tiles : Array = get_used_cells_by_id(goal_tile_id)

	if immediate_area.has_all(goal_tiles):
		var all_goals_covered : bool = true

		for goal_tile in goal_tiles:
			if not immediate_area[goal_tile]:
				all_goals_covered = false
				break

		if all_goals_covered:
			emit_signal("game_won", next_scene)