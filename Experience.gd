extends Area2D

enum State { EXPLODE, CHASE }

const MIN_EXPLODE_SPEED = 4
const MAX_EXPLODE_SPEED = 6
const MIN_CHASE_SPEED = 7
const MAX_CHASE_SPEED = 9
const WIGGLE = 10

var motion = Vector2()
var target = Vector2()
var amount = 0

onready var explodeSpeed = rand_range(MIN_EXPLODE_SPEED, MAX_EXPLODE_SPEED)
onready var chaseSpeed = rand_range(MIN_CHASE_SPEED, MAX_CHASE_SPEED)
onready var origin = global_position
onready var skeleton = get_tree().get_root().find_node("Skeleton", true, false)	# better way to do this
onready var state = State.EXPLODE


func _ready():
	# this took a whlie to figure out, but here's the deal
	#		- randomly generate a vector to use as direction - Y coordinate is altered to favor exploding up instead of down
	#		- normalize it, cuz just want it for direction, then set magnitude to distance to 150
	#		- then add it to origin (which is the orb's global position) so target is 150 pixels away from origin in a random direction
	target = origin + ( Vector2(rand_range(-1, 1), rand_range(-1, 0.05)).normalized() * 150 )
	

func _physics_process(delta):
	match state:
		State.EXPLODE:
			var distance = global_position.distance_to(origin)
			motion = (target - global_position).normalized() * explodeSpeed

			if distance > 100:
				$CollisionShape2D.disabled = false
				state = State.CHASE
		
		State.CHASE:
			target = skeleton.global_position
			target.x += rand_range(-WIGGLE, WIGGLE)
			target.y += rand_range(-WIGGLE, WIGGLE)

			var desiredSpeed = (target - global_position).normalized() * chaseSpeed
			var steering = (desiredSpeed - motion) / 35
			motion += steering

	global_position += motion
