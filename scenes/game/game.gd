extends Control

@onready var playersNode = $Players
@onready var rankTrackNode = $RankTrack
@onready var ui = $UI
@onready var map : Map = $Map
@onready var sequence : SequenceOfPlay = $SequenceOfPlay
@onready var debug = $Debug

var turn : int = 1

var playerCount = 1
var rankTrack

signal pickedHits(unitNames)
signal test

var skipHell = false
var skipSouls = false
var skipSummoning = false
var skipAction = false
var skipCombat = false
var skipPetitions = false
var skipEnd = false
var skipUnitPlacing = false
var debugTroops = false
var debugSouls : int = 0
var debugFavors : int = 0
var debugDisfavors : int = 0

var loadSaveGame = false


func _ready():
	randomize()
#	loadSaveGame = true
	Signals.proceed.connect(_on_proceed)
	
	Signals.host.connect(_on_host)
	Signals.join.connect(_on_join)
	Signals.start.connect(_on_start)
	Signals.allPlayersReady.connect(_on_allPlayersReady)
	
	Signals.returnToMainMenu.connect(_on_returnToMainMenu)
	Signals.returnToLobby.connect(_on_returnToLobby)
	Signals.addPlayer.connect(_on_addPlayer)
	Signals.updateTurnTrack.connect(_on_updateTurnTrack)
	
	Save.newSavegame()
	
	#debug 
	Server.playerjoinedRoom.connect(_on_playerjoinedRoom)
	
	skipHell = true
	skipSouls = true
	#skipSummoning = true
	#skipAction = true
#	skipCombat = true
#	skipPetitions = true
#	skipEnd = true

	skipUnitPlacing = true
	#debugTroops = true
#	debugSouls = 100
#	debugFavors = 1
#	debugDisfavors = 1
#
#	Settings.tooltips = false
	Settings.skipScreens = true
#	Settings.skipSoulsSummary = true
#	Settings.skipWaitForPlayers = true
#	Settings.skipPhaseReminder = true

#	canHitLieutenants = false
#	lieutenantBonus = false
	
	if Tutorial.tutorial:
		Settings.tooltips = false
	
	if Connection.usedMenuToStartGame:
		RpcCalls.peerReady.rpc_id(Connection.host)
	
	Signals.potatoPc.emit(Settings.potatoPc)

func saveGame():
	var save_dict = {"game" : {
		"rankTrack" : rankTrackNode.rankTrack,
		"turn" : turn,
		"phase" : Data.phase,
		"worldStates" : {},
	}}
	for aiId in Ai.worldStates:
		save_dict.game.worldStates[aiId] = {}
		for key in Ai.worldStates[aiId]._state:
			save_dict.game.worldStates[aiId][key] = Ai.worldStates[aiId]._state[key]
	return save_dict


func loadGame(savegame : Dictionary):
	# loading from json makes int a float
	var arr : Array = []
	for rank in savegame.rankTrack:
		arr.append(int(rank))
	rankTrackNode.rankTrack = arr
	
	for peer in Connection.peers:
		RpcCalls.updateRankTrack.rpc_id(peer, rankTrackNode.rankTrack)
	
	if savegame.has("turn"):
		for peer in Connection.peers:
			# remember json always stores numbers as float
			RpcCalls.updateTurnTrack.rpc_id(peer, int(savegame.turn))

	if savegame.has("phase"):
		Data.phase = savegame.phase
	
	if savegame.has("worldStates"):
		for oldAiId in savegame.worldStates:
			var newAiId : int = Connection.oldNewIdDict[int(oldAiId)]
			for stateName in savegame.worldStates[oldAiId]:
				Ai.worldStates[newAiId].set_state(stateName, savegame.worldStates[oldAiId][stateName])


func _on_allPlayersReady():
	setup()


