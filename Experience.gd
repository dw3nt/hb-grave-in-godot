extends Node2D

const MAX_EXPLODE_SPEED = 1.75
const MAX_CHASE_SPEED = 4

var target = Vector2()
var isExploding = true

onready var origin = global_position
onready var skeleton = get_tree().get_root().find_node("Skeleton", true, false)	# better way to do this


func _ready():
	target = Vector2(rand_range(-360, 360), rand_range(-360, 360)) 	# this could be improved... like pick a point within 100 units of EXP
	

func _physics_process(delta):
	if global_position.distance_to(origin) > 100:
		isExploding = false
		
		
	if isExploding:
		global_position += (target - global_position).normalized() * MAX_EXPLODE_SPEED
		# slow down as it turns around to flow towards player
	else:
		target = skeleton.global_position
		var foo = 50
		target.y += rand_range(-foo, foo)
		target.x += rand_range(-foo, foo)
		global_position += (target - global_position).normalized() * MAX_CHASE_SPEED
		# some fancier following to be implemented here - should be circling around player
	