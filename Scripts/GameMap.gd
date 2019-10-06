extends TileMap

export var block : Resource
signal add_block
signal game_won

func _ready():
	pass

func can_move(new_position : Vector2):
	var new_coords = world_to_map(new_position)
	var cell_id = get_cellv(new_coords)
	return cell_id == -1 or tile_set.tile_get_name(cell_id) != "Wall 1"

func _on_player_moved(blocks : Array):
	var immediate_area : Dictionary = {}
	
	for block in blocks:
		var postion = world_to_map(block.global_position)
		add_to_area(immediate_area, position, true)
		
		add_to_area(immediate_area, position + Vector2.UP, false)
		add_to_area(immediate_area, position + Vector2.DOWN, false)
		add_to_area(immediate_area, position + Vector2.LEFT, false)
		add_to_area(immediate_area, position + Vector2.RIGHT, false)
	
	for key in immediate_area.keys():
		if(immediate_area[key]):
			# add block
			pass


func add_to_area(area : Dictionary, position : Vector2, is_occupied : bool):
	if area.has(position):
		if not area[position] and is_occupied:
			area[position] = true
	else:
		area[position] = is_occupied