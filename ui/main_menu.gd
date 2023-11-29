extends Control



func _ready():
	%TutorialMenuButton.get_popup().id_pressed.connect(_on_TutorialMenuButton_id_pressed)
	for chapter in Tutorial.Chapter.values():
		%TutorialMenuButton.get_popup().add_item(Tutorial.chapterNames[chapter], chapter)
	
	#var demonName : String = "Andras"
	#var demonImages : Array = []
	#var dir = DirAccess.open("res://demon_assets/" + demonName.to_lower() )#+ demonName
	##var dir = DirAccess.open("res://")
	#print("res://demon_assets/" + demonName.to_lower() )
	#print(dir)
	#print(demonName)
	#if dir:
		#dir.list_dir_begin()
		#var file_name = dir.get_next()
		#while file_name != "":
			#if dir.current_is_dir():
				#print("Found directory: " + file_name)
			#else:
				##if not file_name.ends_with(".import"):
					##print("Found file: " + file_name)
					##demonImages.append(file_name)
				#demonImages.append(file_name)
				#print("Found file: " + file_name)
				##else:
					##print("Found file: " + file_name)
			#file_name = dir.get_next()
	#else:
		#print("An error occurred when trying to access the path.")
	#demonImages.shuffle()
	#print(demonImages)
	#print("demon_assets/" + demonName.to_lower() + "/" + demonImages.pop_back())
	##var image = load("demon_assets/" + demonName.to_lower() + "/" + demonImages.pop_back())
	#var img = Image.new()
	#img.load("res://00354-3473751642.png")
	#var texture = ImageTexture.new()
	#texture.create_from_image(img)
	connectAudio()


func connectAudio() -> void:
	var res : Array = []
	res = Functions.findByClass(self, "Button", res)
	for child : Button in res:
		child.mouse_entered.connect(_on_mouseEntered)
	for child : Button in res:
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
#	Connection.host = true
#	Connection.startLocalServer()
	Main.StartServer()
	get_tree().change_scene_to_file("res://ui/lobby.tscn")
	
	#var lobby = load("res://ui/lobby.tscn")
	#get_tree().change_scene_to_packed(lobby)
	
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


