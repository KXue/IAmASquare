extends Node2D

class_name Player

onready var connected_blocks	: Array = [self] setget , get_connected_blocks
onready var final_position		: Vector2 = global_position
onready var initial_position	: Vector2 = global_position

export var transition_value	: float
export var is_moving		: bool = false

func _enter_tree():
	GameSingleton.set_player(self)
	
func _ready():
	Broadcaster.connect("add_blocks", self, "_on_add_blocks")

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

	if input_direction.length_squared() > 0 and GameSingleton.get_map().can_move(input_direction):
		initial_position = global_position
		is_moving = true

		if $AnimationPlayer.current_animation == "Move":
			$AnimationPlayer.seek(0, true)
			complete_move()
		else:
			$AnimationPlayer.play("Move")

		var displacement : Vector2 = input_direction
		displacement = GameSingleton.get_map().to_map_scale(displacement)
		
		final_position = initial_position + displacement
		final_position = GameSingleton.get_map().round_position(final_position)
		
		transition_value = 0

func _physics_process(delta):
	if is_moving:
		var target_offset = (final_position - initial_position) * transition_value
		set_global_position(initial_position + target_offset)
	elif global_position != final_position:
		global_position = final_position
		
func get_connected_blocks() -> Array:
	return connected_blocks

func add_block(block : Node2D):
	block.transform.origin -= transform.origin
	add_child(block)
	block.set_owner(self)
	connected_blocks.append(block)

func complete_move():
	if global_position != final_position:
		global_position = final_position
	Broadcaster.emit_signal("player_moved", connected_blocks)

func _on_add_blocks(blocks : Array):
	for block in blocks:
		add_block(block)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Move":
		is_moving = false
		complete_move()
		$AnimationPlayer.play("Idle")