extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var area3d = get_node("Area3D")
	area3d.body_entered.connect(_on_body_entered)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	print_debug("a new body entered:")
	print_debug(body)
	pass # Replace with function body.
