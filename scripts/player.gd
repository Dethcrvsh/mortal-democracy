extends CharacterBody3D


const SPEED = 10
const JUMP_VELOCITY = 25
const HITBOX_OFFSET = Vector3(1, 0, 0)
const TUMBLE_THREASHOLD = 1
const TUMBLE_DRAG = 0.8
# The tick coldown for a punch
const PUNCH_DELAY = 10

var player = ""
var is_punching = false
var punch_counter = 0
var hitbox = null
var last_move_dir = -1
var is_tumble = false
var tumble_time = 0.0
var run_animation_timestamp = 0.0

@onready var model = $person_model
@onready var hitbox_node = load("res://scenes/hitbox.tscn")
@onready var animator = $person_model/placeholder_person_run/AnimationPlayer

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
			
	if  is_tumble:
		tumble_time += delta
		
		if is_on_floor() and velocity.length() < TUMBLE_THREASHOLD:
			is_tumble = false
			
		if tumble_time > 0.1:
			tumble_time = 0.0
			velocity.x *= 0.8

	else:
	
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
			hitbox.position += HITBOX_OFFSET * last_move_dir
			hitbox.set_player(self)
			add_child(hitbox)
			is_punching = true

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir = Input.get_vector("left_" + player, "right_" + player, "ui_up", "ui_down")
		
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

func launch_player(launch_vector):
	is_tumble = true
	velocity.x = launch_vector.x
	velocity.y = launch_vector.y
	
