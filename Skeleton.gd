extends KinematicBody2D

enum State { MOVE, ROLL, ATTACK_ONE, ATTACK_TWO, ATTACK_THREE }

const MAX_RUN_SPEED = 200
const ACCELERATION = 20
const LAST_ATTACK_STATE = State.ATTACK_THREE

export(bool) var allow_combo = false

var motion = Vector2()
var isFlipped = false
var maxHp = 25
var hp = maxHp

onready var state = State.MOVE
onready var hitboxes = get_tree().get_nodes_in_group("playerHitbox")


func _ready():
	reset_hitboxes()


func _physics_process(delta):
	match state:
		State.ROLL:
			process_roll()
		State.ATTACK_ONE:
			process_attack("attack_one")
		State.ATTACK_TWO:
			process_attack("attack_two")
		State.ATTACK_THREE:
			process_attack("attack_three")
		State.MOVE:
			process_move()
	
	move_and_slide(motion)


func process_attack(anim_name):
	$Anim.play(anim_name)	
	motion.x = lerp(motion.x, 0, 0.25)
	
	if Input.is_action_just_pressed("attack") && allow_combo && state != LAST_ATTACK_STATE:
		state += 1
		
		
func process_hit(attacker, damage):
	print("Skeleton took " + str(damage) + " from " + attacker.name)
	hp -= damage
	if hp <= 0:
		queue_free()
	
	
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

	
func should_stop():
	return (!Input.is_action_pressed("move_left") && !Input.is_action_pressed("move_right")) || (Input.is_action_pressed("move_left") && Input.is_action_pressed("move_right"))
	
	
func reset_hitboxes():
	for node in hitboxes:
		node.get_child(0).disabled = true


func _on_Anim_animation_started(anim_name):
	match anim_name:
		"attack_one":
			continue
		"attack_two":
			continue
		"attack_three":
			reset_hitboxes()


func _on_Anim_animation_finished(anim_name):
	match anim_name:
		"roll":
			motion.x = 100 * sign(motion.x)
			state = State.MOVE
		"attack_one":
			if state == State.ATTACK_ONE:
				state = State.MOVE
		"attack_two":
			if state == State.ATTACK_TWO:
				state = State.MOVE
		"attack_three":
			if state == State.ATTACK_THREE:
				state = State.MOVE
