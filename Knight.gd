extends KinematicBody2D

signal knight_hp_changed
signal enemy_death

enum State { IDLE, CHASE, ATTACK, KNOCKBACK }

const MAX_MOVE_SPEED = 50
const ACCELERATION = 10

var motion = Vector2()
var isDodgeable = false
var isFlipped = false
var inAttackRange = false
var maxHp = 25
var hp = maxHp
var knockbackSpeed = 0
var expScene = load("res://Experience.tscn")
var expOrbs = 5
var expAmount = 1
var shouldIdle = false

onready var state = State.CHASE
onready var skeleton = get_tree().get_root().find_node("Skeleton", true, false)

func _ready():
	$EnemyHP.hpTotal = maxHp
	$EnemyHP.currentHp = maxHp
	$EnemyHP.init()
	reset_hitboxes()

func _physics_process(delta):
	# may be a better way to tell enemies player doesn't exist (or is dead) cuz this seems like bad practice / inefficent
	if skeleton == null:
		state = State.IDLE
	
	match state:
		State.IDLE:
			reset_hitboxes()
			process_idle()
		State.CHASE:
			reset_hitboxes()
			set_face_direction(skeleton)
			process_chase(skeleton)
		State.ATTACK:
			process_attack()
		State.KNOCKBACK:
			reset_hitboxes()
			process_knockback()
			
	move_and_slide(motion)
	

func process_idle():
	if $Anim.current_animation != "idle":
		$Anim.play("idle")
		
	motion.x = lerp(motion.x, 0, 0.25)
	
	
func process_chase(chase):
	if !isFlipped:
		motion.x = min(motion.x + ACCELERATION, MAX_MOVE_SPEED)
	else:
		motion.x = max(motion.x - ACCELERATION, -MAX_MOVE_SPEED)
		
	if $Anim.current_animation != "walk":
		$Anim.play("walk")
	
	
func process_attack():
	if $Anim.current_animation != "knockback":
		$Anim.play("attack")
		
	motion.x = lerp(motion.x, 0, 0.25)
	
	
func process_hit(attacker, damage, knockback):
	state = State.KNOCKBACK
	if attacker.position.x > self.position.x:
		knockbackSpeed = -knockback
	else:
		knockbackSpeed = knockback
	set_face_direction(attacker)
		
	hp -= damage
	if hp <= 0:
		process_death()
	else:
		$EnemyHP.update_hp(hp)
		emit_signal("knight_hp_changed", hp)
		

func process_knockback():
	if $Anim.current_animation != "knockback":
		$Anim.play("knockback")
	motion.x = lerp(motion.x, 0, 0.025)
	
	
func process_death():
	var expParent = get_tree().get_root().find_node("Experience", true, false)
	for i in range(expOrbs):
		var inst = expScene.instance()
		inst.global_position = global_position
		inst.amount = expAmount
		expParent.add_child(inst)
	
	emit_signal("enemy_death")
	queue_free()
			

func set_face_direction(faceTowards):
	if faceTowards.position.x > position.x && isFlipped:
		isFlipped = false
		scale.x = -1
		$EnemyHP.set_rotation_degrees(0)
	elif faceTowards.position.x < position.x && !isFlipped:
		isFlipped = true
		scale.x = -1
		$EnemyHP.set_rotation_degrees(180)
		
		
func reset_hitboxes():
	$Hitbox/CollisionShape2D.disabled = true
	

func _on_AttackDetect_body_entered(body):
	if body.get_name() == "Skeleton":
		inAttackRange = true
		state = State.ATTACK


func _on_AttackDetect_body_exited(body):
	if body.get_name() == "Skeleton":
		inAttackRange = false
		

func _on_Player_Death():
	shouldIdle = true


func _on_Anim_animation_started(anim_name):
	match(anim_name):
		"knockback":
			motion.x = knockbackSpeed


func _on_Anim_animation_finished(anim_name):
	match(anim_name):
		"attack":
			if get_tree().get_root().find_node("Skeleton", true, false):
				if inAttackRange:
					set_face_direction(skeleton)
				else:
					state = State.CHASE
			else:
				skeleton = null
		"knockback":
			if inAttackRange:
				state = State.ATTACK
			else:
				state = State.CHASE
				
	if shouldIdle:
		state = State.IDLE
