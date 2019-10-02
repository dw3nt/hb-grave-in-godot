extends KinematicBody2D

enum State { IDLE, CHASE, ATTACK }

const MAX_MOVE_SPEED = 50
const ACCELERATION = 10

onready var state = State.CHASE
onready var skeleton = get_tree().get_root().find_node("Skeleton", true, false)

var motion = Vector2()
var isFlipped = false
var inAttackRange = false

func _physics_process(delta):
	# may be a better way to tell enemies player doesn't exist (or is dead) cuz this is bad practice and inefficent
	if skeleton == null:
		state = State.IDLE
	
	match state:
		State.IDLE:
			set_face_direction(skeleton)
			process_idle()
		State.CHASE:
			set_face_direction(skeleton)
			process_chase(skeleton)
		State.ATTACK:
			process_attack()
			
	move_and_slide(motion)
	

func process_idle():
	$Anim.play("idle")
	motion.x = lerp(motion.x, 0, 0.25)
	
	
func process_chase(chase):
	if !isFlipped:
		motion.x = min(motion.x + ACCELERATION, MAX_MOVE_SPEED)
	else:
		motion.x = max(motion.x - ACCELERATION, -MAX_MOVE_SPEED)
		
	$Anim.play("walk")
	
	
func process_attack():
	$Anim.play("attack")
	motion.x = lerp(motion.x, 0, 0.25)
			

func set_face_direction(faceTowards):
	if faceTowards.position.x > position.x && isFlipped:
		isFlipped = false
		scale.x = -1
	elif faceTowards.position.x < position.x && !isFlipped:
		isFlipped = true
		scale.x = -1
	

func _on_AttackDetect_body_entered(body):
	if body.get_name() == "Skeleton":
		inAttackRange = true
		state = State.ATTACK


func _on_AttackDetect_body_exited(body):
	if body.get_name() == "Skeleton":
		inAttackRange = false


func _on_Anim_animation_finished(anim_name):
	if anim_name == "attack":
		if inAttackRange:
			set_face_direction(skeleton)
		else:
			state = State.CHASE
