extends NinePatchRect

var next_level : String
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_game_won(next_scene : String):
	next_level = next_scene
	show()


func _on_Next_pressed():
	get_tree().change_scene(next_level)
	pass # Replace with function body.