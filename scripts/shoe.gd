extends Area3D

var player = null
var spawn_dir = null

func set_player(player_in):
	player = player_in

func set_spawn_dir(spawn_dir_in):
	spawn_dir = spawn_dir_in

func _on_body_entered(body):
	if body != player and body != get_parent():
		if body.is_in_group("players"):
			body.take_damage(spawn_dir, Vector3(spawn_dir, 0, 0), 1)
			get_parent().queue_free()
