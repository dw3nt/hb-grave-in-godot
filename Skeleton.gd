extends KinematicBody2D

signal hp_changed(hp, maxHp)
signal kills_changed(val)
signal level_changed(val)

enum State { MOVE, ROLL, KNOCKBACK, ATTACK_ONE, ATTACK_TWO, ATTACK_THREE, DEATH }

const MAX_RUN_SPEED = 200
const ACCELERATION = 20
const LAST_ATTACK_STATE = State.ATTACK_THREE

export(bool) var allow_combo = false

var motion = Vector2()
var isFlipped = false
var maxHp = 1
var hp = maxHp
var knockbackSpeed = 0
var level = 1
var kills = 0
var maxExperience = 2
var experience = 0
var bonePieces = 10
var boneScene = preload("res://Bone.tscn")

onready var state = State.MOVE
onready var hitboxes = get_tree().get_nodes_in_group("playerHitbox")


func _ready():
	reset_hitboxes()


func _physics_process(delta):
	match state:
		State.ROLL:
			reset_hitboxes()
			process_roll()
		State.ATTACK_ONE:
			process_attack("attack_one")
		State.ATTACK_TWO:
			process_attack("attack_two")
		State.ATTACK_THREE:
			process_attack("attack_three")
		State.KNOCKBACK:
			reset_hitboxes()
			process_knockback()
		State.MOVE:
			reset_hitboxes()
			process_move()
	
	move_and_slide(motion)
	set_camera_facing()


func process_attack(anim_name):
	$Anim.play(anim_name)	
	motion.x = lerp(motion.x, 0, 0.25)
	
	if Input.is_action_just_pressed("attack") && allow_combo && state != LAST_ATTACK_STATE:
		state += 1
		
		
func process_hit(attacker, damage, knockback):
	if !(attacker.isDodgeable && state == State.ROLL):
		state = State.KNOCKBACK
		if attacker.position.x > self.position.x:
			knockbackSpeed = -knockback
			if isFlipped:
				isFlipped = false
				scale.x = -1
		else:
			knockbackSpeed = knockback
			if !isFlipped:
				isFlipped = true
				scale.x = -1
				
		hp -= damage
		emit_signal("hp_changed", hp, maxHp)
		if hp <= 0:
			process_death()
			
			
func process_death():
	motion = Vector2(0, 0)
	state = State.DEATH
	$Sprite.visible = false
	$ExpCollect/CollisionShape2D.disabled = true
	$Hurtbox.disabled = true
	reset_hitboxes()
	
	var boneParent = get_tree().get_root().find_node("Bones", true, false)
	var bone
	for i in range(bonePieces):	# for each frame of bone frame
		bone = boneScene.instance()
		bone.global_position = global_position
		bone.boneFrame = i
		bone.isFlipped = isFlipped
		boneParent.add_child(bone)
		
	
func process_knockback():
	if $Anim.current_animation != "knockback":
		$Anim.play("knockback")
	motion.x = lerp(motion.x, 0, 0.025)
	
	
func process_roll():
	$Anim.play("roll")
	if isFlipped:
		motion.x = -200
	else:
		motion.x = 200
	
	
func process_move():
	if Input.is_action_just_pressed("roll"):
		state = State.ROLL
	elif Input.is_action_just_pressed("attack"):
		state = State.ATTACK_ONE
	
	if should_stop():
		motion.x = lerp(motion.x, 0, 0.25)
		$Anim.play("idle")
	elif Input.is_action_pressed("move_left"):
		motion.x = max(motion.x - ACCELERATION, -MAX_RUN_SPEED)
		$Anim.play("run")
		if !isFlipped:
			isFlipped = true
			scale.x = -1
	elif Input.is_action_pressed("move_right"):
		motion.x = min(motion.x + ACCELERATION, MAX_RUN_SPEED)
		$Anim.play("run")
		if isFlipped:
			isFlipped = false
			scale.x = -1
	else:
		$Anim.play("idle")
		
		
func level_up():
	level += 1
	emit_signal("level_changed", level)
	
	experience = experience - maxExperience
	maxExperience += maxExperience
	
	maxHp += 5
	hp = maxHp
	emit_signal("hp_changed", hp, maxHp)
	
	if level % 5 == 0:
		for node in hitboxes:
			node.damage += 5

	
func should_stop():
	return (!Input.is_action_pressed("move_left") && !Input.is_action_pressed("move_right")) || (Input.is_action_pressed("move_left") && Input.is_action_pressed("move_right"))
	
	
func reset_hitboxes():
	for node in hitboxes:
		node.get_child(0).disabled = true
		
		
func set_camera_facing():
	if isFlipped:
		$Camera.offset_h = -1
	else:
		$Camera.offset_h = 1
		
		
func _on_Enemy_Death():
	kills += 1
	emit_signal("kills_changed", kills)
		
		
func _on_Anim_animation_started(anim_name):
	match(anim_name):
		"knockback":
			motion.x = knockbackSpeed


func _on_Anim_animation_finished(anim_name):
	match anim_name:
		"roll":
			motion.x = 100 * sign(motion.x)
			state = State.MOVE
		"attack_one":
			reset_hitboxes()
			if state == State.ATTACK_ONE:
				state = State.MOVE
		"attack_two":
			reset_hitboxes()
			if state == State.ATTACK_TWO:
				state = State.MOVE
		"attack_three":
			reset_hitboxes()
			if state == State.ATTACK_THREE:
				state = State.MOVE
		"knockback":
			state = State.MOVE


func _on_ExpCollect_area_entered(area):
	if area.is_in_group("exp_orb"):
		experience += area.amount
		area.queue_free()
		if experience >= maxExperience:
			level_up()