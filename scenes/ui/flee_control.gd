extends MarginContainer


func _ready():
	Signals.showFleeControl.connect(_on_showFleeControl)
	Signals.hideFleeControl.connect(_on_hideFleeControl)


func _on_showFleeControl():
	show()


func _on_hideFleeControl():
	hide()


func _on_confirm_flee_button_pressed():
	Signals.confirmFlee.emit(true)


func _on_cancel_flee_button_pressed():
	Signals.confirmFlee.emit(false)
