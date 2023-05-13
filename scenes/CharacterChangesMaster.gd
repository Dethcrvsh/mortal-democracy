extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var children = get_children()
	for i in range(3):
		children[i].get_node("CharacterChanger").set_character_id(i)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
