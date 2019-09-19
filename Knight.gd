extends KinematicBody2D

enum State { IDLE, CHASE }

const MAX_MOVE_SPEED = 50
const ACCELERATION = 10

var motion = Vector2()

onready var state = State.IDLE

func _physics_process(delta):
	# may be a better way to tell enemies player doesn't exist (or is dead) cuz this is bad practice and inefficent
	var skeleton = get_tree().get_root().find_node("Skeleton", true, false)
	if skeleton == null:
		state = State.IDLE
	else:
		state = State.CHASE
	
	match state:
		State.IDLE:
			process_idle()
		State.CHASE:
			process_chase(skeleton)
			
	move_and_slide(motion)
	

func process_idle():
	$Anim.play("idle")
	motion.x = lerp(motion.x, 0, 0.25)
	
	
func process_chase(chase):
	var x_scale = sign(chase.position.x - position.x)
	if x_scale == 0:
		x_scale = 1
		
	if x_scale > 0:
		motion.x = min(motion.x + ACCELERATION, MAX_MOVE_SPEED)
	else:
		motion.x = max(motion.x - ACCELERATION, -MAX_MOVE_SPEED)
		
	$Anim.play("walk")
	$Flippable.scale.x = x_scale
			
			
			