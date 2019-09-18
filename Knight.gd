extends KinematicBody2D

enum State { IDLE, CHASE }

const MAX_MOVE_SPEED = 125
const ACCELERATION = 20

var motion = Vector2()

onready var state = State.IDLE

func _physics_process(delta):
	match state:
		State.IDLE:
			print("idle")
		State.CHASE:
			print("chase")
			
	move_and_slide(motion)