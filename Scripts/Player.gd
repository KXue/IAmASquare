extends AnimatedSprite

export var map_path : NodePath
var map : TileMap
var connected_blocks : Array = []

signal player_moved

# Called when the node enters the scene tree for the first time.
func _ready():
	map = get_node(map_path)
	connected_blocks.append(self)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var movement : Vector2 = Vector2(0, 0)
	
	if Input.is_action_just_pressed("ui_up"):
		movement += Vector2.UP
	elif Input.is_action_just_pressed("ui_left"):
		movement += Vector2.LEFT
	elif Input.is_action_just_pressed("ui_right"):
		movement += Vector2.RIGHT
	elif Input.is_action_just_pressed("ui_down"):
		movement += Vector2.DOWN

	movement *= map.cell_size

	if movement.length_squared() > 0 and can_move(movement):
		global_translate(movement)
		emit_signal("player_moved", connected_blocks)

func can_move(movement : Vector2):
	var move : bool = true
	for block in connected_blocks:
		if not map.can_move(block.global_position + movement):
			return false
	return true

func _on_add_block(block : Node2D):
	block.transform.origin -= transform.origin
	add_child(block);
	block.set_owner(self)
	connected_blocks.append(block)
	emit_signal("player_moved", connected_blocks)
	pass

func _on_game_won(next : String):
	play("Win")
