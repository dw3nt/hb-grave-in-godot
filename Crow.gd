extends KinematicBody2D

enum State { CHASE }

const MAX_MOVE_SPEED = 50
const ACCELERATION = 10

var motion = Vector2()
var isFlipped = false
var attacked = false
var maxHp = 1
var hp = maxHp
var knockbackSpeed = 0
var expScene = load("res://Experience.tscn")
var expOrbs = 5
var expAmount = 1

onready var state = State.CHASE
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


func _physics_process(delta):
	# may be a better way to tell enemies player doesn't exist (or is dead) cuz this seems like bad practice / inefficent
	if skeleton == null:
		state = State.IDLE
	
	match state:
		State.CHASE:
			process_chase()
			
			
func process_chase():
	pass
			