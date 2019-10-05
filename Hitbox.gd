extends Area2D


export(int) var damage = 5
export(int) var knockback = 100


func _on_Hitbox_body_entered(body):
	body.process_hit(self.get_owner(), damage, knockback)
