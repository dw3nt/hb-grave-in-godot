extends KinematicBody2D

enum State { MOVE, ROLL }

const MAX_RUN_SPEED = 200
const ACCELERATION = 20

onready var state = State.MOVE
var motion = Vector2()

func _physics_process(delta):
	if Input.is_action_just_pressed("roll"):
		state = State.ROLL
	
	match state:
		State.MOVE:
			process_move()
		State.ROLL:
			process_roll()
	
	move_and_slide(motion)
	
	
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
		

func process_roll():
	var x_direction = 1
	if $Sprite.flip_h:
		x_direction = -1
	
	$Anim.play("roll")
	motion.x = 200 * x_direction

	
func should_stop():
	return (!Input.is_action_pressed("move_left") && !Input.is_action_pressed("move_right")) || (Input.is_action_pressed("move_left") && Input.is_action_pressed("move_right"))


func _on_Anim_animation_finished(anim_name):
	if anim_name == "roll":
		state = State.MOVE
