extends MarginContainer


func _ready():
	Signals.toogleTameHellhoundContainer.connect(_on_toogleTameHellhoundContainer)


func _on_toogleTameHellhoundContainer(boolean : bool):
	return
	if boolean:
		%TamingHellhoundContainer.show()
		%TamingHellhoundButton.disabled = false
	else:
		%TamingHellhoundContainer.hide()


func _on_taming_hellhound_button_pressed():
	Signals.tamingHellhound.emit()