func setup():
	var playerIds : Array = Connection.peers.duplicate()
	Signals.phaseReminder.emit("Start Phase")
	
	playerIds = setupAiPlayer(playerIds, Connection.aiPlayersId)
	
	addSpawner(playerIds)
	
	if Save.savegame.size() == 0:
		setupPlayers(playerIds)
		setupSouls()
		setupFavors()
	else:
		setupPlayersFromSavegame(playerIds)
		setupSoulsFromSavegame()
		setupFavorsFromSavegame()
	
	debug.debugFavors()
	debug.debugDisfavors()
	
	setupMouseLights()
	
	if Save.savegame.size() == 0:
		Data.chooseDemon = true
		if not Tutorial.tutorial:
			setupDemons()
			await confirmStartDemon()
		
		if not Tutorial.tutorial:
			setupSectios()
		
		#debug
		debug.debugSectios()
		
		fillAvailableLieutenantsBox()
		
		if not Tutorial.tutorial:
			await setupStartLegions()
		
		for peer in Connection.peers:
			RpcCalls.updateRankTrack.rpc_id(peer, rankTrackNode.rankTrack)
		
		var phase : int = 0
		if Tutorial.tutorial:
			phase = Tutorial.chapter
		
		sequenceOfPlay(phase)
	else:
		Data.chooseDemon = false
		setupDemonsFromSavegame()

		setupSectiosFromSavegame()
		
		setupLegionsFromSavegame()
		setupLieutenantsFromSavegame()
		fillAvailableLieutenantsBox()
		
		setupArcanaCardsFromSavegame()
		
		for peer in Connection.peers:
			RpcCalls.toogleWaitForPlayer.rpc_id(peer, 66, true)
		if not Settings.skipScreens:
			for peer in Connection.peers:
				await Signals.proceedSignal
		for peer in Connection.peers:
			RpcCalls.toogleWaitForPlayer.rpc_id(peer, 66, false)
		
		if Save.savegame.game:
			loadGame(Save.savegame.game)
		sequenceOfPlay(Data.phase)


func setupAiPlayer(playerIds : Array, aiPlayersIds : Array) -> Array:
	for aiPlayerId in aiPlayersIds:
		Ai.playerIds.append(aiPlayerId)
		Ai.addWorldState(aiPlayerId)
		playerIds.append(aiPlayerId)
	return playerIds


func addSpawner(playerIds : Array) -> void:
	for id in playerIds:
		for peer in Connection.peers:
			map.addSpawner.rpc_id(peer, id)


func setupPlayersFromSavegame(playerIds : Array) -> void:
	var colorNamesLeft = Data.colorsNames.duplicate()
	colorNamesLeft.remove_at(0) # remove "Random" color
	colorNamesLeft.shuffle()
	for colorName in Connection.playerIdColorDict.values():
		if colorNamesLeft.has(colorName):
			colorNamesLeft.erase(colorName)
	for id in playerIds:
		var newName = Connection.playerIdInfoDict[id]["playerName"]
		var loadedName = Connection.playerIdInfoDict[id]["loadedPlayerName"]
		var loadedId : int = Connection.playerIdInfoDict[id]["loadedPlayerId"]
		# using the new id as and copy savegame to new id key
		# json keys are always strings
		Connection.oldNewIdDict[loadedId] = id
		Save.savegame.players[id] = Save.savegame.players[str(loadedId)]
		
		for peer in Connection.peers:
			RpcCalls.addPlayer.rpc_id(peer, id)
		var colorName : String = Connection.playerIdColorDict[id]
#		if Connection.playerIdColorDict.has(id):
#			colorName = Connection.playerIdColorDict[id]
#		else:
#			colorName = colorNamesLeft.pop_back()
		if colorName == Data.colorsNames[0]:
			colorName = colorNamesLeft.pop_back()
		for peer in Connection.peers:
			RpcCalls.changeColor.rpc_id(peer, id, colorName)
			RpcCalls.changePlayerName.rpc_id(peer, id, Connection.playerIdNamesDict[id])


func setupPlayers(playerIds : Array) -> void:
	var colorNamesLeft = Data.colorsNames.duplicate()
	colorNamesLeft.remove_at(0) # remove "Random" color
	colorNamesLeft.shuffle()
	for colorName in Connection.playerIdColorDict.values():
		if colorNamesLeft.has(colorName):
			colorNamesLeft.erase(colorName)
	for id in playerIds:
		for peer in Connection.peers:
			RpcCalls.addPlayer.rpc_id(peer, id)
		var colorName : String = Connection.playerIdColorDict[id]
		if colorName == Data.colorsNames[0]:
			colorName = colorNamesLeft.pop_back()
		for peer in Connection.peers:
			RpcCalls.changeColor.rpc_id(peer, id, colorName)
			RpcCalls.changePlayerName.rpc_id(peer, id, Connection.playerIdNamesDict[id])


func setupMouseLights():
	for peer in Connection.peers:
		RpcCalls.initMouseLights.rpc_id(peer)
	
	
func fillAvailableLieutenantsBox():
	for i in range(3):
		var lieutenantName : String = Decks.getRandomCard("lieutenant")
		for peer in Connection.peers:
			RpcCalls.fillAvailableLieutenantsBox.rpc_id(peer, lieutenantName)

func setupSoulsFromSavegame():
	for playerId in Data.players:
		var player = Data.players[playerId]
		Signals.changeSouls.emit(playerId, Save.savegame.players[playerId].souls)
		if playerId == Data.id:
			Signals.changeSoulsInUI.emit(Save.savegame.players[playerId].souls)


