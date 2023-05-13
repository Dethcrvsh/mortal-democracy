extends CharacterBody3D


const SPEED = 10
const JUMP_VELOCITY = 25
const HITBOX_OFFSET = Vector3(0.7, 0, 0)
const TUMBLE_THREASHOLD = 1
const TUMBLE_DRAG = 0.8
# The tick coldown for a punch
const PUNCH_DELAY = 0.2
const SHIELD_MAX = 3.0
const SHIELD_DMG_PENALTY = -0.5

const IDLE = 0
const PUNCH = 1
const TUMBLE = 2
const SHIELD = 3

var player_state = 0
var player = ""
var cooldown = 0.0

var shield_timer = SHIELD_MAX
var hitbox = null
var last_move_dir = -1
var run_animation_timestamp = 0.0
var input_dir

@onready var model = $person_model
@onready var hitbox_node = load("res://scenes/hitbox.tscn")
@onready var animator = $person_model/placeholder_person_run/AnimationPlayer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func set_player(index: int) -> void:
	player = "p" + str(index + 1)

func take_damage(player_dir, player_vector) -> void:
	if not player_state == SHIELD:
		launch_player(Vector3(
			10.0 * player_dir + 10 * player_vector.x, 
			20.0 + 20.0 * player_vector.y * -1, 
			0
		))
		print(player + " took damage")
		shield_timer += SHIELD_DMG_PENALTY 

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
			
	if player_state == TUMBLE:
		do_tumble(delta)
		return
	elif player_state == PUNCH:
		do_punch(delta)

	do_shield(delta)
	
	# Todo Remove this
	if player != "p1":
		move_and_slide()
		return

	# Handle Jump.
	if Input.is_action_just_pressed("jump_" + player) and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	elif Input.is_action_just_pressed("attack_" + player) and player_state == IDLE:
		hitbox = hitbox_node.instantiate()
		hitbox.position += HITBOX_OFFSET * last_move_dir
		hitbox.set_player(self)
		add_child(hitbox)
		player_state = PUNCH
	
	elif Input.is_action_pressed("shield_" + player) and (player_state == IDLE or player_state == SHIELD):
		player_state = SHIELD
	else:
		player_state = IDLE

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	input_dir = Input.get_vector("left_" + player, 
		"right_" + player, 
		"up_" + player, 
		"down_" + player
	)
	
	if (input_dir.x > 0 and last_move_dir < 0) or (input_dir.x < 0 and last_move_dir > 0):
		model.rotate_y(PI)
		
	if input_dir.x != 0:
		velocity.x = input_dir.x * SPEED
		if input_dir.x < 0:
			last_move_dir = -1
		else:
			last_move_dir = 1
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Play run animation if where moving
	if velocity.x == 0:
		if animator.current_animation == "Run":
			run_animation_timestamp = animator.current_animation_position
			
		animator.play("Idel")
	else:
		if animator.current_animation == "Idel":
			animator.play("Run")
			animator.advance(run_animation_timestamp)
		animator.speed_scale = abs(input_dir.x)*4

	if Input.is_action_just_pressed("test_launch_p1"):
		launch_player(Vector3(10.0, 40.0, 0.0))
	
	move_and_slide()

func do_tumble(delta):
	cooldown += delta
	
	if is_on_floor() and velocity.length() < TUMBLE_THREASHOLD:
		player_state = IDLE
		
	if cooldown > 0.1:
		cooldown = 0.0
		velocity.x *= 0.8
	move_and_slide()

func launch_player(launch_vector):
	player_state = TUMBLE
	velocity.x = launch_vector.x
	velocity.y = launch_vector.y

func do_punch(delta):
	if cooldown < PUNCH_DELAY:
			cooldown += delta
	else:
		hitbox.queue_free()
		cooldown = 0.0
		player_state = IDLE

func do_shield(delta):
	if player_state == SHIELD:
		if shield_timer < 0:
			player_state = IDLE
		else:
			shield_timer -= delta
	elif shield_timer < SHIELD_MAX:
		shield_timer += delta
		
	
