extends KinematicBody2D

signal enemy_death

const MAX_MOVE_SPEED = 125
const OFF_SCREEN_LIMIT = -20

var motion = Vector2()
var isDodgeable = true
var isFlipped = false
var maxHp = 1
var hp = maxHp
var knockbackSpeed = 0
var expScene = load("res://Experience.tscn")
var expOrbs = 2
var expAmount = 1

onready var skeleton = get_tree().get_root().find_node("Skeleton", true, false)

func _ready():
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


func _physics_process(delta):
	move_and_slide(motion)
	
	if global_position.y < OFF_SCREEN_LIMIT:
		queue_free()
	
	
func process_hit(attacker, damage, knockback):
	hp -= damage
	if hp <= 0:
		process_death()
		
		
func process_death():
	var expParent = get_tree().get_root().find_node("Experience", true, false)
	for i in range(expOrbs):
		var inst = expScene.instance()
		inst.global_position = global_position
		inst.amount = expAmount
		expParent.add_child(inst)
		
	emit_signal("enemy_death")
	queue_free()
	

func _on_Hitbox_body_entered(body):
	if body.get_name() == "Skeleton":
		motion.y = -MAX_MOVE_SPEED


func _on_VisibilityNotifier2D_screen_exited():
	print("i'm out")
	queue_free()
