extends Control

var bgColor = Color("260000")

var playersInLobbyTreeRoot : TreeItem
var playersInLobbyTreeItems : Dictionary = {}

var roomsTreeRoot : TreeItem
var roomsTreeItems : Dictionary = {}

var playersInRoomTreeRoot : TreeItem
var playersInRoomTreeItems : Dictionary = {}

var savegameTreeRoot : TreeItem
var savegameTreeItems : Dictionary = {}

var colorMenuButtonIndices : Dictionary = {}
var playerMenuButtonIndices : Dictionary = {}
var aiMenuButtonIndices : Dictionary = {}

var AiPlayerNames : Array = ["Ai 1", "Ai 2", "Ai 3", "Ai 4", "Ai 5"]

var selectedPlayerId : int = 0

var aiID : int = -1

var loadedPlayerIdNamesDict : Dictionary = {}
var savegameData : Dictionary = {"filename" : "", "date" : "", "players" : [], "turn" : "", "phase" : ""}

var playerIcon = preload("res://assets/icons/pentagram.png")

var game_res_path : String = "res://game.tscn"
@onready var thread = Thread.new() 

func _ready():
#	if Connection.host:
##		if not Connection.dedicatedServer:
##			Connection.peers.append(1)
##		print("started hosting")
##		Connection.network.create_server(Connection.port)
##		multiplayer.multiplayer_peer = Connection.network
##		Connection.network.peer_connected.connect(func(id): peer_connected(id))
##		Data.id = multiplayer.get_unique_id()
##		Connection.playerIdNamesDict[Data.id] = "Player " + str(Connection.peers.size())
#
#
#		%MovePlayerContainer.hide()
#		%SavegamePlayersContainer.hide()
#
##		join()
#	else:
##		join()
#		%SavegamePlayersContainer.hide()
#		%MovePlayerContainer.hide()
#		%StartGameButton.hide()
#		%LoadGameButton.hide()
	%RoomContainer.hide()
	
	%ColorMenuButton.get_popup().index_pressed.connect(_on_ColorMenuButton_index_pressed)
	for colorName in Data.colorsNames:
		colorMenuButtonIndices[colorName] = %ColorMenuButton.get_popup().item_count
#		%ColorMenuButton.get_popup().add_item(colorName)
		var texture : Texture2D = Data.icons_small[colorName]
		%ColorMenuButton.get_popup().add_icon_item(texture, colorName)
		
	
	playersInLobbyTreeRoot = %PlayersInLobbyTree.create_item()
	%PlayersInLobbyTree.set_column_title(0, "Player Name")
	
	roomsTreeRoot = %RoomsTree.create_item()
	%RoomsTree.set_column_title(0, "Room Name")
	
	playersInRoomTreeRoot = %PlayerTree.create_item()
	%PlayerTree.set_column_title(0, "Player Name")
	%PlayerTree.set_column_title(1, "Player Color")
#	%PlayerTree.set_column_title(3, "Kick Player")
	
	Server.playerJoined.connect(_on_playerJoined)
	Server.playerLeft.connect(_on_playerLeft)
	Server.updatePlayers.connect(_on_update_players)
	Server.returnToLobby.connect(_on_returnToLobby)
	Server.roomCreated.connect(_on_roomCreated)
	Server.updateRooms.connect(_on_updateRooms)
	Server.roomClosed.connect(_on_roomClosed)
	Server.startGame.connect(_on_startGame)
	Server.playerjoinedRoom.connect(_on_playerjoinedRoom)
	Server.playerLeftRoom.connect(_on_playerLeftRoom)
	Server.changePlayerName.connect(_on_changePlayerName)
	#if not 	Connection.host:
	Connection.connectToServer()
	
	ResourceLoader.load_threaded_request(game_res_path)
	
	%PlayerNameTextEdit.text = Data.profile.playername
	
	savegameTreeRoot = %SavegameTree.create_item()
	%SavegameTree.set_column_title(0, "Filename")
	%SavegameTree.set_column_title(1, "Date")
	%SavegameTree.set_column_title(2, "Players")
	%SavegameTree.set_column_title(3, "Turn")
	%SavegameTree.set_column_title(4, "Phase")
	
	
	
#func _on_connected():
#	Connection.fetch_players(get_instance_id())
#	Connection.fetch_rooms(get_instance_id())


func _on_changePlayerName(playerId : int, playerName : String):
	if playerId == Data.id:
		%PlayerNameTextEdit.text = playerName
		Connection.playerName = playerName
	var item : TreeItem = playersInLobbyTreeItems[playerId]
	item.set_text(0, playerName)


func _on_playerJoined(playerName : String, playerId : int):
#	%PlayersInLobbyList.add_item(playerName)
	var item : TreeItem = %PlayersInLobbyTree.create_item(playersInLobbyTreeRoot)
	item.set_text(0, playerName)
	item.set_selectable(0, false)
	item.set_metadata(0, playerId)
	playersInLobbyTreeItems[playerId] = item


func _on_playerLeft(playerId : int):
	var item : TreeItem = playersInLobbyTreeItems[playerId]
	playersInLobbyTreeRoot.remove_child(item)
	playersInLobbyTreeItems.erase(playerId)

	
#	for index in %PlayersInLobbyList.item_count:
#		var playerNameEntry = %PlayersInLobbyList.get_item_text(index)
#		if playerNameEntry == playerName:
#			%PlayersInLobbyList.remove_item(index)
#			break


