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
const SHIELD_COOLDOWN = 1.0

const JIMMIE_SPECIAL_DELAY = 1.0
const JIMMIE_SPECIAL_RAMP_UP = 0.3
const JIMMIE_HITBOX_OFFSET = Vector3(2.0, 0, 0)
const JIMMIE_SPECIAL_COOLDOWN_MAX = 2.0

var jimmie_special_cooldown = 0.0
var is_jimmie_special_spawned = false

const IDLE = 0
const PUNCH = 1
const TUMBLE = 2
const SHIELD = 3
const SPECIAL = 4
const SHOE_SPEED = 20
const SHOE_OFFSET = Vector3(0.3, 0.8, 0)
const ANNIE_COOLDOWN = 1.0

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
var annie_timer = ANNIE_COOLDOWN
var talking = false
var shield_cooldown = 0.0

var stefan_special = null
var stefan_special_cooldown = 0
var ulf_special = null
var ulf_special_cooldown = 0
var ulf_special_direction = null
var collision_shape: CollisionShape3D = null

@onready var audio_player = AudioStreamPlayer.new()
@onready var audio_player2 = AudioStreamPlayer.new()
@onready var test_audio = load("res://Audio/test.ogg")
@onready var swoosh_audio = load("res://Audio/slash.ogg")
@onready var punch_audio = load("res://Audio/punch.mp3")
@onready var jimmy_special_audio = load("res://Audio/jimmy_special.mp3")
@onready var male_hurt = load("res://Audio/male_hurt.mp3")
@onready var female_hurt = load("res://Audio/female_hurt.mp3")
@onready var model = $Model
@onready var animator = $Model/AnimationPlayer
@onready var hitbox_node = load("res://scenes/hitbox.tscn")
@onready var jimmie_hitbox_node = load("res://scenes/jimmie_hitbox.tscn")
@onready var shield_node = load("res://scenes/shield.tscn")
@onready var jimmie_model = load("res://scenes/jimmie_model.tscn")
@onready var stefan_special_asset = load("res://scenes/SpecialAttackStefan.tscn")
@onready var ulf_special_asset = load("res://scenes/SpecialAttackUlf.tscn")
@onready var iron_bar_model = load("res://scenes/IronBar.tscn")
@onready var shoe_scene = load("res://scenes/shoe.tscn")

@onready var jimmy_model = load("res://scenes/jimmie_with_jarnror.tscn")
@onready var annie_model = load("res://scenes/annie_model.tscn")
@onready var stefan_model = load("res://scenes/stefan_model.tscn")
@onready var ulf_model = load("res://scenes/ulf_model.tscn")
var id_to_model = null

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func set_player(arg_device: String) -> void:
	player = "p" + arg_device
	device = arg_device
	
func take_damage(player_dir, player_vector, scale) -> void:
	if character_id == 0 and player_state == SPECIAL:
		return
	
	if not player_state == SHIELD:
		# TODO: jimmie
		launch_player(Vector3(
			(10.0 * player_dir + 10 * player_vector.x) * scale, 
			(20.0 + 20.0 * player_vector.y * -1) * scale, 
			0
		))
		print(player + " took damage")
		shield_timer += SHIELD_DMG_PENALTY 
		if character_id == 1:
			audio_player.volume_db = -0.15
			audio_player.stream = female_hurt
		else:
			audio_player.volume_db = 0.3
			audio_player.stream = male_hurt
		audio_player.play()
		audio_player2.stream = punch_audio
		audio_player2.play()

func _ready():
	id_to_model = {0:jimmy_model, 1:annie_model, 2:stefan_model, 3:ulf_model}
	og_rotation = rotation
	og_model_transform = model.transform
	collision_shape = get_node("CollisionShape3D")
	add_child(audio_player)
	add_child(audio_player2)
	audio_player.stream = test_audio
	var random_character = rng.randi_range(0, 3)
	var random_character_scale = Vector3(1,1,1)
	if random_character == 3:
		random_character_scale *= 0.6
	change_character(random_character, random_character_scale)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor() and not ulf_special_active():
		velocity.y -= gravity * delta
	
	if character_id == 2:
		stefan_special_cooldown -= delta
	if character_id == 3:
		ulf_special_cooldown -= delta
			
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
		animator.play("Punch")
		animator.speed_scale = 1.0
		do_punch()
	
	elif Input.is_action_just_pressed("shield_" + player) and (player_state == IDLE or player_state == SHIELD):
		if shield_cooldown <= 0.0:
			player_state = SHIELD
			shield = shield_node.instantiate()
			shield_cooldown = SHIELD_COOLDOWN
			add_child(shield)
	
	elif Input.is_action_just_released("shield_" + player):
		player_state = IDLE
		if shield != null:
			shield.queue_free()
	

	if Input.is_action_just_pressed("special_" + player) and player_state == IDLE and check_special():
		player_state = SPECIAL
		init_special()
		return

	if annie_timer <= ANNIE_COOLDOWN:
		annie_timer += delta
		
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
	elif input_dir.x == 0 and player_state == IDLE:
		model.rotation = Vector3(0, PI, 0)
		
	if input_dir.x != 0 and player_state != SHIELD:
		velocity.x = input_dir.x * SPEED
		if input_dir.x < 0:
			last_move_dir = -1
		else:
			last_move_dir = 1
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if character_id == 0 and player_state == SPECIAL:
		move_and_slide()
		return
	
	# Play run animation if where moving
	if punch_cooldown <= 0:
		if talking:
			animator.play("talk")
			animator.speed_scale = 1.0
			
		elif not is_on_floor():
			if velocity.y > 0:
				animator.play("jump")
			else:
				animator.play("fall")
		elif velocity.x == 0:
			if animator.current_animation == "Run":
				run_animation_timestamp = animator.current_animation_position
			
			if player_state != SPECIAL:
				animator.play("Idel")
		else:
			if animator.current_animation != "Run":
				animator.play("Run")
				animator.advance(run_animation_timestamp)
			animator.speed_scale = abs(input_dir.x)*4
	
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
	if shield_cooldown >= 0.0:
		shield_cooldown -= delta
		return
	
	if player_state == SHIELD:
		if shield_timer < 0:
			player_state = IDLE
			shield.queue_free()
			shield_cooldown = SHIELD_COOLDOWN
		else:
			shield_timer -= delta
	elif shield_timer < SHIELD_MAX:
		shield_timer += delta

