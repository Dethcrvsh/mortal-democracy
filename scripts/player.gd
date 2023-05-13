extends CharacterBody3D


const SPEED = 50
const JUMP_VELOCITY = 50
const PLAYER_CONST = "p1"

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var last_move_dir = -1
var is_tumble = false
@onready var model = $person_model
@onready var animator = $person_model/placeholder_person_run/AnimationPlayer

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

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
		animator.play("Idel")
	else:
		animator.play("Run", -1, abs(input_dir.x)*2)
	
	move_and_slide()
