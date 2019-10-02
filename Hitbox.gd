extends Area2D


func _on_Hitbox_body_entered(body):
	body.process_hit(self.get_owner())
