extends CharacterBody3D


const SPEED = 10
const JUMP_VELOCITY = 25
const HITBOX_OFFSET = Vector3(1, 0, 0)
# The tick coldown for a punch
const PUNCH_DELAY = 10

var player = ""
var is_punching = false
var punch_counter = 0
var hitbox = null

@onready var hitbox_node = load("res://scenes/hitbox.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func set_player(index: int) -> void:
	player = "p" + str(index + 1)

func take_damage() -> void:
	print(player + " took damage")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Todo Remove this
	if player != "p1":
		move_and_slide()
		return
	
	# Handle the delay between punches
	if is_punching:
		if punch_counter < PUNCH_DELAY:
			punch_counter += 1
		else:
			hitbox.queue_free()
			punch_counter = 0
			is_punching = false

	# Handle Jump.
	if Input.is_action_just_pressed("jump_" + player) and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("attack_" + player) and not is_punching:
		hitbox = hitbox_node.instantiate()
		hitbox.position += HITBOX_OFFSET
		hitbox.set_player(self)
		add_child(hitbox)
		is_punching = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left_" + player, "right_" + player, "ui_up", "ui_down")
	if input_dir.x != 0:
		velocity.x = input_dir.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
