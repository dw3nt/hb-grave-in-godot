extends Area2D


func _on_Hitbox_body_entered(body):
	self.get_owner().attack_hit(body)
