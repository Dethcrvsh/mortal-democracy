extends RigidBody3D

const MAX_TIMER = 1.0
var timer = 0.0

@onready var hit_box = $shoe

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timer >= MAX_TIMER:
		queue_free()
	timer += delta

func set_player(player_in):
	hit_box.set_player(player_in)

func set_spawn_dir(spawn_dir_in):
	hit_box.set_spawn_dir(spawn_dir_in)
