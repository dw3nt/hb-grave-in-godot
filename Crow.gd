extends KinematicBody2D

enum State { CHASE, EXIT }

const MAX_MOVE_SPEED = 100

var motion = Vector2()
var isDodgeable = true
var isFlipped = false
var maxHp = 1
var hp = maxHp
var knockbackSpeed = 0
var expScene = load("res://Experience.tscn")
var expOrbs = 3
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
	
	
func process_hit(attacker, damage, knockback):
	pass
	

func _on_Hitbox_body_entered(body):
	if body.get_name() == "Skeleton":
		motion.y = -MAX_MOVE_SPEED
