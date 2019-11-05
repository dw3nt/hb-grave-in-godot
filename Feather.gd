extends Node2D

const GRAVITY = 0.25

var motion

func _ready():
	randomize()
	motion = Vector2(rand_range(-3, 3), rand_range(-4, -2))
	

func _physics_process(delta):
	motion.y += GRAVITY
	global_position += motion


func _on_Timer_timeout():
	queue_free()
