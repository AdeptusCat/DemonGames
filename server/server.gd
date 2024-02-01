extends Node

var network = ENetMultiplayerPeer.new()
var multiplayer_api : MultiplayerAPI
var port = 1920
var max_players = 100

var peers = []
var playersIdNameDict = {} # dict of playerId's and their names
var rooms = {}
var playersInGame = []
var serverActive : bool = false

#func _init():
	
var server

func _ready():
#	serverTree = SceneTree.new()
#	serverTree.set_multiplayer(serverTree.get_multiplayer(), self.get_path())
#	network = ENetMultiplayerPeer.new()
	
	multiplayer_api = MultiplayerAPI.create_default_interface()
	get_tree().set_multiplayer(multiplayer_api, self.get_path())
	#self.get_path()
	# duplicate the node, script and signals
	server =  Server.duplicate(5)
	add_child(server)
	
	server.fetchPlayers.connect(_on_fetchPlayers)
	server.fetchRooms.connect(_on_fetchRooms)
	server.joinRoom.connect(_on_joinRoom)
	server.createRoom.connect(_on_createRoom)
	server.leaveRoom.connect(_on_leaveRoom)
	server.requestStartGame.connect(_on_requestStartGame)
	server.returnToLobby.connect(_on_returnToLobby)
	server.addAi.connect(_on_addAi)
	server.removeAi.connect(_on_removeAi)
	server.requestNameChange.connect(_on_request_name_change)


func StartServer():
	if not serverActive:
		peers.append(1)
		print("started hosting")
		var error : Error = network.create_server(port)
		match error:
			ERR_ALREADY_IN_USE:
				return
			ERR_CANT_CREATE:
				return
			OK:
			#	multiplayer.multiplayer_peer = network
				multiplayer_api.multiplayer_peer = network
				network.peer_connected.connect(func(id): peer_connected(id))
				network.peer_disconnected.connect(func(id): peer_disconnected(id))
				serverActive = true
				
#				print(rpcFunction.get_method())
#				sendFunction(rpcFunction, rpcFunction.bind("testString"))


func sendFunction(f : Callable, bindingF : Callable):
	print(f)
	print(f.get_method())
	var args : Array = f.get_bound_arguments()
	print(f.get_method())
	f = Callable(f.get_object(), str(f.get_method()))
	print(f)
	f.rpc(args[0])


@rpc("any_peer", "call_local")
func rpcFunction(str : String = ""):
	print(str)


func peer_connected(player_id):
	print("connected: ", player_id)
	playersIdNameDict[player_id] = "Player " + str(playersIdNameDict.size()+1)
	await get_tree().create_timer(0.1).timeout
#	server.player_connected.rpc_id(player_id)
	server.return_players.rpc_id(player_id, playersIdNameDict)
	server.return_rooms.rpc_id(player_id, rooms, playersInGame)
	for playerId in playersIdNameDict:
		if not playerId == player_id:
			server.player_connected.rpc_id(playerId, playersIdNameDict[player_id], player_id)


func _on_request_name_change(playerId : int, playerName : String):
	if playersIdNameDict.has(playerId):
		playersIdNameDict[playerId] = playerName
		server.change_player_name.rpc(playerId, playerName)


func peer_disconnected(player_id):
	print("disconnected: ", player_id, " ", playersIdNameDict[player_id])
	
	# wait, otherwise it sends to player_id which is already disconnected.
	await get_tree().create_timer(0.1).timeout
	
	for playerId in playersIdNameDict:
		if not playerId == player_id:
			server.player_disconnected.rpc_id(playerId, player_id)
#		if roomClosed:
#			server.room_closed.rpc_id(playerId, player_id)
	
	playersIdNameDict.erase(player_id)
	playersInGame.erase(player_id)
	
	var roomClosed = false
	if rooms.has(player_id):
		server.room_closed.rpc(player_id, rooms[player_id]["name"])