# update lobby player entries
func _on_update_players(playersDict : Dictionary):
	for playerId in playersDict:
		if not playersInLobbyTreeItems.has(playerId):
			var item : TreeItem = %PlayersInLobbyTree.create_item(playersInLobbyTreeRoot)
			item.set_text(0, playersDict[playerId])
			item.set_selectable(0, false)
			item.set_metadata(0, playerId)
			playersInLobbyTreeItems[playerId] = item
		if playerId == Data.id:
			var item : TreeItem = playersInLobbyTreeItems[playerId]
#			item.set_custom_bg_color(0, bgColor, false)
			item.set_icon(0, playerIcon)
			%PlayerNameTextEdit.text = item.get_text(0)
			Connection.playerName = item.get_text(0)
			Server.request_name_change.rpc_id(1, Data.id, Data.profile.playername)
			if Tutorial.tutorial == true:
				_on_host_button_pressed()
	for playerId in playersInLobbyTreeItems:
		if not playersDict.has(playerId):
			var item : TreeItem = playersInLobbyTreeItems[playerId]
			playersInLobbyTreeRoot.remove_child(item)
			playersInLobbyTreeItems.erase(playerId)
	
	
#	print(Data.id, " ", playersDict)
#	var playersInLobby : Array = []
#	var playersToRemove : Array = []
#	for index in %PlayersInLobbyList.item_count:
#		var playerName = %PlayersInLobbyList.get_item_text(index)
#		if not playersDict.values().has(playerName):
#			playersToRemove.append(index)
#		else:
#			playersInLobby.append(playerName)
#	for index in playersToRemove:
#		%PlayersInLobbyList.remove_item(index)
#	for playerName in playersDict.values():
#		if not playersInLobby.has(playerName):
#			var index = %PlayersInLobbyList.add_item(playerName)
#			if playerName == playersDict[Data.id]:
#				Connection.playerName = playerName
#				%PlayersInLobbyList.set_item_custom_bg_color(index, bgColor)
			


func _on_returnToLobby():
	pass


func _on_updateRooms(roomsDict : Dictionary, playersInGame : Array):
	for roomId in roomsDict:
		if not roomsTreeItems.has(roomId):
			var item : TreeItem = %RoomsTree.create_item(roomsTreeRoot)
			item.set_text(0, roomsDict[roomId]["name"])
			item.set_selectable(0, true)
			item.set_metadata(0, roomId)
			roomsTreeItems[roomId] = item
		if roomId == Data.id:
			%HostButton.disabled = true
			%JoinButton.disabled = true
			%ChangePlayerNameButton.disabled = true
			%PlayerNameTextEdit.editable = false
			%RoomContainer.show()
	for roomId in roomsTreeItems:
		if not roomsDict.has(roomId):
			var item : TreeItem = roomsTreeItems[roomId]
			roomsTreeRoot.remove_child(item)
			roomsTreeItems.erase(roomId)
		if playersInGame.has(roomId):
			var item : TreeItem = roomsTreeItems[roomId]
			var text : String = item.get_text(0)
			item.set_text(0, text + " (Started)")
			item.set_selectable(0, false)
			item.deselect(0)
	
	
#	var roomsInLobby : Array = []
#	var roomsToRemove : Array = []
#	for index in %RoomsList.item_count:
#		var roomName = %RoomsList.get_item_text(index)
#		if not roomsDict.values().has(roomName):
#			roomsToRemove.append(index)
#		else:
#			roomsInLobby.append(roomName)
#		%RoomsList.set_item_disabled(index, playersInGame.has(roomName))
#	for index in roomsToRemove:
#		%RoomsList.remove_item(index)
#	for roomId in roomsDict:
#		if roomsInLobby.has(roomsDict[roomId].name):
#			if roomId == Data.id:
#				%HostButton.disabled = true
#				%JoinButton.disabled = true
#				%RoomContainer.show()
#				%MovePlayerContainer.hide()
#				%SavegamePlayersContainer.hide()
#		else:
#			%RoomsList.add_item(roomsDict[roomId].name)
	
	
#	leaveRoomButton.disabled = true
#	rooms = roomsDict
#	room_id_array = []
#	player_in_room = []
#	for item in roomList.get_item_count():
#		roomList.remove_item(0)
#	for room in rooms:
#		room_id_array.append(room)
#		roomList.add_item(str(rooms[room]["name"]))
#		if playersInGame.has(room):
#			roomList.set_item_disabled(roomList.get_item_count() - 1, true)
#		else:
#			roomList.set_item_disabled(roomList.get_item_count() - 1, false)
#	for item in playerInRoomList.get_item_count():
#		playerInRoomList.remove_item(0)
#	if rooms.has(room_id):
#		leaveRoomButton.disabled = false
#		for player in rooms[room_id]["players"]:
#			player_in_room.append(player)
#			playerInRoomList.add_item(str(rooms[room_id]["players"][player]))
#			if player == room_id or player == get_tree().get_network_unique_id():
#				continue
#			rpc_id(player, "update_addon", firecardsCheckBox.pressed, quickCheckBox.pressed, extremeCheckBox.pressed, faceToFaceCheckBox.pressed, difficultyCheckBox.pressed)

func _on_roomCreated(playerId : int, roomName : String):
	
	%LoadingDataVBoxContainer.hide()
	AiPlayerNames = Data.profileNames.duplicate()
	%PlayerTree.custom_minimum_size = Vector2(500,300)
	var item : TreeItem = %RoomsTree.create_item(roomsTreeRoot)
	item.set_text(0, roomName)
	item.set_selectable(0, true)
	item.set_metadata(0, playerId)
	roomsTreeItems[playerId] = item
