extends Area2D


export(int) var damage = 5


func _on_Hitbox_body_entered(body):
	body.process_hit(self.get_owner(), damage)
