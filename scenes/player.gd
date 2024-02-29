extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var double_jump = false


func _physics_process(delta):
	var move_speed = SPEED
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y < 0:
			$AnimatedSprite2D.animation = "fall"
		elif velocity.y > 0:
			$AnimatedSprite2D.animation = "jump"
	else:
		double_jump = true
		
	if Input.is_action_pressed("sprint"):
		move_speed = SPEED * 2

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif double_jump:
			velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * move_speed
		if is_on_floor():
			if move_speed > SPEED:
				$AnimatedSprite2D.animation = "run"
			else:
				$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		if velocity.y == 0:
			$AnimatedSprite2D.animation = "idle"

	move_and_slide()
		
	$AnimatedSprite2D.play()
