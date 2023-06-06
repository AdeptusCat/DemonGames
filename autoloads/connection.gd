extends Node

var network = ENetMultiplayerPeer.new()

var port = 1920

var host
var peers : Array = []
var aiPlayersId : Array = []
var connected : bool = false
var playersReady : Array = []
var playerIdNamesDict : Dictionary = {}
var dedicatedServer : bool = false
var usedMenuToStartGame : bool = false
var NewPlayerNamesDictToloadedPlayerNames : Dictionary = {}
var playerNamesIdDict : Dictionary = {}
var playerIdColorDict : Dictionary = {}

# loading player data
var playerIdInfoDict : Dictionary = {}
var oldNewIdDict : Dictionary = {}

var playerName = ""
var serverTree

var local = true


func _ready():
	Signals.resetGame.connect(_on_resetGame)
	Signals.returnToMainMenu.connect(_on_returnToMainMenu)


func isAiPlayer(playerId) -> bool:
	if playerId < 0:
		return true
	else:
		return false


func sendToPeers(function : Callable):
	for peer in Connection.peers:
		function.rpc_id(peer)


func _on_returnToMainMenu():
	network.close()


func join():
	Connection.network.create_client("localhost", Connection.port)
	multiplayer.multiplayer_peer = Connection.network
	Data.id = multiplayer.get_unique_id()


func _on_resetGame():
	host = null
	peers.clear()
	aiPlayersId.clear()
	connected = false
	playersReady.clear()
	playerIdNamesDict.clear()
	dedicatedServer = false
	usedMenuToStartGame = false
	NewPlayerNamesDictToloadedPlayerNames.clear()
	playerNamesIdDict.clear()
	playerIdColorDict.clear()

func playerReady(playerId : int):
	playersReady.append(playerId)
	
	print("ready ", playersReady.size(), " ",peers.size())
	if playersReady.size() == peers.size():
		Signals.allPlayersReady.emit()


func connectToServer():
	if connected:
		return
	if local:
		network.create_client("localhost", port)
	else:
		network.create_client("adeptuscat.ddns.net", port)
	multiplayer.multiplayer_peer = network
	Data.id = multiplayer.get_unique_id()
	print("client started ", Data.id)
#	network.peer_connected.connect(func(id): peer_connected(id))
#	network.peer_disconnected.connect(func(id): peer_disconnected(id))
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.connected_to_server.connect(_on_connection_succeeded)
#	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _on_connection_failed():
	connected = false
	print("connection failed")


func _on_connection_succeeded():
	connected = true
#	Server.fetch_players.rpc_id(Connection.host)
#	Server.fetch_rooms.rpc_id(Connection.host)

func closeConnection():
	multiplayer.connection_failed.disconnect(_on_connection_failed)
	multiplayer.connected_to_server.disconnect(_on_connection_succeeded)
	network.close()
	connected = false
	


func return_players(s_players):
	Signals.updatePlayers.emit(s_players)


func startLocalServer():
	
#	serverTree = SceneTree.new()
#	serverTree.init()
#	serverTree.get_root().set_update_mode(SubViewport.UPDATE_DISABLED)

#	serverTree.multiplayer_poll = true
	# add the server scene (it needs to have the same name 
	# as the singleton which handles the client connection)
#	serverTree.change_scene_to_file("res://server/main.tscn")
	
	var i = 0
	for ip in IP.get_local_addresses():
		print(ip)
		
	
#func _physics_process(delta):
#	if serverTree:
#		serverTree.iteration(delta)

#func _process(delta):
#	if serverTree:
#		serverTree.idle(delta)

func exitTree():
	if serverTree:
		serverTree.finish()
