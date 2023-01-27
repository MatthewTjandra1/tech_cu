extends ColorRect

signal transition_done

func transition():
	$AnimationPlayer.play("Transition")

func _on_AnimationPlayer_animation_finished(Transition):
	emit_signal("transition_done")
