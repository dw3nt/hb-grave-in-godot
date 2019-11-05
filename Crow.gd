extends KinematicBody2D

signal enemy_death

const MAX_MOVE_SPEED = 125
const OFF_SCREEN_LIMIT_UP = -20
const OFF_SCREEN_LIMIT_LEFT = -300
const OFF_SCREEN_LIMIT_RIGHT = 2000

var motion = Vector2()
var isDodgeable = true
var isFlipped = false
var maxHp = 1
var hp = maxHp
var knockbackSpeed = 0
var expScene = load("res://Experience.tscn")
var expOrbs = 2
var expAmount = 1
var shouldSpawnHit = false
var hitEffectScene = load("res://HitEffect.tscn")
var hitEffectAmount = 4
var featherScene = load("res://Feather.tscn")
var featherAmount = 4
var shouldDie = false

onready var skeleton = get_tree().get_root().find_node("Skeleton", true, false)
onready var hitEffectsParnet = get_tree().get_root().find_node("HitEffects", true, false)

func _ready():
	randomize()
	
	var dir = null
	if skeleton == null:
		dir = rand_range(-1, 1)
	else:
		dir = skeleton.position.x - position.x
		
	if dir < 0:
		isFlipped = true
		scale.x = -1		
		motion.x = -MAX_MOVE_SPEED
	else:
		motion.x = MAX_MOVE_SPEED
		
		
func _process(delta):
	if shouldSpawnHit:
		var spacing = 360 / hitEffectAmount
		for i in range(hitEffectAmount):
			var inst = hitEffectScene.instance()
			inst.global_position = global_position
			inst.set_rotation_degrees(i * spacing + rand_range(-30, 30))
			hitEffectsParnet.add_child(inst)
		shouldSpawnHit = false
		
	if shouldDie:
		process_death()
		shouldDie = false


func _physics_process(delta):
	move_and_slide(motion)
	
	if global_position.y < OFF_SCREEN_LIMIT_UP || global_position.x < OFF_SCREEN_LIMIT_LEFT || global_position.x > OFF_SCREEN_LIMIT_RIGHT:
		queue_free()
	
	
func process_hit(attacker, damage, knockback):
	shouldSpawnHit = true
	skeleton.setup_camera_shake(2, 0.25)
	
	hp -= damage
	if hp <= 0:
		shouldDie = true
		
		
func process_death():
	spawn_experience()
	spawn_feathers()
		
	emit_signal("enemy_death")
	queue_free()
	
	
func spawn_feathers():
	var spacing = 360 / featherAmount
	for i in range(featherAmount):
		var inst = featherScene.instance()
		inst.global_position = global_position
		inst.set_rotation_degrees(i * spacing + rand_range(-30, 30))
		hitEffectsParnet.add_child(inst)
	
	
func spawn_experience():
	var expParent = get_tree().get_root().find_node("Experience", true, false)
	for i in range(expOrbs):
		var inst = expScene.instance()
		inst.global_position = global_position
		inst.amount = expAmount
		expParent.add_child(inst)
	

func _on_Hitbox_body_entered(body):
	if body.get_name() == "Skeleton":
		if body.state != body.State.ROLL:
			motion.y = -MAX_MOVE_SPEED


func _on_Player_Death():
	pass