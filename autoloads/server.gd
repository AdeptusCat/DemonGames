extends Node

# Server Signals
signal fetchPlayers
signal fetchRooms
signal playerNameChanged(player_name)
signal joinRoom(room_name)
signal createRoom(room_name)
signal leaveRoom(room_id, player_id)
signal requestStartGame(room_id)
signal returnToLobby
signal requestNameChange(playerId : int, playerName : String)


# Client Signals
signal changePlayerName(playerId : int, playerName : String)

signal updatePlayers(players) # update lobby players
signal updateRooms(rooms, playersInGame)

signal playerJoined(playerName, playerId)
signal playerLeft(playerId)
signal playerLeftRoom(playerId)
signal playerjoinedRoom(room_id, room_name, player_id, playersNameIdDict, is_ai)
signal addAi(room_id, ai_id, ai_name)
signal removeAi(room_id, ai_id)
signal roomClosed(roomId, roomName)
signal roomCreated(roomId, roomName)
signal startGame(room_idm, peers)

# Signals for both


@rpc("call_local")
func player_connected(playerName : String, playerId : int):
	playerJoined.emit(playerName, playerId)


@rpc("call_local")
func player_disconnected(playerId : int):
	playerLeft.emit(playerId)


@rpc("any_peer", "call_local")
func create_room(room_name : String):
	createRoom.emit(room_name)


@rpc("call_local")
func room_created(player_id : int, roomName : String):
	roomCreated.emit(player_id, roomName)


@rpc("call_local")
func room_closed(roomId : int, roomName : String):
	roomClosed.emit(roomId, roomName)


@rpc("any_peer", "call_local")
func join_room(room_id):
	joinRoom.emit(room_id)


@rpc("any_peer", "call_local")
func leave_room(room_id : int, player_id):
	leaveRoom.emit(room_id, player_id)


@rpc("any_peer", "call_local")
func add_ai_to_room(room_id : int, ai_id, ai_name : String):
	addAi.emit(room_id, ai_id, ai_name)


@rpc("any_peer", "call_local")
func remove_ai_from_room(room_id : int, ai_id):
	removeAi.emit(room_id, ai_id)


@rpc("call_local")
func player_left_room(playerId : int):
	playerLeftRoom.emit(playerId)


@rpc("call_local")
func joined_room(room_id : int, room_name : String, player_id : int, playersNameIdDict : Dictionary, is_ai : bool):
	playerjoinedRoom.emit(room_id, room_name, player_id, playersNameIdDict, is_ai)


@rpc("any_peer", "call_local")
func return_to_lobby():
	returnToLobby.emit()


@rpc("any_peer", "call_local")
func fetch_players():
	fetchPlayers.emit()

@rpc("call_local")
func return_players(players : Dictionary):
	updatePlayers.emit(players)


@rpc("any_peer", "call_local")
func fetch_rooms():
	fetchRooms.emit()


@rpc("call_local")
func return_rooms(rooms : Dictionary, playersInGame : Array):
	updateRooms.emit(rooms, playersInGame)


@rpc("any_peer", "call_local")
func request_start_game(room_id : int):
	requestStartGame.emit(room_id)


@rpc("any_peer", "call_local")
func start_game(room_id : int, peers : Array):
	startGame.emit(room_id, peers)


@rpc("any_peer", "call_local")
func request_name_change(player_id : int, player_name : String):
	requestNameChange.emit(player_id, player_name)


@rpc("call_local")
func change_player_name(player_id : int, player_name : String):
	changePlayerName.emit(player_id, player_name)

