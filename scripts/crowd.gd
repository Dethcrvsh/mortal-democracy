extends Node3D

@onready var animator = $crowd/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	var rng = RandomNumberGenerator.new()
	animator.advance(rng.randf_range(0.0, 4.1))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
