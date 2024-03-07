extends AnimatedSprite2D

var dash = false
var jump = false
var punch = false
var punch_magnitude = 0
var direction = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if dash:
		animation = "dash_01"
		flip_h = direction
		play()
		dash = false
	if jump:
		animation = "lift_01"
		play()
		jump = false
	if punch:
		if punch_magnitude >= 0.7:
			animation = "punch_heavy"
			flip_h = direction
			play()
		elif punch_magnitude >= 0.4:
			animation = "punch_medium"
			flip_h = direction
			play()
		elif punch_magnitude >= 0.2:
			animation = "punch_light"
			flip_h = direction
			play()
		punch = false


func _on_player_dash(vel, pos):
	direction = vel < 0
	position = pos
	if direction:
		position.x += 20
	else:
		position.x -= 20 
	dash = true


func _on_player_jump(pos):
	position = pos
	position.y += 10
	jump = true


func _on_player_punch(pos, power, dir):
	position = pos
	direction = dir
	if direction:
		position.x += 5
	else:
		position.x -= 5
	punch = true
	punch_magnitude = power
