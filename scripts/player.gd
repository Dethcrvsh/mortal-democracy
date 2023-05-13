extends CharacterBody3D


const SPEED = 10
const JUMP_VELOCITY = 25
const TUMBLE_THREASHOLD = 1
const TUMBLE_DRAG = 0.8
const PLAYER_CONST = "p1"

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var last_move_dir = -1
var run_animation_timestamp = 0.0
var is_tumble = false
var tumble_time = 0.0
@onready var model = $person_model
@onready var animator = $person_model/placeholder_person_run/AnimationPlayer

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if  is_tumble:
		tumble_time += delta
		
		if is_on_floor() and velocity.length() < TUMBLE_THREASHOLD:
			is_tumble = false
			
		if tumble_time > 0.1:
			tumble_time = 0.0
			velocity.x *= 0.8
		
	else:
		# Handle Jump.
		if Input.is_action_just_pressed("jump_" + PLAYER_CONST) and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir = Input.get_vector("left_" + PLAYER_CONST, "right_" + PLAYER_CONST, "ui_up", "ui_down")
		if input_dir.x != 0:
			velocity.x = input_dir.x * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		# Flip model if we changed direction
		if input_dir.x > 0 and last_move_dir < 0 or input_dir.x < 0 and last_move_dir > 0:
			model.rotate_y(PI)
			last_move_dir = input_dir.x
		
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
	
