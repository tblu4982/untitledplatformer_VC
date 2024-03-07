extends CharacterBody2D

signal jump
signal dash
signal punch
signal smoke_call

const SPEED = 100.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var double_jump = false
var is_punching = false
var charging_punch = false
var idle_timer = 0
var signal_sprint = false
var punch_charge = 0
var face_pos = false
var in_ladder_space = false
var is_climbing = false

func _physics_process(delta):
	var move_speed = SPEED
	# Add the gravity.
	if not is_on_floor() and not is_climbing:
		is_punching = false
		velocity.y += gravity * delta
		if velocity.y < 0:
			$AnimatedSprite2D.animation = "fall"
		elif velocity.y > 0:
			$AnimatedSprite2D.animation = "jump"
		$AnimatedSprite2D.play()
	else:
		double_jump = true
		if Input.is_action_pressed("punch"):
			if !charging_punch:
				$AnimatedSprite2D.animation = "punch_windup"
			else:
				$AnimatedSprite2D.animation = "punch_charge"
				if $AnimatedSprite2D.frame == 1:
					punch_charge += delta
			if $AnimatedSprite2D.frame == 4:
				charging_punch = true
			is_punching = true
		if Input.is_action_just_released("punch"):
			charging_punch = false
			$AnimatedSprite2D.animation = "punch"
			smoke_call.emit()
			punch.emit(position, punch_charge, face_pos)
			punch_charge = 0
		$AnimatedSprite2D.play()
			
	if $AnimatedSprite2D.frame == 5:
		is_punching = false
		
	if Input.is_action_pressed("sprint"):
		move_speed = SPEED * 2

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or in_ladder_space:
			velocity.y = JUMP_VELOCITY
			smoke_call.emit()
			jump.emit(position)
			is_climbing = false
		elif double_jump:
			velocity.y = JUMP_VELOCITY
			double_jump = false
			smoke_call.emit()
			jump.emit(position)
			is_climbing = false
			
	if Input.is_action_pressed("interact"):
		is_climbing = true
			
	if velocity.y != 0:
		idle_timer = 0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_h = Input.get_axis("move_left", "move_right")
	var direction_v = Input.get_axis("up", "down")
	
	if not is_climbing:
		if direction_h:
			idle_timer = 0
			if is_punching:
				velocity.x = 0
				if $AnimatedSprite2D.frame == 2:
					is_punching = false
			else:
				velocity.x = direction_h * move_speed
				face_pos = velocity.x > 0
				if is_on_floor():
					if move_speed > SPEED:
						$AnimatedSprite2D.animation = "run"
						if !signal_sprint:
							smoke_call.emit()
							dash.emit(velocity.x, position)
							signal_sprint = true
					else:
						$AnimatedSprite2D.animation = "walk"
				$AnimatedSprite2D.flip_h = direction_h < 0
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			signal_sprint = false
			if velocity.y == 0 and !is_punching:
				if idle_timer >= 5:
					$AnimatedSprite2D.animation = "wait"
				else:
					$AnimatedSprite2D.animation = "idle"
				idle_timer += delta
		$AnimatedSprite2D.play()
	else:
		if direction_v:
			$AnimatedSprite2D.animation = "climb"
			if direction_v > 0:
				$AnimatedSprite2D.play_backwards()
			else:
				$AnimatedSprite2D.play()
		else:
			$AnimatedSprite2D.pause()
		velocity.y = direction_v * SPEED
		velocity.x = direction_h * SPEED

	move_and_slide()

func _on_area_2d_body_entered(body):
	print("enter")
	in_ladder_space = true


func _on_area_2d_body_exited(body):
	print("exit")
	in_ladder_space = false
	is_climbing = false
