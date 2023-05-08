extends Control


func _ready():
	%TutorialMenuButton.get_popup().id_pressed.connect(_on_TutorialMenuButton_id_pressed)
	for chapter in Tutorial.Chapter.values():
		%TutorialMenuButton.get_popup().add_item(Tutorial.chapterNames[chapter], chapter)


func _on_TutorialMenuButton_id_pressed(id):
	Tutorial.chapter = id
	Tutorial.tutorial = true
	_on_host_game_button_pressed()


func _on_host_game_button_pressed():
#	Connection.host = true
#	Connection.startLocalServer()
	Main.StartServer()
	get_tree().change_scene_to_file("res://ui/lobby.tscn")
	
#	get_tree().change_scene_to_file("res://ui/lobby.tscn")

#	var serverTree = SceneTree.new()
#	serverTree._initialize()

#	serverTree.set_multiplayer(serverTree.get_multiplayer(), self.get_path())
#	serverTree.change_scene_to_file("res://server/server.tscn")
#	var main_scene = load("res://server/server.tscn")
#	var main = main_scene.instantiate()
#	add_child(main)
#	main.StartServer()
	
#	await get_tree().create_timer(1.1).timeout
#	get_tree().change_scene_to_file("res://ui/lobby.tscn")
	
#	var lobby_scene = load("res://ui/lobby.tscn")
#	var lobby = lobby_scene.instantiate()
#	add_child(lobby)

func _on_connect_button_pressed():
	Connection.local = false
	get_tree().change_scene_to_file("res://ui/lobby.tscn")


func _on_connect_to_local_button_pressed():
	Connection.local = true
	get_tree().change_scene_to_file("res://ui/lobby.tscn")


func _on_itch_button_pressed():
	OS.shell_open("https://adeptuscat.itch.io/demongames")


func _on_reddit_button_pressed():
	OS.shell_open("https://www.reddit.com/user/adeptuscat/")


func _on_reddit_button_2_pressed():
	OS.shell_open("https://discord.gg/AXhbqHNjhm")


func _on_tutorial_button_pressed():
	Tutorial.tutorial = true
	_on_host_game_button_pressed()
