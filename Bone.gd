extends KinematicBody2D

const GRAVITY = 10
const GROUND_LIMIT = 156
const SWORD_ANGLE = 220
const SWORD_FRAME = 5

var boneFrame
var isFlipped = false
var motion

func _ready():
	$Sprite.frame = boneFrame
	if boneFrame == SWORD_FRAME:	# special angle for sword
		rotation_degrees = SWORD_ANGLE
		add_game_over_timer()
	else:
		rotation_degrees = rand_range(0, 360)
		
	var facing = -1
	if isFlipped:
		facing = 1
		
	motion = Vector2(rand_range(50 * facing, 250 * facing), rand_range(-100, -200))
	
	
func _physics_process(delta):
	if global_position.y < GROUND_LIMIT:
		motion.y += GRAVITY
		move_and_slide(motion)
		

func add_game_over_timer():
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_timer_process_mode(1)		# enumerated - 1 = TIMER_PROCESS_IDLE
	timer.set_wait_time(2)
	timer.connect("timeout", self, "_timer_timeout")
	timer.start()
	add_child(timer)
	

func _timer_timeout():
	print("bone timeout")	# transition to game over screen after saving score(s)
	
	