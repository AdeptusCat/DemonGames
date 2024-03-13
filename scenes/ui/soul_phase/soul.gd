extends Control


var targetPosition : Vector2 = Vector2.ZERO


func _ready():
	%TextureRect.scale = Vector2(0.1, 0.1)
	%GPUParticles2D.emitting = true


func collect():
	var tween = create_tween()
	tween.tween_property(%TextureRect, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "global_position", targetPosition, 1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	tween.connect("finished", on_collect_finished)


func pay():
	Signals.soulLeftPlayerStats.emit()
	var tween = create_tween()
	tween.tween_property(%TextureRect, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "global_position", targetPosition, 1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	tween.connect("finished", on_pay_finished)


func on_collect_finished():
	Signals.soulReachedPlayerStats.emit()
	queue_free()


func on_pay_finished():
	queue_free()
