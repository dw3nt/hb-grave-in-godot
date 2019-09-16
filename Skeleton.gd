extends KinematicBody2D

enum State { MOVE, ROLL, ATTACK_ONE }

const MAX_RUN_SPEED = 200
const ACCELERATION = 20

var motion = Vector2()

onready var state = State.MOVE

func _physics_process(delta):
	if Input.is_action_just_pressed("roll"):
		state = State.ROLL
	elif Input.is_action_just_pressed("attack"):
		state = State.ATTACK_ONE
	
	match state:
		State.ROLL:
			process_roll()
		State.ATTACK_ONE:
			process_attack()
		State.MOVE:
			process_move()
	
	move_and_slide(motion)


func process_attack():
	$Anim.play("attack_one")
	motion.x = lerp(motion.x, 0, 0.25)
	
	
func process_roll():
	$Anim.play("roll")
	motion.x = 200 * sign(motion.x)
	
	
func process_move():
	if should_stop():
		motion.x = lerp(motion.x, 0, 0.25)
		$Anim.play("idle")
	elif Input.is_action_pressed("move_left"):
		motion.x = max(motion.x - ACCELERATION, -MAX_RUN_SPEED)
		$Anim.play("run")
		$Sprite.flip_h = true
	elif Input.is_action_pressed("move_right"):
		motion.x = min(motion.x + ACCELERATION, MAX_RUN_SPEED)
		$Anim.play("run")
		$Sprite.flip_h = false
	else:
		$Anim.play("idle")

	
func should_stop():
	return (!Input.is_action_pressed("move_left") && !Input.is_action_pressed("move_right")) || (Input.is_action_pressed("move_left") && Input.is_action_pressed("move_right"))


func _on_Anim_animation_finished(anim_name):
	match anim_name:
		"roll":
			motion.x = 100 * sign(motion.x)
			state = State.MOVE
		"attack_one":
			state = State.MOVE