func init_special():
	print_debug("special initialied by ", player)
	
	#jimmie
	if character_id == 0:
		animator.play("järnrör")
		animator.speed_scale = 2
		if last_move_dir > 0:
			model.rotation = Vector3(0, -PI/2, 0)
		else:
			model.rotation = Vector3(0, PI/2, 0)
		cooldown = JIMMIE_SPECIAL_DELAY
		
		velocity.x = 0
		
	# annie
	if character_id == 1:
		
		annie_special()
	
	# stefan
	if character_id == 2: 
		stefan_special = stefan_special_asset.instantiate()
		add_child(stefan_special)
		stefan_special.set_player(self)
		stefan_special.max_timer = 0.75
		audio_player.volume_db = -0.25
		audio_player.stream = test_audio
		audio_player.play()
		return
	
	if character_id == 3:
		ulf_special = ulf_special_asset.instantiate()
		add_child(ulf_special)
		ulf_special.set_player(self)
		ulf_special.max_timer = 0.25
		velocity.x = last_move_dir * 20
		velocity.y = 0
		if last_move_dir > 0:
			ulf_special.rotation = Vector3(0, PI, 0)
		self.rotation.z = - PI/3 * last_move_dir
		audio_player.stream = test_audio
		audio_player.volume_db = -0.25
		audio_player.play()
		return

func do_special(delta):
	
	print_debug("special initialied by ", player, "as ", character_id)
	
	#jimmie
	if character_id == 0:
		do_jimmie_special(delta)
		
	# annie
	if character_id == 1:
		annie_special()
	
	# stefan
	if character_id == 2:
		if stefan_special == null:
			player_state = IDLE
			stefan_special_cooldown = 1
		return
	
	# ulf
	if character_id == 3:
		if ulf_special == null:
			player_state = IDLE
			ulf_special_cooldown = 2
			velocity.x = 0
			self.rotation.z = 0
		return

func check_special():
	
	if (character_id == 0 and jimmie_special_cooldown <= 0.0) or (character_id == 1):
		return true
		
	# ulf
	if character_id == 3:
		if ulf_special_cooldown > 0:
			return false
		return true
	
	# stefan
	if character_id == 2:
		if stefan_special_cooldown > 0:
			return false
		return true
	return false


func do_jimmie_special(delta):
	if jimmie_special_cooldown <= 0.0:
		velocity.x = 0
		if cooldown <= 0.0:
			cooldown = 0.0
			player_state = IDLE
			is_jimmie_special_spawned = false
			jimmie_special_cooldown = JIMMIE_SPECIAL_COOLDOWN_MAX
			return
		elif cooldown <= JIMMIE_SPECIAL_RAMP_UP and not is_jimmie_special_spawned:
			#Spawn the hitbox
			var hitbox = jimmie_hitbox_node.instantiate()
			audio_player.volume_db = 0.0
			audio_player.stream = jimmy_special_audio
			audio_player.play()
			hitbox.set_player(self)
			hitbox.position += JIMMIE_HITBOX_OFFSET * last_move_dir
			hitbox.max_timer = 0.2
			
			add_child(hitbox)
			is_jimmie_special_spawned = true
	
	cooldown -= delta
		
func change_character(char_id, new_scale = Vector3(1, 1, 1)):
	character_id = char_id
	var model_instance = id_to_model[character_id].instantiate()
	print_debug("character id: ", character_id)
	model_instance.transform = og_model_transform.scaled(new_scale)
	model_instance.rotation = model.rotation
	self.rotation.z = 0
	model_instance.position.y = -0.4 + 0.7*(new_scale.y-1)
	model.queue_free()
	model = model_instance
	animator = model.get_node("AnimationPlayer")
	add_child(model)
	player_state = IDLE
	
	# ulf christerson magic
	if character_id == 3:
		collision_shape.shape.height = 1
		collision_shape.position.y = -0.3
	else:
		collision_shape.shape.height = 1.8
		collision_shape.position.y = 0

func annie_special():
	if annie_timer > ANNIE_COOLDOWN:
		var shoe_inst = shoe_scene.instantiate()
		get_parent().add_child(shoe_inst)
		shoe_inst.set_player(self)
		shoe_inst.set_spawn_dir(last_move_dir)
		shoe_inst.set_linear_velocity(Vector3(last_move_dir*SHOE_SPEED, SHOE_SPEED/6, 0))
		shoe_inst.global_position = global_position + Vector3(SHOE_OFFSET.x*last_move_dir, SHOE_OFFSET.y, 0)
		annie_timer = 0.0
		audio_player.stream = swoosh_audio
		audio_player.volume_db = -3.0
		audio_player.play()
	player_state = IDLE

func ulf_special_active():
	if character_id == 3:
		return player_state == SPECIAL
	return false
