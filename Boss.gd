extends KinematicBody2D

signal boss_hp_changed
signal enemy_death
signal boss_death

enum State { IDLE, CHASE, ATTACK, KNOCKBACK, DEATH }

const MAX_MOVE_SPEED = 50
const ACCELERATION = 10

var motion = Vector2()
var isDodgeable = false
var isFlipped = false
var inAttackRange = false
var canAttack = true
var inBackupRange = false
var maxHp = 100
var hp = maxHp
var knockbackSpeed = 0
var expScene = load("res://Experience.tscn")
var expOrbs = 25
var expAmount = 1
var shouldIdle = false
var hitEffectScene = load("res://HitEffect.tscn")
var hitEffectAmount = 6
var shouldSpawnHit = false
var shouldDie = false

onready var state = State.CHASE
onready var skeleton = get_tree().get_root().find_node("Skeleton", true, false)
onready var hitEffectsParnet = get_tree().get_root().find_node("HitEffects", true, false)

func _ready():
	randomize()
	
	$EnemyHP.hpTotal = maxHp
	$EnemyHP.currentHp = maxHp
	$EnemyHP.init()
	
	reset_hitboxes()


func _process(delta):
	if shouldSpawnHit:
		var spacing = 360 / hitEffectAmount
		for i in range(hitEffectAmount):
			var inst = hitEffectScene.instance()
			inst.global_position = global_position
			inst.global_position.y += 20
			inst.set_rotation_degrees(i * spacing + rand_range(-30, 30))
			hitEffectsParnet.add_child(inst)
		shouldSpawnHit = false
		
	if shouldDie:
		process_death()
		shouldDie = false


func _physics_process(delta):
	# may be a better way to tell enemies player doesn't exist (or is dead) cuz this seems like bad practice / inefficent
	if skeleton == null:
		state = State.IDLE
	
	match state:
		State.IDLE:
			reset_hitboxes()
			process_idle()
		State.CHASE:
			if $Anim.current_animation != "attack":
				reset_hitboxes()
				if !inBackupRange:
					set_face_direction(skeleton)
				process_chase(skeleton)
		State.ATTACK:
			if canAttack:
				process_attack()
			else:
				state = State.CHASE
		
	move_and_slide(motion)
	

func process_idle():
	if $Anim.current_animation != "idle":
		$Anim.play("idle")
		
	motion.x = lerp(motion.x, 0, 0.25)
	
	
func process_chase(chase):
	if !isFlipped:
		if inBackupRange:
			motion.x = max(motion.x - ACCELERATION, -MAX_MOVE_SPEED)
		else:
			motion.x = min(motion.x + ACCELERATION, MAX_MOVE_SPEED)
	else:
		if inBackupRange:
			motion.x = min(motion.x + ACCELERATION, MAX_MOVE_SPEED)
		else:
			motion.x = max(motion.x - ACCELERATION, -MAX_MOVE_SPEED)
	
	if $Anim.current_animation != "walk" && $Anim.current_animation != "attack":
		$Anim.play("walk")
	
	
func process_attack():
	if $Anim.current_animation != "knockback":
		$Anim.play("attack")
		
	motion.x = lerp(motion.x, 0, 0.25)
	
	
func trigger_attack_screenshake():
	skeleton.setup_camera_shake(10, 0.15)
	
	
func process_hit(attacker, damage, knockback):
	if state != State.ATTACK:
		set_face_direction(attacker)
	
	shouldSpawnHit = true
	skeleton.setup_camera_shake(2, 0.25)
		
	hp -= damage
	attacker.play_hit_audio()
	if hp <= 0:
		state = State.DEATH
		$BackupDetect.monitoring = false
		$AttackDetect.monitoring = false
		shouldDie = true
	else:
		$EnemyHP.update_hp(hp)
		emit_signal("boss_hp_changed", hp)
		
		
func process_death():
	state = State.DEATH
	motion = Vector2(0, 0)
	$Anim.play("death")
	$EnemyHP.visible = false
	
	
func spawn_experience():
	var expParent = get_tree().get_root().find_node("Experience", true, false)
	for i in range(expOrbs):
		var inst = expScene.instance()
		inst.global_position = global_position
		inst.amount = expAmount
		expParent.add_child(inst)
			

func set_face_direction(faceTowards):
	if faceTowards.position.x > position.x && isFlipped:
		isFlipped = false
		scale.x = -1
		$EnemyHP.set_rotation_degrees(0)
	elif faceTowards.position.x < position.x && !isFlipped:
		isFlipped = true
		scale.x = -1
		$EnemyHP.set_rotation_degrees(180)
		
		
func play_hit_audio():
	pass
	
	
func play_sound(nodePath):
	get_node(nodePath).play()
		
		
func reset_hitboxes():
	$Hitbox/CollisionPolygon2D.disabled = true
	

func _on_AttackDetect_body_entered(body):
	if body.get_name() == "Skeleton":
		inAttackRange = true
		state = State.ATTACK


func _on_AttackDetect_body_exited(body):
	if body.get_name() == "Skeleton":
		inAttackRange = false
		
		
func _on_BackupDetect_body_entered(body):
	if body.get_name() == "Skeleton":
		inBackupRange = true


func _on_BackupDetect_body_exited(body):
	if body.get_name() == "Skeleton":
		inBackupRange = false


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
				
			canAttack = false;
			$AttackTimer.start();
		"knockback":
			if shouldDie:
				state = State.DEATH
			else:
				if inAttackRange:
					state = State.ATTACK
				else:
					state = State.CHASE
		"death":
			$Anim.play("death-fade")
			spawn_experience()
		"death-fade":
			emit_signal("enemy_death")
			emit_signal("boss_death")
			queue_free()
				
	if shouldIdle:
		state = State.IDLE


func _on_AttackTimer_timeout():
	canAttack = true;
	if inAttackRange:
		state = State.ATTACK
	else:
		state = State.CHASE
