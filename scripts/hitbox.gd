extends Area3D

var max_timer = 0.2
var timer = 0.0
var player = null


func set_player(player_in):
	player = player_in

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_body_entered(body):
	if body != player and body.is_in_group("players"):
		if player.player_state == player.SPECIAL:
			body.take_damage(player.last_move_dir, player.input_dir, 3)
		else:
			body.take_damage(player.last_move_dir, player.input_dir, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timer >= max_timer:
		queue_free()
	timer += delta
