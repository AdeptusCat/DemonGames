extends MarginContainer

signal clicked(node)
var unitNr : int = 0

func _on_gui_input(event):
	if Input.is_action_just_pressed("click"):
		clicked.emit(self)

