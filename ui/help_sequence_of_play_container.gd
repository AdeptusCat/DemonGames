extends MarginContainer


func _ready():
	Signals.showSequenceOfPlayHelp.connect(_on_showSequenceOfPlayHelp)
	#reset_size()


func _on_showSequenceOfPlayHelp():
	show()


func _on_button_pressed():
	hide()