#	%RoomsList.add_item(roomName)
	if playerId == Data.id:
		%HostButton.disabled = true
		%JoinButton.disabled = true
		%ChangePlayerNameButton.disabled = true
		%PlayerNameTextEdit.editable = false
		%RoomContainer.show()
		%StartGameButton.show()
		%LoadGameButton.show()
		%LeaveRoomButton.show()
		%AddAiButton.show()
		%RoomLabel.text = roomName
		
		for childItem in playersInRoomTreeRoot.get_children():
			playersInRoomTreeRoot.remove_child(childItem)
		playersInRoomTreeItems.clear()
		item = %PlayerTree.create_item(playersInRoomTreeRoot)
		item.set_text(0, Connection.playerName)
		item.set_icon(0, playerIcon)
		item.set_selectable(0, false)
		item.set_text_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)
		item.set_metadata(0, playerId)
		item.set_text(1, Data.colorsNames[0])
		item.set_icon(1, Data.icons_small[Data.colorsNames[0]])
		item.set_selectable(1, true)
		item.set_text_alignment(1, HORIZONTAL_ALIGNMENT_FILL)
		%PlayerTree.set_column_title(2, "Kick Player")
		item.set_text(2, "Kick Player")
		item.set_selectable(2, true)
		item.set_text_alignment(2, HORIZONTAL_ALIGNMENT_CENTER)
		playersInRoomTreeItems[playerId] = item
#		item.set_custom_bg_color(0, bgColor, false)
		
		for colorName in colorMenuButtonIndices:
			var index : int = colorMenuButtonIndices[colorName]
			%ColorMenuButton.get_popup().set_item_disabled(index, false)
		
#		%PlayerList.clear()
#		var index = %PlayerList.add_item(Connection.playerName)
#		%PlayerList.set_item_custom_bg_color(index, bgColor)
		Connection.host = Data.id
		print("w0 ",Connection.host)
		Connection.playerIdNamesDict = {playerId : Connection.playerName}
		Connection.aiPlayersId.clear()
		
		if Tutorial.tutorial:
			if Tutorial.chapter == Tutorial.Chapter.Actions or Tutorial.chapter == Tutorial.Chapter.Soul or Tutorial.chapter == Tutorial.Chapter.Combat:
				_on_add_ai_button_pressed()
			_on_start_game_button_pressed()


func _on_roomClosed(playerId : int, roomName : String):
	var item : TreeItem = roomsTreeItems[playerId]
	roomsTreeRoot.remove_child(item)
	roomsTreeItems.erase(playerId)

#	for index in %RoomsList.item_count:
#		var roomNameEntry = %RoomsList.get_item_text(index)
#		if roomNameEntry == roomName:
#			%RoomsList.remove_item(index)
#			break
	if %RoomContainer.visible and roomName == %RoomLabel.text:
		%RoomLabel.text = ""
		%RoomContainer.hide()
		%HostButton.disabled = false
		%ChangePlayerNameButton.disabled = false
		%PlayerNameTextEdit.editable = true
#	playerLeftRoomAudio.play()
#	tween.interpolate_property(gapMarginContainer, "rect_min_size", Vector2(0,30), Vector2(0,300) , 0.5, Tween.TRANS_EXPO, Tween.EASE_OUT)
#	tween.start()
#	in_room = false
#	room_id = ""
#	createRoomButton.disabled = false
#	roomLineEdit.disabled = false
##	connectRoomButton.disabled = false
#	startButton.disabled = true
#	leaveRoomButton.disabled = true


func _on_startGame(roomId : int, peers : Array):
	if roomId == Data.id:
		if %PlayerTree.columns == 4:
			
			var loadedPlayerIdsLeft : Array = []
			for i in %PlayerMenuButton.get_popup().item_count:
				var loadedPlayerId : int = %PlayerMenuButton.get_popup().get_item_metadata(i)
				if not loadedPlayerId == 0:
					loadedPlayerIdsLeft.append(loadedPlayerId)
			loadedPlayerIdsLeft.shuffle()
			
			var loadedAiIdsLeft : Array = []
			for i in %AiMenuButton.get_popup().item_count:
				var loadedAiId : int = %AiMenuButton.get_popup().get_item_metadata(i)
				if not loadedAiId == 0:
					loadedAiIdsLeft.append(loadedAiId)
			loadedAiIdsLeft.shuffle()
			
			for item in playersInRoomTreeItems.values():
				var loadedPlayerId : int = item.get_metadata(3)
				if loadedPlayerId > 0:
					if loadedPlayerIdsLeft.has(loadedPlayerId):
						loadedPlayerIdsLeft.erase(loadedPlayerId)
					if loadedAiIdsLeft.has(loadedPlayerId):
						loadedAiIdsLeft.erase(loadedPlayerId)
			
			for item in playersInRoomTreeItems.values():
				var loadedPlayerId : int = item.get_metadata(3)
				if loadedPlayerId == 0:
					if item.get_metadata(0) > 0:
						var id : int = loadedPlayerIdsLeft.pop_back()
						item.set_metadata(3, id)
						for key in loadedPlayerIdNamesDict.keys():
							print("key? ", key, " ",typeof(key))
						item.set_text(3, loadedPlayerIdNamesDict[id])
					else:
						var id : int = loadedAiIdsLeft.pop_back()
						item.set_metadata(3, id)
						for key in loadedPlayerIdNamesDict.keys():
							print("key? ", key, " ",typeof(key))
						item.set_text(3, loadedPlayerIdNamesDict[id])
			
			for item in playersInRoomTreeItems.values():
				var playerName : String = item.get_text(0)
				var playerId : int = item.get_metadata(0)
				var loadedPlayerId : int = item.get_metadata(3)
				var loadedPlayerName : String = item.get_text(3)
				Connection.playerIdInfoDict[playerId] = {
					"playerName" : playerName,
					"loadedPlayerId" : loadedPlayerId,
					"loadedPlayerName" : loadedPlayerName
				}
			
			
	Connection.usedMenuToStartGame = true
	Connection.host = roomId
	Connection.peers = peers
	Connection.playersReady.clear()
	Connection.playerIdColorDict.clear()
	for playerId in playersInRoomTreeItems:
		Connection.playerIdColorDict[playerId] = playersInRoomTreeItems[playerId].get_text(1)
	%LoadingControl.show()
	await get_tree().create_timer(0.1).timeout
	
	while not ResourceLoader.load_threaded_get_status(game_res_path) == 3:
		print("loading")
	var gameScene = ResourceLoader.load_threaded_get(game_res_path)