func setupSouls():
	for playerId in Data.players:
		var player = Data.players[playerId]
		var souls = player.souls + 10 + debugSouls
		Signals.changeSouls.emit(playerId, souls)
		if playerId == Data.id:
			Signals.changeSoulsInUI.emit(souls)


func setupFavorsFromSavegame():
	for playerId in Data.players:
		var player = Data.players[playerId]
		Signals.changeFavors.emit(playerId, Save.savegame.players[playerId].favors)
		if playerId == Data.id:
			Signals.changeFavorsInUI.emit(Save.savegame.players[playerId].favors)
		Signals.changeDisfavors.emit(playerId, Save.savegame.players[playerId].disfavors)


func setupFavors():
	for playerId in Data.players:
		var player = Data.players[playerId]
		var favors = player.favors + 1
		Signals.changeFavors.emit(playerId, favors)
		if playerId == Data.id:
			Signals.changeFavorsInUI.emit(favors)


func setupDemons():
	for playerId in Data.players:
		for i in range(3):
			var nr : String = Decks.getRandomCard("demon")
			for peer in Connection.peers:
				RpcCalls.addDemon.rpc_id(peer, playerId, nr)


func setupDemonsFromSavegame():
	for playerId in Data.players:
		# 5 demons
		for demonName in Save.savegame.players[playerId].demons:
			# for some reason it tries to load the rank values in int
			# but the array only contains the names of the demons???
			if demonName is String:
				for peer in Connection.peers:
					RpcCalls.addDemon.rpc_id(peer, playerId, demonName + ".tres", Save.savegame.demons[demonName])


func confirmStartDemon() -> void:
	for peer in Connection.peers:
		RpcCalls.toogleWaitForPlayer.rpc_id(peer, 0, true)
	if not Settings.skipScreens:
		for peer in Connection.peers:
			ui.confirmStartDemon.rpc_id(peer)
		for peer in Connection.peers:
			print("waiting for demon")
			await Signals.proceedSignal
	for peer in Connection.peers:
		RpcCalls.toogleWaitForPlayer.rpc_id(peer, 0, false)


func setupSectios():
	var assignedCircles = []
	var assignedQuarters = []
	for playerId in Data.players:
		var quarters = [0, 1, 2, 3, 4]
		quarters.shuffle()
		var playersAssignedCircles = []
		var circles = []
		for nr in range(9):
			circles.append(nr)
		for quarterNr in range(4):
			var quarter = quarters.pop_back()
			var circle = randi_range(0, 8)
			while true:
				var free = true
				for index in assignedCircles.size():
					var assignedCircle = assignedCircles[index]
					var assignedQuarter = assignedQuarters[index]
					if assignedCircle == circle and assignedQuarter == quarter:
						free = false
				if playersAssignedCircles.has(circle):
					free = false
				if free:
					break
				else:
					circle = randi_range(0, 8)
			playersAssignedCircles.append(circle)
			assignedQuarters.append(quarter)
			assignedCircles.append(circle)
			var sectio : Sectio = Decks.sectios[circle][quarter]
			for peer in Connection.peers:
				RpcCalls.occupySectio.rpc_id(peer, playerId, sectio.sectioName)


func setupSectiosFromSavegame():
	for playerId in Data.players:
		for sectioName in Save.savegame.players[playerId].sectios:
			for peer in Connection.peers:
				RpcCalls.occupySectio.rpc_id(peer, playerId, sectioName)


func setupArcanaCardsFromSavegame():
	for playerId in Data.players:
#		# 9 arcana cards
		for cardName in Save.savegame.players[playerId].arcanaCards:
			# remove card from deck
			Decks.getSpecificCard("arcana", cardName)
			for peer in Connection.peers:
				RpcCalls.addArcanaCard.rpc_id(peer, playerId, cardName)
	for peer in Connection.peers:
		#RpcCalls.showArcanaCardsContainer.rpc_id(peer)
		RpcCalls.showStartScreen.rpc_id(peer)


func setupStartLegions():
	if not skipUnitPlacing:
		var playerIds : Array = Connection.peers.duplicate()
		playerIds.append_array(Ai.playerIds.duplicate())
		playerIds.shuffle()
		for playerId in playerIds:
			if playerId > 0:
				playerPlaceStartLegion(playerId)
			else:
				aiPlaceStartLegion(playerId)
		for peer in Connection.peers:
			await map.unitPlacingDone
		
		for peers in Connection.peers:
			RpcCalls.resetUnitsToPlace.rpc_id(peers)
		Signals.placeUnitsFromArray.emit()


