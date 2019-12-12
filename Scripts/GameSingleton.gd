extends Node

var player	: Node setget set_player, get_player
var map		: TileMap setget set_map, get_map
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func set_player(new_player : Node):
	player = new_player
	
func get_player():
	return player
	
func set_map(new_map : TileMap):
	map = new_map

func get_map():
	return map
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
