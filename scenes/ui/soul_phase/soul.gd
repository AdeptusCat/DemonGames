extends Control


var targetPosition : Vector2 = Vector2.ZERO


func collect():
	var tween = create_tween()
	tween.tween_property(self, "global_position", targetPosition, 1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	tween.connect("finished", on_collect_finished)


func pay():
	Signals.soulLeftPlayerStats.emit()
	var tween = create_tween()
	tween.tween_property(self, "global_position", targetPosition, 1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	tween.connect("finished", on_pay_finished)


func on_collect_finished():
	Signals.soulReachedPlayerStats.emit()
	queue_free()


func on_pay_finished():
	queue_free()
