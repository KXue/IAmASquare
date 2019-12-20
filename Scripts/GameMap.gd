extends TileMap

export var block : Resource
export var next_scene : String

const DIRECTIONS : Array = [
	Vector2.UP, 
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.RIGHT 
]

func _enter_tree():
	GameSingleton.set_map(self)

func _ready():
	Broadcaster.connect("player_moved", self, "_on_player_moved")
#	connect("player_moved", GameSingleton.get_player(), "_on_player_moved")

func _on_player_moved(blocks : Array):
	var immediate_area : Dictionary = _generate_immediate_area(blocks)
	_add_blocks_to_player(immediate_area)
	_check_win_condition(immediate_area)

func to_map_scale(unit : Vector2) -> Vector2:
	unit.x *= cell_size.x
	unit.y *= cell_size.y
	return unit

func round_position(position : Vector2) -> Vector2:
	return Vector2(
		round(position.x / cell_size.x) * cell_size.x, 
		round(position.y / cell_size.y) * cell_size.y
	)

func can_move(movement : Vector2) -> bool:
	movement.x = movement.x * cell_size.x
	movement.y = movement.y * cell_size.y
	
	var connected_blocks = GameSingleton.get_player().get_connected_blocks()
	for block in connected_blocks:
		if not is_open(round_position(block.global_position + movement)):
			return false
	return true

func is_open(new_position : Vector2) -> bool:
	var new_coords = world_to_map(new_position)
	var cell_id = get_cellv(new_coords)
	return cell_id == -1 or tile_set.tile_get_name(cell_id) != "Wall"

func _generate_immediate_area(blocks : Array) -> Dictionary:
	var immediate_area : Dictionary = {}
	
	for block in blocks:
		var coords = world_to_map(block.global_position)
		_add_to_area(immediate_area, coords, true)
		for direction in DIRECTIONS:
			_add_to_area(immediate_area, coords + direction, false)
	
	return immediate_area

func _add_blocks_to_player(immediate_area : Dictionary):
	var blocks : Array = []
	
	var to_search : Array = []
	var searched_area = immediate_area.duplicate()
	
	for key in immediate_area.keys():
		if not immediate_area[key]:
			to_search.append(key)
	
	while(not to_search.empty()):
		var coord = to_search.pop_front()
		_add_to_area(searched_area, coord, true)
		if _can_add_at(coord):
			var new_block = block.instance()
			new_block.transform.origin = map_to_world(coord, true)
			blocks.append(new_block)
			set_cellv(coord, INVALID_CELL)
			for direction in DIRECTIONS:
				var new_coord = coord + direction
				if not searched_area.has(new_coord) or not searched_area[new_coord]:
					to_search.push_back(new_coord)
			
	Broadcaster.emit_signal("add_blocks", blocks)

func _can_add_at(coords : Vector2) -> bool:
	var cell_index = get_cellv(coords)
	return cell_index != -1 and tile_set.tile_get_name(cell_index) == "Block"

func _add_to_area(area : Dictionary, position : Vector2, is_occupied : bool):
	if area.has(position):
		area[position] = is_occupied or area[position]
	else:
		area[position] = is_occupied

func _check_win_condition(immediate_area : Dictionary):
	var goal_tile_id : int = tile_set.find_tile_by_name("Goal")
	var goal_tiles : Array = get_used_cells_by_id(goal_tile_id)

	if immediate_area.has_all(goal_tiles):
		var all_goals_covered : bool = true

		for goal_tile in goal_tiles:
			if not immediate_area[goal_tile]:
				all_goals_covered = false
				break

		if all_goals_covered:
			Broadcaster.emit_signal("game_won", next_scene)