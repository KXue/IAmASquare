extends TileMap

export var block : Resource
export var next_scene : String
signal add_block
signal game_won

func _ready():
	pass

func can_move(new_position : Vector2):
	var new_coords = world_to_map(new_position)
	var cell_id = get_cellv(new_coords)
	return cell_id == -1 or tile_set.tile_get_name(cell_id) != "Wall"

func _on_player_moved(blocks : Array):
	var immediate_area : Dictionary = generate_immediate_area(blocks)
	add_blocks_to_player(immediate_area)
	check_win_condition(immediate_area)
	
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
		if not area[position] and is_occupied:
			area[position] = true
	else:
		area[position] = is_occupied

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
			print("won")
			emit_signal("game_won", next_scene)