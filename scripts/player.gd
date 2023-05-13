extends CharacterBody3D


const SPEED = 10
const JUMP_VELOCITY = 25
const HITBOX_OFFSET = Vector3(0.7, 0, 0)
const TUMBLE_THREASHOLD = 1
const TUMBLE_DRAG = 0.8
# The tick coldown for a punch
const PUNCH_DELAY = 0.2
const TUMBLE_ROTATION = PI*2

var player = ""
var is_punching = false
var punch_time = 0.0
var hitbox = null
var last_move_dir = -1
var is_tumble = false
var tumble_time = 0.0
var run_animation_timestamp = 0.0
var rng = RandomNumberGenerator.new()
var rotation_dir = 1
var og_rotation = null
var input_dir

@onready var model = $person_model
@onready var hitbox_node = load("res://scenes/hitbox.tscn")
@onready var animator = $person_model/placeholder_person_run/AnimationPlayer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func set_player(index: int) -> void:
	player = "p" + str(index + 1)

func take_damage(player_dir, player_vector) -> void:
	launch_player(Vector3(
		10.0 * player_dir + 10 * player_vector.x, 
		20.0 + 20.0 * player_vector.y * -1, 
		-20.0
	))
	print(player + " took damage")

func _ready():
	og_rotation = rotation
	

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
			
	if is_punching:
		do_punch(delta)
	
	# Todo Remove this
	if player != "p1":
		move_and_slide()
		return
			
	if  is_tumble:
		animator.play("tumble")
		
		rotate(Vector3(0.0, 0.0, 1.0), TUMBLE_ROTATION*delta*rotation_dir)
		tumble_time += delta
		
		if is_on_floor() and velocity.length() < TUMBLE_THREASHOLD:
			rotation = og_rotation
			is_tumble = false
			
		if tumble_time > 0.1:
			tumble_time = 0.0
			velocity.x *= 0.8
		
		var saved_velocity = velocity
		
		move_and_slide()
		
		var collision = get_slide_collision(0)
		if collision:
			var bounce_direction = collision.get_collider(0).global_position.direction_to(global_position)
			velocity = saved_velocity.length()*0.5*bounce_direction
		return

	# Handle Jump.
	if Input.is_action_just_pressed("jump_" + player) and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("attack_" + player) and not is_punching:
		hitbox = hitbox_node.instantiate()
		hitbox.position += HITBOX_OFFSET * last_move_dir
		hitbox.set_player(self)
		add_child(hitbox)
		is_punching = true

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
	tumble_time += delta
	
	if is_on_floor() and velocity.length() < TUMBLE_THREASHOLD:
		is_tumble = false
		
	if tumble_time > 0.1:
		tumble_time = 0.0
		velocity.x *= 0.8
	move_and_slide()

func launch_player(launch_vector):
	is_tumble = true
	velocity.x = launch_vector.x
	velocity.y = launch_vector.y
	
	var random_i = rng.randi_range(0, 1)
	print(random_i)
	if random_i == 0:
		rotation_dir = 1
	else:
		rotation_dir = -1

func do_punch(delta):
	if punch_time < PUNCH_DELAY:
			punch_time += delta
	else:
		hitbox.queue_free()
		punch_time = 0.0
		is_punching = false
	
