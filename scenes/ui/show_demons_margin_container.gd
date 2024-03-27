extends MarginContainer


func _on_texture_button_pressed():
	Signals.expandDemonCards.emit()


