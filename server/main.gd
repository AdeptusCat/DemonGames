extends Node

var network = ENetMultiplayerPeer.new()
var port = 1920
var max_players = 100

var peers = []
var playersIdNameDict = {} # dict of playerId's and their names
var rooms = {}
var playersInGame = []
var serverActive : bool = false

#func _init():
	

func _ready():
#	var serverTree = SceneTree.new()
#	serverTree.set_multiplayer(serverTree.get_multiplayer(), self.get_path())
	Server.fetchPlayers.connect(_on_fetchPlayers)
	Server.fetchRooms.connect(_on_fetchRooms)
	Server.joinRoom.connect(_on_joinRoom)
	Server.createRoom.connect(_on_createRoom)
	Server.leaveRoom.connect(_on_leaveRoom)
	Server.requestStartGame.connect(_on_requestStartGame)
	Server.returnToLobby.connect(_on_returnToLobby)
	Server.requestNameChange.connect(_on_request_name_change)
	


func StartServer():
	peers.append(1)
	print("started hosting")
	network.create_server(port)
	multiplayer.multiplayer_peer = network
	network.peer_connected.connect(func(id): peer_connected(id))
	network.peer_disconnected.connect(func(id): peer_disconnected(id))


func _on_request_name_change(playerId : int, playerName : String):
	if playersIdNameDict.has(playerId):
		playersIdNameDict[playerId] = playerName
		Server.change_player_name.rpc(playerId, playerName)


func peer_connected(player_id):
	print("connected: ", player_id)
	playersIdNameDict[player_id] = str(player_id)
	await get_tree().create_timer(0.1).timeout
#	Server.player_connected.rpc_id(player_id)
	Server.return_players.rpc_id(player_id, playersIdNameDict)
	Server.return_rooms.rpc_id(player_id, rooms, playersInGame)
	for playerId in playersIdNameDict:
		if not playerId == player_id:
			Server.player_connected.rpc_id(playerId, playersIdNameDict[player_id])

func peer_disconnected(player_id):
	print("disconnected: ", player_id, " ", playersIdNameDict[player_id])
	
	# wait, otherwise it sends to player_id which is already disconnected.
	await get_tree().create_timer(0.1).timeout
	
	for playerId in playersIdNameDict:
		if not playerId == player_id:
			Server.player_disconnected.rpc_id(playerId, playersIdNameDict[player_id], player_id)
#		if roomClosed:
#			Server.room_closed.rpc_id(playerId, player_id)
	
	playersIdNameDict.erase(player_id)
	playersInGame.erase(player_id)
	
	var roomClosed = false
	if rooms.has(player_id):
		Server.room_closed.rpc(player_id, rooms[player_id]["name"])
#		for id in rooms[player_id]["players"]:
#			if not id == player_id:
#				Server.closed_room.rpc_id(id)
		rooms.erase(player_id)
	for room in rooms:
		for id in rooms[room]["players"]:
			if id == player_id:
				for playerId in rooms[room]["players"]:
					if not playerId == player_id:
						Server.player_left_room.rpc_id(playerId, player_id)
				rooms[room]["players"].erase(id)
				break
	
	
	


func _on_returnToLobby():
	var player_id = get_tree().get_rpc_sender_id()
	playersInGame.erase(player_id)
	if rooms.has(player_id):
		for player in rooms[player_id]["players"]:
			if not player == player_id:
				rpc_id(player, "closed_room")
		rooms.erase(player_id)
	for room in rooms:
		for player in rooms[room]["players"]:
			if player_id == player:
				rooms[room]["players"].erase(player)
			else:
				rpc_id(player, "left_room")
	Server.return_players.rpc(playersIdNameDict)
	Server.return_rooms.rpc(rooms, playersInGame)
	print("returning to lobby: ", player_id, " ", playersIdNameDict[player_id])


func _on_createRoom(room_name : String):
	var player_id = multiplayer.get_remote_sender_id()
	rooms[player_id] = {"name" : null, "players" : {}}
	rooms[player_id]["name"] = room_name
	rooms[player_id]["players"][player_id] = playersIdNameDict[player_id]
	Server.room_created.rpc(player_id, room_name)
#	Server.return_rooms.rpc(rooms, playersInGame)
	print("creating  room: ", room_name)


func _on_joinRoom(room_name : String):
	var player_id = multiplayer.get_remote_sender_id()
	for room_id in rooms:
		if room_name == rooms[room_id]["name"]:
			rooms[room_id]["players"][player_id] = playersIdNameDict[player_id]
			Server.return_rooms.rpc(rooms, playersInGame)
			for id in rooms[room_id]["players"]:
				Server.joined_room.rpc_id(id, room_id, room_name, player_id, rooms[room_id]["players"], false)
			print("joining room: player_id ", player_id, ", ", rooms[room_id])
			break


func _on_fetchPlayers():
	var player_id = multiplayer.get_remote_sender_id()
	Server.return_players.rpc_id(player_id, playersIdNameDict)


func _on_fetchRooms():
	var player_id = multiplayer.get_remote_sender_id()
	Server.return_rooms.rpc_id(player_id, rooms, playersInGame)


@rpc("any_peer", "call_local")
func _on_leaveRoom(room_id : int):
	var player_id = multiplayer.get_remote_sender_id()
	if player_id == room_id:
		Server.room_closed.rpc(player_id, rooms[room_id]["name"])
		rooms.erase(room_id)
#		Server.return_rooms.rpc(rooms, playersInGame)
		return
	for id in rooms[room_id]["players"]:
		Server.player_left_room.rpc_id(id, player_id)
	print("leaving room : player_id ", room_id, " ", rooms[room_id]["players"][player_id])
	rooms[room_id]["players"].erase(player_id)
#	Server.return_rooms.rpc(rooms, playersInGame)


func _on_requestStartGame(room_id : int):
	var player_id = multiplayer.get_remote_sender_id()
	for id in rooms[player_id]["players"]:
		playersInGame.append(id)
		Server.start_game.rpc_id(id, player_id, rooms[player_id]["players"].keys())
		
#	Server.return_rooms.rpc(rooms, playersInGame)
	print("starting game : ", rooms[player_id]["players"])
