extends Node


var savegame : Dictionary = {}
var unixTimeInt : int

func newSavegame():
	var unixTime = Time.get_unix_time_from_system()
	unixTimeInt = int(unixTime)


func _ready():
	loadProfile()
	Signals.resetGame.connect(_on_resetGame)


func _on_resetGame():
	savegame.clear()


func saveGame():
#	var unixTime = Time.get_unix_time_from_system()
#	unixTimeInt = int(unixTime) # new savegame every save
	var saveDir = DirAccess.open("user://savegames/")
	if not saveDir:
		var userDir = DirAccess.open("user://")
		userDir.make_dir("savegames")
	var file = FileAccess.open("user://savegames/save_game_" + str(unixTimeInt) + ".dat", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	savegame = {"game" : {}, "worldStates" : {}, "players" : {}, "demons" : {}, "legions" : {}, "lieutenants" : {}}
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
#		if node.filename.is_empty():
#			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
#			continue

		# Check the node has a save function.
		if !node.has_method("saveGame"):
			print("persistent node '%s' is missing a saveGame() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("saveGame")
		for type in node_data:
			for key in node_data[type]:
				savegame[type][key] = node_data[type][key]
				# JSON provides a static method to serialized JSON string
	for demonNode in Data.demons.values():
		savegame["demons"][demonNode.demonName] = {"onEarth" = demonNode.onEarth, "incapacitated" = demonNode.incapacitated}
	var json_string = JSON.stringify(savegame)
	file.store_line(json_string)
	file.flush()

# ACHTUNG loading int type variables turn out to be floats
# but if the variable is declared as an int then it gets loaded as int
func loadGame(fileName : String = ""):
	if fileName.is_empty():
		var filesNames = readFilenames("savegames")
		var timestamps : Array = []
		for filesName in filesNames:
			var modTime = FileAccess.get_modified_time("user://savegames/" + filesName)
			timestamps.append(modTime)
		var latestTimestamp = timestamps.max()
		var index = timestamps.find(latestTimestamp)
		
		if index == -1:
			print("no savegames in folder")
			return
		var file = FileAccess.open("user://savegames/" + filesNames[index], FileAccess.READ)
		var json_string = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			savegame = json.data
			print(savegame)
			return savegame
	#		if typeof(data_received) == TYPE_ARRAY:
	#			print(data_received) # Prints array
	#		else:
	#			print("Unexpected data")
		else:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			return null
	else:
		var file = FileAccess.open("user://savegames/" + fileName, FileAccess.READ)
		var json_string = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			savegame = json.data
			print(savegame)
			return savegame
	#		if typeof(data_received) == TYPE_ARRAY:
	#			print(data_received) # Prints array
	#		else:
	#			print("Unexpected data")
		else:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			return null

func readFilenames(dirName : String = ""):
	var fileNames = []
	var dir = DirAccess.open("user://" + dirName)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
#				print("Found directory: " + file_name)
				pass
			else:
#				print("Found file: " + file_name)
				file_name = file_name.trim_suffix('.remap')
				fileNames.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return fileNames


func saveProfile(profile : Dictionary):
	var profileDir = DirAccess.open("user://profile/")
	if not profileDir:
		var userDir = DirAccess.open("user://")
		userDir.make_dir("profile")
	
	var file = FileAccess.open("user://profile/profile.dat", FileAccess.WRITE)
	var json_string = JSON.stringify(profile)
	file.store_line(json_string)
	file.flush()


func loadProfile():
	var profileDir = DirAccess.open("user://profile/")
	if not profileDir:
		var userDir = DirAccess.open("user://")
		userDir.make_dir("profile")
	
	var file = FileAccess.open("user://profile/profile.dat", FileAccess.READ_WRITE)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			var profile : Dictionary = json.data
			Data.profile = profile
		else:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			resetProfile()
			json_string = JSON.stringify(Data.profile)
			file.store_line(json_string)
			file.flush()
	else:
		resetProfile()
		saveProfile(Data.profile)
	print("profile ", Data.profile)


func resetProfile():
	Data.profileNames.shuffle()
	var profile : Dictionary = {"playername" : Data.profileNames.pop_back()}
	Data.profile = profile
	Connection.playerName = Data.profile.playername
