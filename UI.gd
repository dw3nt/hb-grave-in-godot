extends CanvasLayer

onready var HPBar = $MarginContainer/VBoxContainer/Row1/HPBar

func _on_Skeleton_hp_changed(hp):
	$Tween.interpolate_property(HPBar, "value", HPBar.value, hp, 0.25, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0)
	$Tween.start()


func _on_Skeleton_kills_changed(val):
	$MarginContainer/VBoxContainer/Row2/MarginContainer/Kills.text = "Kills: " + str(val)
