extends KinematicBody2D

const GRAVITY = 10
const GROUND_LIMIT = 154
const SWORD_ANGLE = 220
const SWORD_FRAME = 5

#var boneFrame = rand_range(0, 9)
var boneFrame = 5
var motion

func _ready():
	$Sprite.frame = boneFrame
	if boneFrame == SWORD_FRAME:	# special angle for sword
		rotation_degrees = SWORD_ANGLE
	else:
		rotation_degrees = rand_range(0, 360)
		
	motion = Vector2(rand_range(-50, -250), rand_range(-100, -200))
	
	
func _physics_process(delta):
	if global_position.y < GROUND_LIMIT:
		motion.y += GRAVITY
		move_and_slide(motion)