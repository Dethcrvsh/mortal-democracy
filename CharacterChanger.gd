extends Area3D

@onready var jimmy_model = load("res://scenes/jimmie_model.tscn")
@onready var annie_model = load("res://scenes/annie_model.tscn")
@onready var stefan_model = load("res://scenes/stefan_model.tscn")
@onready var ulf_model = load("res://scenes/ulf_model.tscn")

var id_to_model
var character_id = 0
var character_scale = Vector3(1, 1, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	id_to_model = {0:jimmy_model, 1:annie_model, 2:stefan_model, 3:ulf_model}


# Called every frame. 'delta' is the elapsed time since the previous frame.
func set_character_id(id):
	character_id = id

func set_character_scale(new_scale):
	character_scale = new_scale

func _on_body_entered(body):
	if body.has_method("change_character"):
		var model_instance = id_to_model[character_id].instantiate()
		body.change_character(model_instance, character_scale)
		body.set_character(character_id)
