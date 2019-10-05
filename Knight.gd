extends KinematicBody2D

enum State { IDLE, CHASE, ATTACK }

const MAX_MOVE_SPEED = 50
const ACCELERATION = 10

var motion = Vector2()
var isFlipped = false
var inAttackRange = false
var maxHp = 25
var hp = maxHp

onready var state = State.CHASE
onready var skeleton = get_tree().get_root().find_node("Skeleton", true, false)

func _physics_process(delta):
	# may be a better way to tell enemies player doesn't exist (or is dead) cuz this seems like bad practice / inefficent
	if skeleton == null:
		state = State.IDLE
	
	match state:
		State.IDLE:
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
	
	
func process_hit(attacker, damage):
	print("Knight took " + str(damage) + " from " + attacker.name)
	hp -= damage
	if hp <= 0:
		queue_free()
			

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
		if get_tree().get_root().find_node("Skeleton", true, false):
			if inAttackRange:
				set_face_direction(skeleton)
			else:
				state = State.CHASE
		else:
			skeleton = null
