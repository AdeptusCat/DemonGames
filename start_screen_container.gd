extends MarginContainer


func _ready():
	Signals.showStartScreen.connect(_on_showStartScreen)


func _on_showStartScreen():
	%StartScreenContainer.show()
	Signals.help.emit(Data.HelpSubjects.StartScreen)


func _on_start_screen_button_pressed():
	Signals.proceed.emit()
	hide()


func _on_start_screen_texture_rect_gui_input(event):
	if Input.is_action_just_pressed("click"):
		Signals.proceed.emit()
		hide()