#	get_tree().change_scene_to_packed(gameScene)
#	get_tree().change_scene_to_file("res://game.tscn")

	call_deferred("add_in_background", gameScene)

func add_in_background(child):
#	var instance = child.instantiate()
	get_tree().change_scene_to_packed(child)


@rpc("any_peer", "call_local")
func start():
	Connection.usedMenuToStartGame = true
	%LoadingControl.show()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://game.tscn")


#@rpc("any_peer", "call_local")
#func addPlayerToList(playerName : String):
#	%PlayerList.add_item(playerName)


@rpc("any_peer", "call_local")
func showSavegamePlayers(_playerIdNamesDict : Dictionary):
	%PlayerTree.columns = 4
	%PlayerTree.set_column_title(3, "Play as")
	for i in playersInRoomTreeItems:
		playersInRoomTreeItems[i].set_text(3, "Random")
		playersInRoomTreeItems[i].set_metadata(3, 0)
		if not playersInRoomTreeItems[i].get_metadata(0) == Data.id and not Connection.host == Data.id:
			playersInRoomTreeItems[i].set_selectable(3, false)
		playersInRoomTreeItems[i].set_text_alignment(3, HORIZONTAL_ALIGNMENT_CENTER)
	
	%PlayerMenuButton.get_popup().clear()
	%PlayerMenuButton.get_popup().index_pressed.connect(_on_PlayerMenuButton_index_pressed)
	playerMenuButtonIndices[0] = 0
	%PlayerMenuButton.get_popup().add_item("Random")
	%PlayerMenuButton.get_popup().set_item_metadata(0, 0)
	
	%AiMenuButton.get_popup().clear()
	%AiMenuButton.get_popup().index_pressed.connect(_on_AiMenuButton_index_pressed)
	aiMenuButtonIndices[0] = 0
	%AiMenuButton.get_popup().add_item("Random")
	%AiMenuButton.get_popup().set_item_metadata(0, 0)
	
	for playerId in _playerIdNamesDict:
		if playerId > 0:
			var i : int = %PlayerMenuButton.get_popup().item_count
			playerMenuButtonIndices[playerId] = i
			%PlayerMenuButton.get_popup().add_item(_playerIdNamesDict[playerId])
			%PlayerMenuButton.get_popup().set_item_metadata(i, playerId)
		else:
			var i : int = %AiMenuButton.get_popup().item_count
			aiMenuButtonIndices[playerId] = i
			%AiMenuButton.get_popup().add_item(_playerIdNamesDict[playerId])
			%AiMenuButton.get_popup().set_item_metadata(i, playerId)


func _on_PlayerMenuButton_index_pressed(index):
	print("playerName ", %PlayerMenuButton.get_popup().get_item_text(index))
	print("playerId ", %PlayerMenuButton.get_popup().get_item_metadata(index))
	var loadedPlayerName : String = %PlayerMenuButton.get_popup().get_item_text(index)
	var loadedPlayerId : int = %PlayerMenuButton.get_popup().get_item_metadata(index)
	change_player_request.rpc_id(Connection.host, selectedPlayerId, loadedPlayerName, loadedPlayerId)


func _on_AiMenuButton_index_pressed(index):
	print("playerName ", %AiMenuButton.get_popup().get_item_text(index))
	print("playerId ", %AiMenuButton.get_popup().get_item_metadata(index))
	var loadedPlayerName : String = %AiMenuButton.get_popup().get_item_text(index)
	var loadedPlayerId : int = %AiMenuButton.get_popup().get_item_metadata(index)
	change_player_request.rpc_id(Connection.host, selectedPlayerId, loadedPlayerName, loadedPlayerId)


@rpc("any_peer", "call_local")
func change_player_request(player_id : int, loaded_player_name : String, loaded_player_id : int):
	for item in playersInRoomTreeItems.values():
		if item.get_metadata(1) == loaded_player_id and not loaded_player_name == "Random":
			return
	for peer in playersInRoomTreeItems:
		if not peer < 0: # ID < 0 is AI Player
			if player_id > 0:
				change_player.rpc_id(peer, player_id, loaded_player_name, loaded_player_id)
			else:
				change_ai.rpc_id(peer, player_id, loaded_player_name, loaded_player_id)

@rpc("any_peer", "call_local")
func change_player(player_id : int, loaded_player_name : String, loaded_player_id : int):
	var item : TreeItem = playersInRoomTreeItems[player_id]
	item.set_text(3, loaded_player_name)
	item.set_metadata(3, loaded_player_id)
	for playerId in playerMenuButtonIndices:
		var index : int = playerMenuButtonIndices[playerId]
		var buttonPlayerName : String = %PlayerMenuButton.get_popup().get_item_text(index)
		var buttonPlayerId : int = %PlayerMenuButton.get_popup().get_item_metadata(index)
		%PlayerMenuButton.get_popup().set_item_disabled(index, false)
		for playerItem in playersInRoomTreeItems.values():
			if playerItem.get_metadata(3) == buttonPlayerId and not buttonPlayerName == "Random":
				%PlayerMenuButton.get_popup().set_item_disabled(index, true)
				break