func aiPlaceStartLegion(id : int) -> void:
	var bestSectio : Sectio = Ai.getBestStartSectio(id)
	map.placeUnit(bestSectio, id, Data.UnitType.Legion)


func playerPlaceStartLegion(playerId : int) -> void:
	map.placeFirstLegion.rpc_id(playerId)
	for peer in Connection.peers:
		RpcCalls.toogleWaitForPlayer.rpc_id(peer, playerId, true)
	for peer in Connection.peers:
		ui.updateRankTrackCurrentPlayer.rpc_id(peer, playerId)
	map.unitPlacingDone
	for peer in Connection.peers:
		RpcCalls.toogleWaitForPlayer.rpc_id(peer, playerId, false)


func setupLegionsFromSavegame():
	for legion in Save.savegame.legions.values():
#		loadUnit.rpc_id(playerNameIdDict[legion.playerName], legion.occupiedSectio)
		var sectio = Decks.sectioNodes[legion.occupiedSectio]
#		var playerId : int = playerNameIdDict[legion.playerName]
		var playerId : int = Connection.oldNewIdDict[int(legion.triumphirate)]
		map.spawnUnit(sectio.sectioName, legion.unitNr, playerId, Data.UnitType.Legion)
		map.updateTroopInSectio(sectio.sectioName, sectio.troops)
		Signals.incomeChanged.emit(playerId)
		for peer in Connection.peers:
			if not peer == Data.id:
				# skip sending to host if its an AI player
				if not Connection.peers.has(playerId) and peer == Connection.host:
					continue
				map.spawnUnit.rpc_id(peer, sectio.sectioName, legion.unitNr, playerId, Data.UnitType.Legion)
				map.updateTroopInSectio.rpc_id(peer, sectio.sectioName, sectio.troops)


func setupLieutenantsFromSavegame():
	for lieutenant in Save.savegame.lieutenants.values():
		# doesnt need to return the name, for its already known
		# but it needs to be removed from the deck
		Decks.getSpecificCard("lieutenant", lieutenant.unitName)
		# need to pass the new triumphirates ID, not the old one
		var playerId : int = Connection.oldNewIdDict[int(lieutenant.triumphirate)]
		map.spawnUnit(lieutenant.occupiedSectio, lieutenant.unitNr, playerId, Data.UnitType.Lieutenant, lieutenant.unitName)
		var sectio = Decks.sectioNodes[lieutenant.occupiedSectio]
		map.updateTroopInSectio(sectio.sectioName, sectio.troops)
#		var playerId : int = playerNameIdDict[lieutenant.playerName]
		
		Signals.incomeChanged.emit(playerId)
		for peer in Connection.peers:
			if not peer == Data.id:
				# skip sending to host if its an AI player
				if not Connection.peers.has(playerId) and peer == Connection.host:
					continue
				map.spawnUnit.rpc_id(peer, lieutenant.occupiedSectio, lieutenant.unitNr, playerId, Data.UnitType.Lieutenant, lieutenant.unitName)
				map.updateTroopInSectio.rpc_id(peer, sectio.sectioName, sectio.troops)


func sequenceOfPlay(phase : int = 0):
	if debugTroops:
		for playerId in Data.players.keys():
			if Connection.peers.has(playerId):
				debug.spawnDebugTroops1.rpc_id(playerId)
				await get_tree().create_timer(0.5).timeout
			else:
				debug.spawnDebugTroops1(playerId)
	
	if Tutorial.tutorial and Tutorial.chapter == Tutorial.Chapter.Introduction:
		await Tutorial.introduction()
	
	await get_tree().create_timer(0.1).timeout
	for peer in Connection.peers:
		RpcCalls.updatePhaseLabel.rpc_id(peer, phase, Data.phases.keys()[phase])
	await get_tree().create_timer(0.1).timeout
	
	while(true):
		#for peer in Connection.peers:
			#RpcCalls.showArcanaCardsContainer.rpc_id(peer)
		
		print("hell phase ",phase, " ", Data.phases.Hell)
		if phase == Data.phases.Hell and not skipHell:
			await $Hell.phase()
		
		phase = await nextPhase(phase, Data.phases.Hell)
		
		print("soul phase ",phase, " ", Data.phases.Soul)
		if phase == Data.phases.Soul and not skipSouls:
			await $Soul.phase(ui)
		
		phase = await nextPhase(phase, Data.phases.Soul)
		
		print("Summoning phase ",phase, " ", Data.phases.Summoning)
		if phase == Data.phases.Summoning and not skipSummoning:
			await $Summoning.phase(phase, ui)
		
		phase = await nextPhase(phase, Data.phases.Summoning)
		
		print("Action phase ",phase, " ", Data.phases.Action)
		for peer in Connection.peers:
			RpcCalls.showRankTrackMarginContainer.rpc_id(peer)
		if phase == Data.phases.Action and not skipAction:
			var rankTrack : Array = rankTrackNode.rankTrack.duplicate()
			await $Action.phase(phase, rankTrack, ui, map, rankTrackNode)
