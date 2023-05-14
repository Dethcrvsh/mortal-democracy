extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var children = get_children()
	children[0].get_node("CharacterChanger").set_character_id(0)
	children[1].get_node("CharacterChanger").set_character_id(1)
	children[2].get_node("CharacterChanger").set_character_id(2)
	children[3].get_node("CharacterChanger").set_character_id(3)
	children[3].get_node("CharacterChanger").set_character_scale(Vector3(0.6, 0.6, 0.6))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
