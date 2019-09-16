extends KinematicBody2D

const MAX_RUN_SPEED = 200
const ACCELERATION = 20

var motion = Vector2()

func _physics_process(delta):
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
		
	move_and_slide(motion)
	
	
func should_stop():
	return (!Input.is_action_pressed("move_left") && !Input.is_action_pressed("move_right")) || (Input.is_action_pressed("move_left") && Input.is_action_pressed("move_right"))