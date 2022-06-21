extends Area2D



func _on_Coin_body_entered(body: Node) -> void:
	$AnimationPlayer.play("bounce")
	body.add_coin()
	

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	queue_free()
