extends MarginContainer


func _on_button_pressed():
	hide()


func _on_button_2_pressed():
	Signals.showSequenceOfPlayHelp.emit()
	hide()
