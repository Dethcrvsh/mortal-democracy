extends Area3D

var id_to_model
var character_id = 0
var character_scale = Vector3(1, 1, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func set_character_id(id):
	character_id = id

func set_character_scale(new_scale):
	character_scale = new_scale

func _on_body_entered(body):
	if body.has_method("change_character"):
		body.change_character(character_id, character_scale)
