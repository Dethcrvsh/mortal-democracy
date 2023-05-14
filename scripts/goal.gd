extends Node3D

var gamestate = null
var players_in_zone = []
const vote_rate = 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	var area3d = get_node("Area3D")
	area3d.body_entered.connect(_on_body_entered)
	area3d.body_exited.connect(_on_body_exited)
	print_debug(get_tree().get_nodes_in_group("players"))
	gamestate = get_tree().get_first_node_in_group("gamestate")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if len(players_in_zone) == 1 and gamestate.votes.has(players_in_zone[0]):
		gamestate.votes[players_in_zone[0]] += delta * vote_rate

func _on_body_entered(body: Node3D):
	
	if body.is_in_group("players"):
		players_in_zone.append(body.device)
		print_debug("player %s at podium" % body.device)
		body.talking = true

func _on_body_exited(body: Node3D):
	if body.is_in_group("players"):
		players_in_zone.erase(body.device)
		body.talking = false
	