@rpc("any_peer", "call_local")
func change_ai(player_id : int, loaded_player_name : String, loaded_player_id : int):
	var item : TreeItem = playersInRoomTreeItems[player_id]
	item.set_text(3, loaded_player_name)
	item.set_metadata(3, loaded_player_id)
	for playerId in aiMenuButtonIndices:
		var index : int = aiMenuButtonIndices[playerId]
		var buttonPlayerName : String = %AiMenuButton.get_popup().get_item_text(index)
		var buttonPlayerId : int = %AiMenuButton.get_popup().get_item_metadata(index)
		%AiMenuButton.get_popup().set_item_disabled(index, false)
		for playerItem in playersInRoomTreeItems.values():
			if playerItem.get_metadata(3) == buttonPlayerId and not buttonPlayerName == "Random":
				%AiMenuButton.get_popup().set_item_disabled(index, true)
				break


func _on_start_game_button_pressed():
	var aiPlayers : int = 0
	var humanPlayers : int = 0
	if not OS.has_feature("editor") and not Tutorial.tutorial:
		if playersInRoomTreeItems.size() < 3:
			%NotEnoughPlayersMarginContainer.show()
			return
	for id in playersInRoomTreeItems:
		if id > 0:
			aiPlayers += 1
		else:
			humanPlayers += 1
	if loadedPlayerIdNamesDict.size() > 0:
		if not aiPlayers == aiMenuButtonIndices.size() - 1 or not humanPlayers == playerMenuButtonIndices.size() - 1:
			print(loadedPlayerIdNamesDict.size(), playerMenuButtonIndices.size() + aiMenuButtonIndices.size() - 2)
			%CannotStartMarginContainer.show()
			return
	Server.request_start_game.rpc_id(1, Data.id)


func _on_load_game_button_pressed():
	var saveDir = DirAccess.open("user://savegames/")
	if saveDir:
		var filesNames = Save.readFilenames("savegames")
		var timestamps : Array = []
		%SavegameList.clear()
		for filesName in filesNames:
			var modTime : int = FileAccess.get_modified_time("user://savegames/" + filesName)
			%SavegameList.add_item(filesName)
			%SavegameList.move_item(%SavegameList.item_count - 1, 0)
			%SavegameList.set_item_metadata(0, modTime)
			
			var datetime : String = Time.get_datetime_string_from_unix_time(%SavegameList.get_item_metadata(0))
			
			var file = FileAccess.open("user://savegames/" + filesName, FileAccess.READ)
			var json_string = file.get_as_text()
			var json = JSON.new()
			var error = json.parse(json_string)
			var savegame : Dictionary
			if error == OK:
				savegame = json.data
			else:
				print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			
			var item : TreeItem = %SavegameTree.create_item(savegameTreeRoot, 0)
			item.set_text(0, filesName)
			item.set_text(1, datetime)
			var playerNames : String = ""
			for playerName in savegame.players:
				playerNames += savegame.players[playerName].playerName
				playerNames += " | "
			item.set_text(2, playerNames)
			if savegame.game.has("turn"):
				item.set_text(3, str(savegame.game.turn))
			if savegame.game.has("phase"):
				item.set_text(4, Data.phases.keys()[savegame.game.phase])
			savegameTreeItems[modTime] = item
		
		if savegameTreeRoot.get_child_count() > 0:
			var item : TreeItem = savegameTreeRoot.get_child(0)
			item.select(0)
			
		%SavegameList.select(0, true)
		
		
		
		$LobbyContainer.hide()
		%LoadSavegameContainer.show()


@rpc("any_peer", "call_local")
func updateloadedData(_savegameData : Dictionary):
	%DateLabel.text = _savegameData.date
	%TurnLabel.text = _savegameData.turn
	%PhaseLabel.text = _savegameData.phase
	%PlayersLabel.text = ""
	%PlayersLabel2.text = ""
	%PlayersLabel3.text = ""
	%PlayersLabel4.text = ""
	%PlayersLabel5.text = ""
	%PlayersLabel6.text = ""
	print("savegameplayer" ,_savegameData.players)
	var i : int = 0
	for playerName in _savegameData.players:
		match i:
			0:
				%PlayersLabel.text = playerName
			1:
				%PlayersLabel2.text = playerName
			2:
				%PlayersLabel3.text = playerName
			3:
				%PlayersLabel4.text = playerName
			4:
				%PlayersLabel5.text = playerName
			5:
				%PlayersLabel6.text = playerName
		i += 1
	%LoadingDataVBoxContainer.show()


func _on_select_savegame_button_pressed():
	var savegame_item : TreeItem = %SavegameTree.get_selected()
	if savegame_item:
		savegameData.filename = savegame_item.get_text(0)
		savegameData.date = savegame_item.get_text(1)
		savegameData.players.clear()
		savegameData.turn = savegame_item.get_text(3)
		savegameData.phase = savegame_item.get_text(4)
		
		var filename = savegame_item.get_text(0)
		Save.loadGame(filename)
		%LoadSavegameContainer.hide()
		$LobbyContainer.show()
		var playerIdNamesDict : Dictionary = {}
		for playerKey  in Save.savegame.players:
			# json numbers are always float, have to cast it as int
			playerIdNamesDict[int(Save.savegame.players[playerKey]["playerId"])] = Save.savegame.players[playerKey]["playerName"]
			savegameData.players.append(Save.savegame.players[playerKey]["playerName"])
		
		loadedPlayerIdNamesDict.clear()
		loadedPlayerIdNamesDict = playerIdNamesDict.duplicate()
		
	#		showSavegamePlayers(loadedPlayerIdNamesDict)
		for peer in Connection.playerIdNamesDict.keys():
			if peer > 0:
				showSavegamePlayers.rpc_id(peer, loadedPlayerIdNamesDict)
				updateloadedData.rpc_id(peer, savegameData)
		
		var idsUsed : Array = []
		for id in playersInRoomTreeItems:
			if id < 0 and not idsUsed.has(id):
				print(id, idsUsed)
				idsUsed.append(id)
				var item : TreeItem = playersInRoomTreeItems[id]
				Server.leave_room.rpc_id(1, Connection.host, item.get_metadata(0))
				print("before ", Connection.aiPlayersId)
				Connection.aiPlayersId.erase(item.get_metadata(0))
				var aiName : String = item.get_text(0)
				if aiName.contains(" (AI)"):
					aiName = aiName.rstrip(" (AI)")
					AiPlayerNames.append(aiName)
				print("after ", Connection.aiPlayersId)
