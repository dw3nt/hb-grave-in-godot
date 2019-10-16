extends Area2D

enum State { EXPLODE, CHASE }

const MAX_EXPLODE_SPEED = 3
const MAX_CHASE_SPEED = 3.5

var motion = Vector2()
var target = Vector2()
var amount = 0

onready var origin = global_position
onready var skeleton = get_tree().get_root().find_node("Skeleton", true, false)	# better way to do this
onready var state = State.EXPLODE


func _ready():
	target = Vector2(rand_range(-360, 360), rand_range(-360, 360))	# improve - spread out randomness to not overlap - also sometimes they get stuck...?
	

func _physics_process(delta):
	# get it to ease into the chase state
	match state:
		State.EXPLODE:
			if global_position.distance_to(origin) > 100:
				state = State.CHASE
				$CollisionShape2D.disabled = false
				
			motion = (target - global_position).normalized() * MAX_EXPLODE_SPEED
		
		State.CHASE:
			target = skeleton.global_position
			var desiredSpeed = (target - global_position).normalized() * MAX_CHASE_SPEED
			var steering = desiredSpeed - motion / 1.5
			motion += steering
				
	global_position += motion