#
		phase = await nextPhase(phase, Data.phases.Action)
		for peer in Connection.peers:
			RpcCalls.combatPhase.rpc_id(peer)
		
		print("Combat phase ",phase, " ", Data.phases.Combat)
		$Combat.combatWinner.clear()
		if phase == Data.phases.Combat and not skipCombat:
			if Tutorial.tutorial:
				rankTrack = await Tutorial.combat(rankTrackNode)
				# otherwise the "On Earth" Demon doesnt get his Label
				for peer in Connection.peers:
					RpcCalls.combatPhase.rpc_id(peer)
			await $Combat.phase(map)
		for peer in Connection.peers:
			RpcCalls.combatOver.rpc_id(peer)
			
		phase = await nextPhase(phase, Data.phases.Combat)
		
		print("Petitions phase ",phase, " ", Data.phases.Petitions)
		if phase == Data.phases.Petitions and not skipPetitions:
			await $Petition.phase($Combat.combatWinner, ui)
			
		phase = await nextPhase(phase, Data.phases.Petitions)
		
		print("End phase ",phase, " ", Data.phases.Petitions)
		if phase == Data.phases.End and not skipEnd:
			if $End.phase():
				break
			
		phase = Data.nextPhase()
		for peer in Connection.peers:
			RpcCalls.updatePhaseLabel.rpc_id(peer, phase, Data.phases.keys()[phase])
		await get_tree().create_timer(0.1).timeout
		
		# save game after each round
		turn += 1
		for peer in Connection.peers:
			RpcCalls.updateTurnTrack.rpc_id(peer, turn)
		Save.saveGame()


func nextPhase(currentPhase, expectedPhase):
	if currentPhase == expectedPhase:
		currentPhase = Data.nextPhase()
	for peer in Connection.peers:
		RpcCalls.updatePhaseLabel.rpc_id(peer, currentPhase, Data.phases.keys()[currentPhase])
	await get_tree().create_timer(0.1).timeout
	Save.saveGame()
	return currentPhase


func _on_host():
	Main.StartServer()
	
	Connection.connectToServer()
	await get_tree().create_timer(0.5).timeout
	
	Server.create_room.rpc_id(1, "Debug")
	Connection.host = Data.id
	
	await get_tree().create_timer(0.5).timeout
	RpcCalls.peerReady.rpc_id(Connection.host)


func peer_connected(id):
	playerCount += 1
	Connection.peers.append(id)
	if Connection.peers.size() >= 2:
		await get_tree().create_timer(0.5).timeout
		_on_start()


func _on_join():
	Connection.connectToServer()
	await get_tree().create_timer(0.5).timeout
	
	Server.join_room.rpc_id(1, "Debug")
	
	await get_tree().create_timer(0.5).timeout
	RpcCalls.peerReady.rpc_id(Connection.host)


func _on_playerjoinedRoom(roomId : int, room_name : String, player_id : int, playersIdNameDict : Dictionary):
	Connection.host = roomId
	var peers : Array[int]
	for peer in playersIdNameDict.keys():
		peers.append(int(peer))
	
	Connection.peers = peers
	if roomId == Data.id:
		if Connection.peers.size() >= 2:
			await get_tree().create_timer(0.5).timeout
			_on_start()


func _on_start():
	Server.request_start_game.rpc_id(1, Data.id)


func _on_proceed():
	Data.chooseDemon = false
	RpcCalls.proceed.rpc_id(Connection.host)


func _on_returnToMainMenu():
	Signals.resetGame.emit()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


func _on_returnToLobby():
	Server.return_to_lobby.rpc_id(1)
	Signals.resetGame.emit()
	get_tree().change_scene_to_file("res://scenes/ui/lobby.tscn")


func _on_addPlayer(playerScene : Player):
	playersNode.add_child(playerScene)


func _on_updateTurnTrack(_turn : int):
	turn = _turn


# cheats
func _input(event):
	return
	if Input.is_action_just_pressed("right_click"):
		for peer in Connection.peers:
			RpcCalls.addArcanaCard.rpc_id(peer, Data.id, "Blood Money")
