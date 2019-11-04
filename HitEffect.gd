extends Node2D

var speed = 3
	

func _physics_process(delta):
	global_position += Vector2(speed, 0).rotated(get_rotation())


func _on_Timer_timeout():
	queue_free()