#					if item.get_metadata(0) < 0: # ID < 0 is AI Player
#						AiPlayerNames.append(item.get_text(0))
				if playersInRoomTreeItems.size() > 3:
					%PlayerTree.custom_minimum_size -= Vector2(0, 64)
				item.deselect(2)
		
		var aiPlayersLoadedIds : Array = []
		for id in loadedPlayerIdNamesDict:
			if id < 0:
				aiPlayersLoadedIds.append(id)
		
		print("ai to add ",aiPlayersLoadedIds)
		for id in aiPlayersLoadedIds:
			_on_add_ai_button_pressed(id)
		
#	if %SavegameList.is_anything_selected():
#		var itemIndices = %SavegameList.get_selected_items()
#		var filename = %SavegameList.get_item_text(itemIndices[0])
#		Save.loadGame(filename)
#		%LoadSavegameContainer.hide()
#		$LobbyContainer.show()
#		var playerIdNamesDict : Dictionary = {}
#		for playerKey  in Save.savegame.players:
#			# json numbers are always float, have to cast it as int
#			playerIdNamesDict[int(Save.savegame.players[playerKey]["playerId"])] = Save.savegame.players[playerKey]["playerName"]
#
#		loadedPlayerIdNamesDict.clear()
#		loadedPlayerIdNamesDict = playerIdNamesDict.duplicate()
#
##		showSavegamePlayers(loadedPlayerIdNamesDict)
#		for peer in Connection.playerIdNamesDict.keys():
#			showSavegamePlayers.rpc_id(peer, loadedPlayerIdNamesDict)


func _on_cancel_button_pressed():
	%LoadSavegameContainer.hide()
	$LobbyContainer.show()


func _on_back_button_pressed():
	Connection.host = null
	Connection.closeConnection()
	%LoadingControl.show()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")


func _on_host_button_pressed():
	%PlayerTree.columns = 3
	%PlayerTree.set_column_clip_content(2, false)
	%PlayerTree.set_column_expand(2, true)
	Server.create_room.rpc_id(1, Connection.playerName + "'s Room")


func _on_join_button_pressed():
	var item : TreeItem = %RoomsTree.get_next_selected(roomsTreeRoot)
	item.deselect(0)
	for roomItem in roomsTreeItems.values():
		roomItem.set_selectable(0, false)
	var roomId : int = item.get_metadata(0)
#	var index = %RoomsList.get_selected_items()[0]
#	var roomName = %RoomsList.get_item_text(index)
	print("join ", roomId)
	%PlayerTree.columns = 3
	%PlayerTree.set_column_title(2, "")
	%PlayerTree.set_column_clip_content(2, true)
	%PlayerTree.set_column_expand(2, false)
	Server.join_room.rpc_id(1, roomId)
	

func _on_playerjoinedRoom(roomId : int, room_name : String, player_id : int, playerIdNamesDict : Dictionary, is_ai):
	if playersInRoomTreeItems.size() >= 6 and Connection.host == Data.id:
		Server.leave_room.rpc_id(1, Connection.host, player_id)
		return
	if playersInRoomTreeItems.size() >= 3:
		%PlayerTree.custom_minimum_size += Vector2(0, 64)
	Connection.playerIdNamesDict = playerIdNamesDict.duplicate()
	
	if %PlayerTree.columns == 4 and Connection.host == Data.id and not player_id < 0:
		updateloadedData.rpc_id(player_id, savegameData)
		showSavegamePlayers.rpc_id(player_id, loadedPlayerIdNamesDict)
		# send the new player the already selected players in the loading column
		for index in playersInRoomTreeItems:
			var item : TreeItem = playersInRoomTreeItems[index]
			var playerId : int = item.get_metadata(0)
			var loaded_player_name : String = item.get_text(3)
			var loaded_player_id : int = item.get_metadata(3)
			change_player.rpc_id(player_id, playerId, loaded_player_name, loaded_player_id)
	
	if is_ai:
		var item : TreeItem = %PlayerTree.create_item(playersInRoomTreeRoot)
		playersInRoomTreeItems[player_id] = item
		item.set_text(0, playerIdNamesDict[player_id])
		item.set_selectable(0, false)
		item.set_text_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)
		item.set_metadata(0, player_id)
		item.set_text(1, Data.colorsNames[0])
		item.set_icon(1, Data.icons_small[Data.colorsNames[0]])
		item.set_text_alignment(1, HORIZONTAL_ALIGNMENT_FILL)
		item.set_selectable(2, false)
		item.set_text_alignment(2, HORIZONTAL_ALIGNMENT_CENTER)
		if not Data.id == Connection.host:
			item.set_selectable(1, false)
		else:
			%PlayerTree.set_column_title(2, "Kick Player")
			item.set_text(2, "Kick Player")
			item.set_selectable(2, true)
		if %PlayerTree.columns == 4:
			item.set_text(3, "Random")
			item.set_metadata(3, 0)
			if not item.get_metadata(0) == Data.id and not Connection.host == Data.id:
				item.set_selectable(3, false)
			item.set_text_alignment(3, HORIZONTAL_ALIGNMENT_CENTER)
			if Data.id == Connection.host:
				change_color_request.rpc_id(Connection.host, player_id,  Save.savegame.players[str(player_id)].colorName)
		return
