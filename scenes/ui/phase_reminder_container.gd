extends MarginContainer


func _ready():
	Signals.phaseReminder.connect(start)


func start(text : String):
	if Settings.skipPhaseReminder:
		Signals.phaseReminderDone.emit()
		return
	%PhaseReminderLabel.text = text
	pivot_offset = size / 2
	show()
	await get_tree().create_timer(0.5).timeout
	var tw1 = create_tween()
	tw1.set_trans(Tween.TRANS_QUINT)
	tw1.set_ease(Tween.EASE_IN)
	tw1.tween_property(self, "scale", Vector2.ZERO, 1)
	tw1.tween_callback(stop)


func stop():
	Signals.phaseReminderDone.emit()
	hide()
	scale = Vector2.ONE
