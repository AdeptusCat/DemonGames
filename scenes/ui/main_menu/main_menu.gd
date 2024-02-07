extends Control



func _ready():
	%TutorialMenuButton.get_popup().id_pressed.connect(_on_TutorialMenuButton_id_pressed)
	for chapter in Tutorial.Chapter.values():
		%TutorialMenuButton.get_popup().add_item(Tutorial.chapterNames[chapter], chapter)
	connectAudio()


func connectAudio() -> void:
	var res : Array = []
	res = Functions.findByClass(self, "Button", res)
	for child : Button in res:
		if child.disabled:
			if child.mouse_entered.is_connected(_on_mouseEntered):
				child.mouse_entered.disconnect(_on_mouseEntered)
		else:
			if not child.mouse_entered.is_connected(_on_mouseEntered):
				child.mouse_entered.connect(_on_mouseEntered)
	for child : Button in res:
		if child.disabled:
			if child.pressed.is_connected(_on_buttonClicked):
				child.pressed.disconnect(_on_buttonClicked)
		else:
			if not child.pressed.is_connected(_on_buttonClicked):
				child.pressed.connect(_on_buttonClicked)


func _on_mouseEntered():
	$AudioManager.playMouseEntered()


func _on_buttonClicked():
	$AudioManager.playButtonClicked()


func _on_TutorialMenuButton_id_pressed(id):
	Tutorial.chapter = id
	Tutorial.tutorial = true
	_on_host_game_button_pressed()


func _on_host_game_button_pressed():
	Main.StartServer()
	get_tree().change_scene_to_file("res://scenes/ui/lobby/lobby.tscn")


func _on_connect_button_pressed():
	Connection.local = false
	get_tree().change_scene_to_file("res://scenes/ui/lobby/lobby.tscn")


func _on_connect_to_local_button_pressed():
	Connection.local = true
	get_tree().change_scene_to_file("res://scenes/ui/lobby/lobby.tscn")


func _on_itch_button_pressed():
	OS.shell_open("https://adeptuscat.itch.io/demongames")


func _on_reddit_button_pressed():
	OS.shell_open("https://www.reddit.com/user/adeptuscat/")


func _on_reddit_button_2_pressed():
	OS.shell_open("https://discord.gg/AXhbqHNjhm")


