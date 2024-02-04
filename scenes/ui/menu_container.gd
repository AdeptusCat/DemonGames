extends Control


const settingsContainer = preload("res://scenes/ui/settings_container.tscn")


func _ready():
	Settings.menuOpen = true
	Signals.menu.connect(_on_menu)


func _on_menu():
	Settings.menuOpen = false
	queue_free()
	

func _on_quit_button_pressed():
	get_tree().quit()


func _on_return_to_game_button_pressed():
	Settings.menuOpen = false
	queue_free()


func _on_settings_button_pressed():
	var settingsNode = settingsContainer.instantiate()
	get_parent().add_child(settingsNode)


func _on_return_to_main_menu_button_pressed():
	Settings.menuOpen = false
	Signals.returnToLobby.emit()
	queue_free()


