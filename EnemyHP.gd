extends Node2D

export(int) var hpHeight = 14
export(int) var hpWidth	= 24

var hpTotal
var currentHp


func init():
	$HP.rect_size = Vector2(hpWidth, hpHeight)
	$HP.max_value = hpTotal
	$HP.value = hpTotal
	modulate = Color(1, 1, 1, 0)
	
	
func update_hp(hp):
	modulate = Color(1, 1, 1, 1)
	$Tween.interpolate_property($HP, "value", $HP.value, hp, 0.25, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0)
	$Tween.start()
	$Timer.start()


func _on_Timer_timeout():
	# fadeaway
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0)
	$Tween.start()