#		for id in rooms[player_id]["players"]:
#			if not id == player_id:
#				server.closed_room.rpc_id(id)
		rooms.erase(player_id)
	for room in rooms:
		for id in rooms[room]["players"]:
			if id == player_id:
				for playerId in rooms[room]["players"]:
					if not playerId == player_id:
						server.player_left_room.rpc_id(playerId, player_id)
				rooms[room]["players"].erase(id)
				break
	
	
	


func _on_returnToLobby():
	var player_id = multiplayer.get_remote_sender_id()
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
	server.return_players.rpc(playersIdNameDict)
	server.return_rooms.rpc(rooms, playersInGame)
	print("returning to lobby: ", player_id, " ", playersIdNameDict[player_id])


func _on_createRoom(room_name : String):
	var player_id = multiplayer.get_remote_sender_id()
	rooms[player_id] = {"name" : null, "players" : {}, "ai" : {}}
	rooms[player_id]["name"] = room_name
	rooms[player_id]["players"][player_id] = playersIdNameDict[player_id]
	server.room_created.rpc(player_id, room_name)
#	server.return_rooms.rpc(rooms, playersInGame)
	print("creating  room: ", room_name)


func _on_addAi(room_id : int, ai_id : int, ai_name : String):
	var roomName = rooms[room_id]["name"]
	rooms[room_id]["ai"][ai_id] = ai_name
	var playersDict : Dictionary = {}
	playersDict.merge(rooms[room_id]["players"])
	playersDict.merge(rooms[room_id]["ai"])
	for id in rooms[room_id]["players"]:
		server.joined_room.rpc_id(id, room_id, roomName, ai_id, playersDict, true)
	print("added ai to room: ", ai_id, ", ", rooms[room_id])


func _on_removeAi(room_id : int, ai_id : int):
	for id in rooms[room_id]["players"]:
		server.player_left_room.rpc_id(id, ai_id)
	print("leaving room : player_id ", room_id, " ", rooms[room_id]["ai"][ai_id])
	rooms[room_id]["ai"].erase(ai_id)


func _on_joinRoom(room_id : int):
	var player_id = multiplayer.get_remote_sender_id()
	var roomName = rooms[room_id]["name"]
	rooms[room_id]["players"][player_id] = playersIdNameDict[player_id]
	var playersDict : Dictionary = {}
	playersDict.merge(rooms[room_id]["players"])
	playersDict.merge(rooms[room_id]["ai"])
	for id in rooms[room_id]["players"]:
		server.joined_room.rpc_id(id, room_id, roomName, player_id, playersDict, false)
	print("joining room: player_id ", player_id, ", ", rooms[room_id])


func _on_fetchPlayers():
	var player_id = multiplayer.get_remote_sender_id()
	server.return_players.rpc_id(player_id, playersIdNameDict)


func _on_fetchRooms():
	var player_id = multiplayer.get_remote_sender_id()
	server.return_rooms.rpc_id(player_id, rooms, playersInGame)


@rpc("any_peer", "call_local")
func _on_leaveRoom(room_id : int, player_id : int):
#	var player_id = multiplayer.get_remote_sender_id()
	if player_id == room_id:
		server.room_closed.rpc(player_id, rooms[room_id]["name"])
		rooms.erase(room_id)
#		server.return_rooms.rpc(rooms, playersInGame)
		return
	for id in rooms[room_id]["players"]:
		server.player_left_room.rpc_id(id, player_id)
#	print("leaving room : player_id ", room_id, " ", rooms[room_id]["players"][player_id])
	rooms[room_id]["players"].erase(player_id)
	rooms[room_id]["ai"].erase(player_id)
#	server.return_rooms.rpc(rooms, playersInGame)


func _on_requestStartGame(room_id : int):
	var player_id = multiplayer.get_remote_sender_id()
	for id in rooms[player_id]["players"]:
		playersInGame.append(id)
		server.start_game.rpc_id(id, player_id, rooms[player_id]["players"].keys())
		
	server.return_rooms.rpc(rooms, playersInGame)
	print("starting game : ", rooms[player_id]["players"])
