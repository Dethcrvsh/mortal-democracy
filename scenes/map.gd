extends Node3D

@onready var SPAWN_NODE = get_node("SpawnPoints")

var spawn_points = []

# Called when the node enters the scene tree for the first time.
func _ready():
	# Initialize the spawn point
	for point in SPAWN_NODE.get_children():
		spawn_points.append(point.get_position())

func get_spawn_point(index: int) -> Vector3:
	if index < spawn_points.size():
		return spawn_points[index]
	else:
		return Vector3(0, 0, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
