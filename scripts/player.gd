extends CharacterBody3D


const SPEED = 12
const JUMP_VELOCITY = 25
const HITBOX_OFFSET = Vector3(0.7, 0, 0)
const TUMBLE_THREASHOLD = 5
const TUMBLE_DRAG = 0.8
# The tick coldown for a punch
const PUNCH_DELAY = 0.5
const SHIELD_MAX = 1.0
const SHIELD_DMG_PENALTY = -0.5
const TUMBLE_ROTATION = PI*2

const JIMMIE_SPECIAL_DELAY = 1.0
const JIMMIE_SPECIAL_RAMP_UP = 0.5
const JIMMIE_HITBOX_OFFSET = Vector3(2.0, 0, 0)
const JIMMIE_SPECIAL_COOLDOWN_MAX = 5.0

var jimmie_special_cooldown = 0.0
var is_jimmie_special_spawned = false

const IDLE = 0
const PUNCH = 1
const TUMBLE = 2
const SHIELD = 3
const SPECIAL = 4

var player_state = 0
var player = ""
var device = null
var cooldown = 0.0
var shield_timer = SHIELD_MAX
var hitbox = null
var last_move_dir = -1
var run_animation_timestamp = 0.0
var rng = RandomNumberGenerator.new()
var rotation_dir = 1
var og_rotation = null
var og_model_transform 
var input_dir
var shield = null
var punch_cooldown = 0.0
var can_punch = true
var can_special = true
var character_id = 0

@onready var model = $Model
@onready var animator = $Model/AnimationPlayer
@onready var hitbox_node = load("res://scenes/hitbox.tscn")
@onready var jimmie_hitbox_node = load("res://scenes/jimmie_hitbox.tscn")
@onready var shield_node = load("res://scenes/shield.tscn")
@onready var jimmie_model = load("res://scenes/jimmie_model.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func set_player(arg_device: String) -> void:
	player = "p" + arg_device
	device = arg_device
	print_debug("new player: ", player)
	
func set_character(arg_character_id: int):
	character_id = arg_character_id

func take_damage(player_dir, player_vector, scale) -> void:
	if not player_state == SHIELD:
		# TODO: jimmie
		launch_player(Vector3(
			(10.0 * player_dir + 10 * player_vector.x) * scale, 
			(20.0 + 20.0 * player_vector.y * -1) * scale, 
			0
		))
		print(player + " took damage")
		shield_timer += SHIELD_DMG_PENALTY 

func _ready():
	og_rotation = rotation
	og_model_transform = model.transform
	

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
			
	if player_state == TUMBLE:
		do_tumble(delta)
		return
	
	if player_state == SPECIAL:
		do_special(delta)
		move_and_slide()
		return

	do_shield(delta)
	
	if jimmie_special_cooldown >= 0.0:
		jimmie_special_cooldown -= delta
	
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
		animator.play("ArmatureAction 2")
		animator.speed_scale = 1.0
		do_punch()
	
	elif Input.is_action_just_pressed("shield_" + player) and (player_state == IDLE or player_state == SHIELD):
		player_state = SHIELD
		shield = shield_node.instantiate()
		add_child(shield)
	
	elif Input.is_action_just_released("shield_" + player):
		player_state = IDLE
		if shield != null:
			shield.queue_free()
	
	if Input.is_action_just_pressed("special_" + player) and player_state == IDLE:
		if (jimmie_special_cooldown <= 0.0):
			player_state = SPECIAL
			init_special()
		return

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	input_dir = Input.get_vector("left_" + player, 
		"right_" + player, 
		"up_" + player, 
		"down_" + player
	)
	
	if input_dir.x > 0 or (last_move_dir > 0 and punch_cooldown > 0.0):
		model.rotation = Vector3(0, -PI/2, 0)
	elif input_dir.x < 0 or (last_move_dir < 0 and punch_cooldown > 0.0):
		model.rotation = Vector3(0, PI/2, 0)
	elif input_dir.x == 0 and player_state != TUMBLE:
		model.rotation = Vector3(0, PI, 0)
		
	if input_dir.x != 0:
		velocity.x = input_dir.x * SPEED
		if input_dir.x < 0:
			last_move_dir = -1
		else:
			last_move_dir = 1
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Play run animation if where moving
	
	if punch_cooldown <= 0:
		if not is_on_floor():
			if velocity.y > 0:
				animator.play("jump")
			else:
				animator.play("fall")
		elif velocity.x == 0:
			if animator.current_animation == "Run":
				run_animation_timestamp = animator.current_animation_position
				
			animator.play("Idel")
		else:
			if animator.current_animation != "Run":
				animator.play("Run")
				animator.advance(run_animation_timestamp)
			animator.speed_scale = abs(input_dir.x)*4

	if Input.is_action_just_pressed("test_launch_p1"):
		change_character(jimmie_model.instantiate(), Vector3(3, 3, 3))
	
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

func init_special():
	print_debug("special initialied by ", player)
	cooldown = JIMMIE_SPECIAL_DELAY
	pass

func do_special(delta):
	if jimmie_special_cooldown <= 0.0:
		velocity.x = 0
		if cooldown <= 0.0:
			cooldown = 0.0
			player_state = IDLE
			is_jimmie_special_spawned = false
			jimmie_special_cooldown = JIMMIE_SPECIAL_COOLDOWN_MAX
			return
		elif cooldown <= JIMMIE_SPECIAL_RAMP_UP and not is_jimmie_special_spawned:
			print("ramp")
			var hitbox = jimmie_hitbox_node.instantiate()
			hitbox.set_player(self)
			hitbox.position += JIMMIE_HITBOX_OFFSET * last_move_dir
			hitbox.max_timer = JIMMIE_SPECIAL_DELAY - JIMMIE_SPECIAL_RAMP_UP
			add_child(hitbox)
			is_jimmie_special_spawned = true
	
	cooldown -= delta
		
func change_character(new_model, new_scale = Vector3(1, 1, 1)):
	new_model.transform = og_model_transform.scaled(new_scale)
	new_model.rotation = model.rotation
	new_model.position.y = -0.4 + 0.7*(new_scale.y-1)
	model.queue_free()
	model = new_model
	animator = new_model.get_node("AnimationPlayer")
	add_child(model)