#	for playerId in playerIdNamesDict:
#		Connection.playerNamesIdDict[playerIdNamesDict[playerId]] = playerId
	
	print("joined room ", playerIdNamesDict)
	if playerIdNamesDict.has(Data.id) and not %RoomContainer.visible:
		%HostButton.disabled = true
		%JoinButton.disabled = true
		%ChangePlayerNameButton.disabled = true
		%PlayerNameTextEdit.editable = false
		%RoomContainer.show()
		%StartGameButton.hide()
		%LoadGameButton.hide()
		%AddAiButton.hide()
		%LeaveRoomButton.show()
		%RoomLabel.text = room_name
		
		Connection.host = roomId
		
		if player_id == Data.id:
			%LoadingDataVBoxContainer.hide()
		
		for childItem in playersInRoomTreeRoot.get_children():
			playersInRoomTreeRoot.remove_child(childItem)
		playersInRoomTreeItems.clear()
		
		print("joined room 2 ", Data.id, playerIdNamesDict)
		for playerId in playerIdNamesDict:
			var item : TreeItem = %PlayerTree.create_item(playersInRoomTreeRoot)
			item.set_text(0, playerIdNamesDict[playerId])
			item.set_selectable(0, false)
			item.set_text_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)
			item.set_metadata(0, playerId)
			item.set_text(1, Data.colorsNames[0])
			item.set_icon(1, Data.icons_small[Data.colorsNames[0]])
			item.set_text_alignment(1, HORIZONTAL_ALIGNMENT_FILL)
			if not Data.id == playerId:
				item.set_selectable(1, false)
			item.set_selectable(2, false)
			item.set_text_alignment(2, HORIZONTAL_ALIGNMENT_CENTER)
			if Data.id == Connection.host:
				%PlayerTree.set_column_title(2, "Kick Player")
				item.set_text(2, "Kick Player")
				item.set_selectable(2, true)
			
			if %PlayerTree.columns == 4:
				item.set_text(3, "Random")
				item.set_metadata(3, 0)
				if not item.get_metadata(0) == Data.id:
					item.set_selectable(3, false)
				item.set_text_alignment(3, HORIZONTAL_ALIGNMENT_CENTER)
			playersInRoomTreeItems[playerId] = item
			if playerId == Data.id:
				item.set_icon(0, playerIcon)
#				item.set_custom_bg_color(0, bgColor, false)
		%PlayerTree.custom_minimum_size = Vector2(500,300)
		for i in playersInRoomTreeItems.size() - 3:
			%PlayerTree.custom_minimum_size += Vector2(0, 64)
#		%PlayerList.clear()
#		for playerId in playerIdNamesDict:
#			var index = %PlayerList.add_item(playerIdNamesDict[playerId])
#			if playerIdNamesDict[playerId] == Connection.playerName:
#				%PlayerList.set_item_custom_bg_color(index, bgColor)
#			Connection.playerIdNamesDict[playerId] = playerIdNamesDict[playerId]
		
	elif %RoomLabel.text == room_name and %RoomContainer.visible:
		for playerId in playerIdNamesDict:
			if not playersInRoomTreeItems.has(playerId):
				var item : TreeItem = %PlayerTree.create_item(playersInRoomTreeRoot)
				item.set_text(0, playerIdNamesDict[playerId])
				item.set_selectable(0, false)
				item.set_text_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)
				item.set_metadata(0, playerId)
				item.set_text(1, Data.colorsNames[0])
				item.set_icon(1, Data.icons_small[Data.colorsNames[0]])
				item.set_text_alignment(1, HORIZONTAL_ALIGNMENT_FILL)
				if not Data.id == playerId:
					item.set_selectable(1, false)
				item.set_selectable(2, false)
				item.set_text_alignment(2, HORIZONTAL_ALIGNMENT_CENTER)
				if Data.id == Connection.host:
					%PlayerTree.set_column_title(2, "Kick Player")
					item.set_text(2, "Kick Player")
					item.set_selectable(2, true)
				if %PlayerTree.columns == 4:
					item.set_text(3, "Random")
					item.set_metadata(3, 0)
					if not item.get_metadata(0) == Data.id:
						item.set_selectable(3, false)
					item.set_text_alignment(3, HORIZONTAL_ALIGNMENT_CENTER)
				playersInRoomTreeItems[playerId] = item
				if playerId == Data.id:
					item.set_icon(0, playerIcon)
#					item.set_custom_bg_color(0, bgColor, false)
				
				if Data.id == Connection.host:
					for playerItem in playersInRoomTreeItems.values():
						change_color.rpc_id(playerId, playerItem.get_metadata(0), playerItem.get_text(1))
#		var namesToAdd = []
#		for playerId in playerIdNamesDict:
##			Connection.playerIdNamesDict[playerId] = playerIdNamesDict[playerId]
#			var hasName = false
#			for index in %PlayerList.item_count:
#				var playerName = %PlayerList.get_item_text(index)
#				if playerName == playerIdNamesDict[playerId]:
#					hasName = true
#			if not hasName:
#				namesToAdd.append(playerIdNamesDict[playerId])
#		for nameToAdd in namesToAdd:
#			var index = %PlayerList.add_item(nameToAdd)
#			if nameToAdd == Connection.playerName:
#				%PlayerList.set_item_custom_bg_color(index, bgColor)
		

