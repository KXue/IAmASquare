extends Node2D

class_name Player

onready var player 				: Sprite = $Player
onready var connected_blocks	: Array = [self]
onready var final_position		: Vector2 = global_position
onready var initial_position	: Vector2 = global_position

export var transition_value	: float
export var is_moving		: bool = false

signal player_moved

func _ready():
	GameSingleton.set_player(self)

func _process(delta):
	var input_direction : Vector2 = Vector2(0, 0)
	
	if Input.is_action_just_pressed("ui_up"):
		input_direction += Vector2.UP
	elif Input.is_action_just_pressed("ui_left"):
		input_direction += Vector2.LEFT
	elif Input.is_action_just_pressed("ui_right"):
		input_direction += Vector2.RIGHT
	elif Input.is_action_just_pressed("ui_down"):
		input_direction += Vector2.DOWN

	if input_direction.length_squared() > 0 and can_move(input_direction):
		if $AnimationPlayer.current_animation == "Move":
			$AnimationPlayer.seek(0, true)
			move_complete()

		initial_position = global_position
		is_moving = true

		var displacement : Vector2 = input_direction
		displacement = to_map_scale(displacement)
		
		final_position = initial_position + displacement
		final_position = round_position(final_position)
		
		transition_value = 0

		$AnimationPlayer.play("Move")

func round_position(position : Vector2):
	var cell_size : Vector2 = GameSingleton.get_map().get_cell_size()
	var x : float = position.x / cell_size.x
	var y : float = position.y / cell_size.y
	
	if $Player.centered:
		x += 0.5
		y += 0.5
		
	return Vector2(round(x) * cell_size.x, round(y) * cell_size.y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if is_moving:
		var target_offset = (final_position - initial_position) * transition_value
		print(initial_position, final_position, transition_value)
		set_global_position(initial_position + target_offset)
	elif global_position != final_position:
		global_position = final_position

func to_map_scale(unit : Vector2):
	var cell_size : Vector2 = GameSingleton.get_map().get_cell_size()
	unit.x *= cell_size.x
	unit.y *= cell_size.y
	return unit

func can_move(movement : Vector2):
	var map : TileMap = GameSingleton.get_map()
	var cell_size = map.get_cell_size()
	
	movement.x = movement.x * cell_size.x
	movement.y = movement.y * cell_size.y
	
	for block in connected_blocks:
		if not map.can_move(round_position(block.global_position + movement)):
			return false
	return true

func add_block(block : Node2D):
	block.transform.origin -= transform.origin
	add_child(block)
	block.set_owner(self)
	connected_blocks.append(block)

func move_complete():
	is_moving = false
	if global_position != final_position:
		global_position = final_position
	# signal move complete
			
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Move":
		move_complete()
		$AnimationPlayer.play("Idle")
