extends Sprite

export var map_path : NodePath
var map : TileMap
var connected_blocks : Array = []

signal player_moved
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

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

	movement *= 16
	var new_position = transform.origin + movement

	if movement.length_squared() > 0 and can_move(new_position):
		global_translate(movement)
		emit_signal("player_moved", connected_blocks)

func can_move(new_position : Vector2):
	return map.can_move(new_position)

func _on_add_block(block : Node2D):
	add_child(block);
	connected_blocks.append(block)
	pass