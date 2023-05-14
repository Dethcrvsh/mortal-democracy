extends CanvasLayer

@onready var bar = $Bar

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_color(color: Color) -> void:
	bar.set_modulate(color)

func set_position(pos: Vector2) -> void:
	set_offset(pos)

func set_votes(votes: int) -> void:
	bar.set_value(votes)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
