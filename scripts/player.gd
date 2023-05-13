extends CharacterBody3D


const SPEED = 10
const JUMP_VELOCITY = 25
const HITBOX_OFFSET = Vector3(0.7, 0, 0)
const TUMBLE_THREASHOLD = 5
const TUMBLE_DRAG = 0.8
# The tick coldown for a punch
const PUNCH_DELAY = 0.5
const SHIELD_MAX = 3.0
const SHIELD_DMG_PENALTY = -0.5
const TUMBLE_ROTATION = PI*2

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
var rng = RandomNumberGenerator.new()
var rotation_dir = 1
var og_rotation = null
var input_dir
var shield = null
var punch_cooldown = 0.0
var can_punch = true

@onready var model = $model
@onready var hitbox_node = load("res://scenes/hitbox.tscn")
@onready var animator = $"model/Jimmie Åkesson/AnimationPlayer"
@onready var shield_node = load("res://scenes/shield.tscn")

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

func _ready():
	og_rotation = rotation
	

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
			
	if player_state == TUMBLE:
		do_tumble(delta)
		return

	do_shield(delta)
	
	# Handle punches
	if punch_cooldown <= 0.0:
		can_punch = true
	else:
		can_punch = false
		punch_cooldown -= delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump_" + player) and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	elif Input.is_action_just_pressed("attack_" + player) and player_state == IDLE and can_punch:
		do_punch()
	
	elif Input.is_action_just_pressed("shield_" + player) and (player_state == IDLE or player_state == SHIELD):
		player_state = SHIELD
		shield = shield_node.instantiate()
		add_child(shield)
	
	elif Input.is_action_just_released("shield_" + player):
		player_state = IDLE
		if shield != null:
			shield.queue_free()

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
		if animator.current_animation != "Run":
			animator.play("Run")
			animator.advance(run_animation_timestamp)
		animator.speed_scale = abs(input_dir.x)*4

	if Input.is_action_just_pressed("test_launch_p1"):
		launch_player(Vector3(10.0, 40.0, 0.0))
	
	move_and_slide()

func do_tumble(delta):
	animator.play("tumble")
	
	rotate(Vector3(0.0, 0.0, 1.0), TUMBLE_ROTATION*delta*rotation_dir)
	cooldown += delta
	
	if is_on_floor() and velocity.length() < TUMBLE_THREASHOLD:
		rotation = og_rotation
		player_state = IDLE
		
	if cooldown > 0.1:
		cooldown = 0.0
		velocity.x *= 0.8
	
	var saved_velocity = velocity
	
	move_and_slide()
	
	var collision = get_slide_collision(0)
	if collision:
		var bounce_direction = collision.get_collider(0).global_position.direction_to(global_position)
		velocity = saved_velocity.length()*0.5*bounce_direction
	return

func launch_player(launch_vector):
	player_state = TUMBLE
	velocity.x = launch_vector.x
	velocity.y = launch_vector.y
	
	var random_i = rng.randi_range(0, 1)
	if random_i == 0:
		rotation_dir = 1
	else:
		rotation_dir = -1

func do_punch():
	hitbox = hitbox_node.instantiate()
	hitbox.position += HITBOX_OFFSET * last_move_dir
	hitbox.set_player(self)
	add_child(hitbox)
	punch_cooldown = PUNCH_DELAY
	can_punch = false

func do_shield(delta):
	if player_state == SHIELD:
		if shield_timer < 0:
			player_state = IDLE
			shield.queue_free()
		else:
			shield_timer -= delta
	elif shield_timer < SHIELD_MAX:
		shield_timer += delta