func _on_playerLeftRoom(playerId : int):
	if not playersInRoomTreeItems.has(playerId):
		return
	if playersInRoomTreeItems.size() > 3:
		%PlayerTree.custom_minimum_size -= Vector2(0, 64)
	var item : TreeItem = playersInRoomTreeItems[playerId]
	playersInRoomTreeRoot.remove_child(item)
	playersInRoomTreeItems.erase(playerId)
	if playerId == Data.id:
		%RoomContainer.hide()
		%HostButton.disabled = false
		%ChangePlayerNameButton.disabled = false
		%PlayerNameTextEdit.editable = true
		for roomItem in roomsTreeItems.values():
			roomItem.set_selectable(0, true)
#	for index in %PlayerList.item_count:
#		var playerNameEntry = %PlayerList.get_item_text(index)
#		if playerNameEntry == playerName:
#			%PlayerList.remove_item(index)
#			break

func _on_rooms_list_item_selected(index):
	if not %RoomContainer.visible:
		%JoinButton.disabled = false


func _on_leave_room_button_pressed():
	Server.leave_room.rpc_id(1, Connection.host, Data.id)


func _on_rooms_tree_item_selected():
	if not %RoomContainer.visible:
		%JoinButton.disabled = false


func _on_ColorMenuButton_index_pressed(index):
	change_color_request.rpc_id(Connection.host, selectedPlayerId,  %ColorMenuButton.get_popup().get_item_text(index))


@rpc("any_peer", "call_local")
func change_color_request(player_id : int, color_name : String):
	for item in playersInRoomTreeItems.values():
		if item.get_text(1) == color_name and not color_name == Data.colorsNames[0]:
			return
	for peer in playersInRoomTreeItems:
		if not peer < 0: # ID < 0 is AI Player
			change_color.rpc_id(peer, player_id, color_name)


@rpc("any_peer", "call_local")
func change_color(player_id : int, color_name : String):
	print("change color ",color_name)
	var item : TreeItem = playersInRoomTreeItems[player_id]
	item.set_text(1, color_name)
	item.set_icon(1, Data.icons_small[color_name])
	for colorName in colorMenuButtonIndices:
		var index : int = colorMenuButtonIndices[colorName]
		%ColorMenuButton.get_popup().set_item_disabled(index, false)
		for playerItem in playersInRoomTreeItems.values():
			if playerItem.get_text(1) == colorName and not colorName == Data.colorsNames[0]:
				%ColorMenuButton.get_popup().set_item_disabled(index, true)
				break


func _on_add_ai_button_pressed(loadedId : int = 0):
	# need to manage when loading game and too many human players joined
	if playersInRoomTreeItems.size() >= 6 and not loadedPlayerIdNamesDict.size() > 0:
		return
#	var id : int = randi_range(-100, -1) # ID < 0 is AI Player
	if loadedId < 0:
		var id : int = loadedId
		var aiName : String = Save.savegame.players[str(id)].playerName
		Server.add_ai_to_room.rpc_id(1, Data.id, id, aiName)
		Connection.aiPlayersId.append(id)
		print("add AI Player ", Connection.aiPlayersId.size())
	else:
		aiID -= 1 
		var id : int = aiID
		AiPlayerNames.shuffle()
		var aiName : String = AiPlayerNames.pop_back()
		Server.add_ai_to_room.rpc_id(1, Data.id, id, aiName + " (AI)")
		Connection.aiPlayersId.append(id)
		print("add AI Player ", Connection.aiPlayersId.size())


func _on_player_tree_item_selected():
	var item : TreeItem = %PlayerTree.get_next_selected(playersInRoomTreeRoot)
	print("selected ", item)
	
	for column in %PlayerTree.columns:
		if item.is_selected(column):
			print("column ", column)
			match column:
				1:
					selectedPlayerId = item.get_metadata(0)
					%ColorMenuButton.position = get_local_mouse_position()
					%ColorMenuButton.show_popup()
					item.deselect(1)
				2:
					Server.leave_room.rpc_id(1, Connection.host, item.get_metadata(0))
					print("before ", Connection.aiPlayersId)
					Connection.aiPlayersId.erase(item.get_metadata(0))
					var aiName : String = item.get_text(0)
					if aiName.contains(" (AI)"):
						aiName = aiName.rstrip(" (AI)")
						AiPlayerNames.append(aiName)
					print("after ", Connection.aiPlayersId)
#					if item.get_metadata(0) < 0: # ID < 0 is AI Player
#						AiPlayerNames.append(item.get_text(0))
					if playersInRoomTreeItems.size() > 3:
						%PlayerTree.custom_minimum_size -= Vector2(0, 64)
					item.deselect(2)
				3:
					selectedPlayerId = item.get_metadata(0)
					if selectedPlayerId > 0:
						%PlayerMenuButton.position = get_local_mouse_position()
						%PlayerMenuButton.show_popup()
#					else:
#						%AiMenuButton.position = get_local_mouse_position()
#						%AiMenuButton.show_popup()
					item.deselect(3)


func _on_change_player_name_button_pressed():
	var text : String = %PlayerNameTextEdit.text
	if text == "":
		return
	Data.profile.playername = text
	Save.saveProfile(Data.profile)
	Server.request_name_change.rpc_id(1, Data.id, text)


func _on_savegame_tree_item_activated():
	_on_select_savegame_button_pressed()


func _on_button_pressed():
	%CannotStartMarginContainer.hide()


func _on_not_enough_players_button_pressed():
	%NotEnoughPlayersMarginContainer.hide()
