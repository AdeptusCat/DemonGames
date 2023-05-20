extends Control

@onready var playersNode = $Players
@onready var rankTrackNode = $RankTrack
@onready var ui = $UI
@onready var actionsNode = $UI/Control/PlayerStatusMarginContainer/MarginContainer/VBoxContainer/Actions
@onready var map =$Map
@onready var sequence : SequenceOfPlay = $SequenceOfPlay

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

var loadSaveGame = false



func _ready():
	randomize()
#	loadSaveGame = true
	Signals.proceed.connect(_on_proceed)
	Signals.tamingHellhound.connect(_on_taming_hellhound)
	Signals.petitionApproved.connect(_on_petition_approved)
	Signals.petitionsDone.connect(_on_peititonsDone)
	Signals.noDemonPicked.connect(_on_no_demon_picked)
	Signals.demonStatusChange.connect(_on_demon_status_change)
	Signals.removeLieutenantFromAvailableLieutenantsBox.connect(_on_removeLieutenantFromAvailableLieutenantsBox)
	Signals.pickedDemon.connect(_on_picked_demon)
	Signals.recruitLieutenant.connect(_on_recruit_lieutenant)
	Signals.recruitLegions.connect(_on_recruit_legions)
	Signals.host.connect(_on_host)
	Signals.join.connect(_on_join)
	Signals.start.connect(_on_start)
	Signals.phaseDone.connect(_on_phase_done)
	Signals.demonDoneWithPhase.connect(_on_demon_done_with_phase)
	Signals.buyArcanaCard.connect(_on_buyArcanaCard)
	Signals.allPlayersReady.connect(_on_allPlayersReady)
	Signals.recruitingDone.connect(_on_recruitingDone)
	Signals.recruiting.connect(_on_recruiting)
	Signals.incomeChanged.connect(_on_incomeChanged)
	Signals.returnToMainMenu.connect(_on_returnToMainMenu)
	Signals.returnToLobby.connect(_on_returnToLobby)
	Signals.addPlayer.connect(_on_addPlayer)
	Signals.updateTurnTrack.connect(_on_updateTurnTrack)
	
	Save.newSavegame()
	
	#debug 
	Server.playerjoinedRoom.connect(_on_playerjoinedRoom)
#	skipHell = true
#	skipSouls = true
#	skipSummoning = true
#	skipAction = true
#	skipCombat = true
#	skipPetitions = true
#	skipEnd = true

	skipUnitPlacing = true
#	debugTroops = true
#
#	Settings.tooltips = false
#	Settings.skipScreens = true
#	Settings.skipSoulsSummary = true
#	Settings.skipWaitForPlayers = true
#	Settings.skipPhaseReminder = true

#	canHitLieutenants = false
#	lieutenantBonus = false
	
	if Tutorial.tutorial:
		Settings.tooltips = false
	
	if Connection.usedMenuToStartGame:
		RpcCalls.peerReady.rpc_id(Connection.host)
		ui.start()


func _on_allPlayersReady():
	for peer in Connection.peers:
		for _peer in Connection.peers:
			map.addSpawner.rpc_id(_peer, peer)
	if Save.savegame.size() > 0:
		setupSaveGame(Connection.peers, Connection.aiPlayersId)
	else:
		setup(Connection.peers, Connection.aiPlayersId)


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
	# loading fromt json makes int a float
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
		print("load world states ", savegame.worldStates)
		for oldAiId in savegame.worldStates:
			var newAiId : int = Connection.oldNewIdDict[int(oldAiId)]
			for stateName in savegame.worldStates[oldAiId]:
				Ai.worldStates[newAiId].set_state(stateName, savegame.worldStates[oldAiId][stateName])

# bugs
# fleeing from combat cancels the next combat? happened once


func debugSectios():
	return
	for peer in Connection.peers:
#		occupySectio.rpc_id(peer, Ai.playerIds[0], "The Wise Men")
		RpcCalls.occupySectio.rpc_id(peer, Data.id, "The Wise Men")
	#	occupySectio.rpc_id(peer, 1, "Thieves")
	#	occupySectio.rpc_id(peer, 1, "The Envious")
	#	occupySectio.rpc_id(peer, 1, "Sugar Hill")

	#	occupySectio.rpc_id(peer, 1, "Sugar Hill")
	#	occupySectio.rpc_id(peer, 1, "Addiction")
	#	occupySectio.rpc_id(peer, 1, "Sea Of Lard")
	#	occupySectio.rpc_id(peer, 1, "The Insatiable")
	#	occupySectio.rpc_id(peer, 1, "Tavern Of Endless Revelry")



@rpc("any_peer", "call_local")
func spawnDebugTroops1(ai : int = 0):
	var sectio
	if Connection.dedicatedServer:
		return
	if not ai == 0:
		sectio = Decks.sectioNodes["Megalomaniacs"]
		sectio = Decks.sectioNodes["Bad People"]
		map.placeUnit(sectio, ai, Data.UnitType.Legion)
		map.placeUnit(sectio, ai, Data.UnitType.Legion)
		map.placeUnit(sectio, ai, Data.UnitType.Legion)
		map.placeUnit(sectio, ai, Data.UnitType.Legion)
		map.placeUnit(sectio, ai, Data.UnitType.Legion)
		return
#	return
#	if Data.id == 1:
	if Data.player.playerName == "Player 1":
		sectio = Decks.sectioNodes["Bad People"]
		map.placeUnit(sectio, Data.id, Data.UnitType.Lieutenant, "Shalmaneser")
		map.placeUnit(sectio, Data.id, Data.UnitType.Legion)
#		map.placeUnit(sectio, Data.id, Data.UnitType.Legion)
#		map.placeUnit(sectio, Data.id, Data.UnitType.Legion)
#		map.placeUnit(sectio, Data.id, Data.UnitType.Legion)
		
		
#		await get_tree().create_timer(1.0).timeout
#		map.recruitLieutenant = true
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map.recruitLieutenant = true
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map.recruitLieutenant = true
#		map._on_sectioClicked(Decks.sectioNodes["Basement Of Wanton Killers"])
#		map._on_sectioClicked(Decks.sectioNodes["Basement Of Wanton Killers"])
#		map._on_sectioClicked(Decks.sectioNodes["Basement Of Wanton Killers"])
#		map._on_sectioClicked(Decks.sectioNodes["Sowers Of Scandal"])
#		map._on_sectioClicked(Decks.sectioNodes["Dogs Of War"])
#		map._on_sectioClicked(Decks.sectioNodes["Megalomaniacs"])
#		map._on_sectioClicked(Decks.sectioNodes["Spies"])
	
	else:
		sectio = Decks.sectioNodes["Megalomaniacs"]
		sectio = Decks.sectioNodes["Bad People"]
		map.placeUnit(sectio, Data.UnitType.Legion)
		map.placeUnit(sectio, Data.UnitType.Legion)
		map.placeUnit(sectio, Data.UnitType.Legion)
		map.placeUnit(sectio, Data.UnitType.Legion)
		map.placeUnit(sectio, Data.UnitType.Legion)
		
#
#		sectio = Decks.sectioNodes["Basement Of Wanton Killers"]
#		map.placeUnit(sectio, Data.UnitType.Legion)
#		sectio = Decks.sectioNodes["Dogs Of War"]
#		map.placeUnit(sectio, Data.UnitType.Legion)
#		sectio = Decks.sectioNodes["Sowers Of Scandal"]
#		map.placeUnit(sectio, Data.UnitType.Legion)
		
#		sectio = Decks.sectioNodes["Bad People"]
#		map.placeUnit(sectio, Data.UnitType.Lieutenant)
#		map.placeUnit(sectio, Data.UnitType.Legion)
#		map.placeUnit(sectio, Data.UnitType.Legion)
#		map.placeUnit(sectio, Data.UnitType.Legion)
#		map.placeUnit(sectio, Data.UnitType.Legion)
#		map.recruitLieutenant = true
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map.recruitLieutenant = true
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map.recruitLieutenant = true
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map.recruitLieutenant = true
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map.recruitLieutenant = true
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map.recruitLieutenant = true
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map.recruitLieutenant = true
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map._on_sectioClicked(Decks.sectioNodes["Basement Of Wanton Killers"])
#		map._on_sectioClicked(Decks.sectioNodes["Basement Of Wanton Killers"])
#		map._on_sectioClicked(Decks.sectioNodes["Basement Of Wanton Killers"])
		
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#
		map._on_sectioClicked(Decks.sectioNodes["Liars"])
#		map._on_sectioClicked(Decks.sectioNodes["Spies"])
#		map._on_sectioClicked(Decks.sectioNodes["Traitors"])
	return
	map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#	map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#	map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#	map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#	map._on_sectioClicked(Decks.sectioNodes["Bad People"])
	map.recruitLieutenant = true
	map._on_sectioClicked(Decks.sectioNodes["Bad People"])
	map.recruitLieutenant = true
	map._on_sectioClicked(Decks.sectioNodes["Bad People"])
	map.recruitLieutenant = true
	map._on_sectioClicked(Decks.sectioNodes["Bad People"])
	map.recruitLieutenant = true
	map._on_sectioClicked(Decks.sectioNodes["Bad People"])


func setupSaveGame(_playerIds : Array, _aiPlayersIds : Array):
	var playerIds : Array = _playerIds.duplicate()
	Signals.phaseReminder.emit("Start Phase")
	
	for aiPlayerId in _aiPlayersIds:
		Ai.playerIds.append(aiPlayerId)
		Ai.addWorldState(aiPlayerId)
#		var aiId = Ai.addAiPlayer()
		playerIds.append(aiPlayerId)
		print("setup player ", aiPlayerId, playerIds)
	
	for id in Ai.playerIds:
		for _peer in Connection.peers:
			map.addSpawner.rpc_id(_peer, id)
	
	var playerNameIdDict = {}
#	for playerId in playerIds:
#		print("start phase ",Connection.playerIdNamesDict)
#		var newName = Connection.playerIdInfoDict[playerId]["playerName"]
#		var loadedName = Connection.playerIdInfoDict[playerId]["loadedPlayerName"]
#		var loadedId = Connection.playerIdInfoDict[playerId]["loadedPlayerId"]
#		Save.savegame.players[newName] = Save.savegame.players[loadedName]
#		print(newName, " ", loadedName, " ", Save.savegame.players)
#		for peer in Connection.peers:
#			addPlayer.rpc_id(peer, playerId, Save.savegame.players[newName])
#			changeColor.rpc_id(peer, playerId, Save.savegame.players[loadedName].colorName)
#			changePlayerName.rpc_id(peer, playerId, newName)
#		playerNameIdDict[newName] = playerId
#		playerNameIdDict[loadedName] = playerId
#		Save.savegame.players[playerId] = Save.savegame.players[loadedName]
	
	
	
		
#	var playerCount = 1
	
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
		playerNameIdDict[newName] = id
		playerNameIdDict[loadedName] = id
		
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
	
	for peer in Connection.peers:
		RpcCalls.initMouseLights.rpc_id(peer)
	
	for playerId in Data.players:
		var player = Data.players[playerId]
#		# 4 legions and souls/favors
		print("setup load")
		Signals.changeSouls.emit(playerId, Save.savegame.players[playerId].souls)
		Signals.changeFavors.emit(playerId, Save.savegame.players[playerId].favors)
		Signals.changeDisfavors.emit(playerId, Save.savegame.players[playerId].disfavors)
	
	for playerId in Data.players:
		# 5 demons
		for demonName in Save.savegame.players[playerId].demons:
			# for some reason it tries to load the rank values in int
			# but the array only contains the names of the demons???
			if demonName is String:
				for peer in Connection.peers:
					RpcCalls.addDemon.rpc_id(peer, playerId, demonName + ".tres", Save.savegame.demons[demonName])
	
	for playerId in Data.players:
		for sectioName in Save.savegame.players[playerId].sectios:
			for peer in Connection.peers:
				RpcCalls.occupySectio.rpc_id(peer, playerId, sectioName)
	
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
				print("spawning unit for ", playerId, " sending to ",peer)
				map.spawnUnit.rpc_id(peer, sectio.sectioName, legion.unitNr, playerId, Data.UnitType.Legion)
				map.updateTroopInSectio.rpc_id(peer, sectio.sectioName, sectio.troops)
	
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
		# old
#		for peer in Connection.peers:
#			map.spawnLieutenant.rpc_id(peer, lieutenant.occupiedSectio, lieutenant.unitNr, lieutenant.unitName, playerNameIdDict[lieutenant.playerName])
	
	# fill Lieutenants Box after spawning the players Lieutenants
	for i in range(3):
		var lieutenantName = Decks.getRandomCard("lieutenant")
		# might be null if there are no Lieutenants left
		if lieutenantName:
			for peer in Connection.peers:
				RpcCalls.fillAvailableLieutenantsBox.rpc_id(peer, lieutenantName)
		
	for playerId in Data.players:
#		# 9 arcana cards
		for cardName in Save.savegame.players[playerId].arcanaCards:
			# remove card from deck
			Decks.getSpecificCard("arcana", cardName)
			for peer in Connection.peers:
				RpcCalls.addArcanaCard.rpc_id(peer, playerId, cardName)
	for peer in Connection.peers:
		RpcCalls.showArcanaCardsContainer.rpc_id(peer, )
		RpcCalls.showStartScreen.rpc_id(peer, )

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


func setup(_playerIds : Array, _aiPlayersIds : Array):
	var playerIds : Array = _playerIds.duplicate()
	Signals.phaseReminder.emit("Start Phase")
	
	for aiPlayerId in _aiPlayersIds:
		Ai.playerIds.append(aiPlayerId)
		Ai.addWorldState(aiPlayerId)
#		var aiId = Ai.addAiPlayer()
		playerIds.append(aiPlayerId)
		print("setup player ", aiPlayerId, playerIds)
	
	for id in Ai.playerIds:
		for _peer in Connection.peers:
			map.addSpawner.rpc_id(_peer, id)
	
#	var playerCount = 1
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
#		if Connection.playerIdColorDict.has(id):
#			colorName = Connection.playerIdColorDict[id]
#		else:
#			colorName = colorNamesLeft.pop_back()
		if colorName == Data.colorsNames[0]:
			colorName = colorNamesLeft.pop_back()
		for peer in Connection.peers:
			RpcCalls.changeColor.rpc_id(peer, id, colorName)
			RpcCalls.changePlayerName.rpc_id(peer, id, Connection.playerIdNamesDict[id])
	
	for peer in Connection.peers:
		RpcCalls.initMouseLights.rpc_id(peer)
	
	for i in range(3):
		var lieutenantName : String = Decks.getRandomCard("lieutenant")
		for peer in Connection.peers:
			RpcCalls.fillAvailableLieutenantsBox.rpc_id(peer, lieutenantName)
	
	for playerId in Data.players:
		var player = Data.players[playerId]
#		# 4 legions and souls/favors		
#		player.souls = player.souls + 10add
#		player.favors = player.favors + 1
		print("setup ", playerId, " ", player.souls)
		var souls = player.souls + 10
		var favors = player.favors + 1
		Signals.changeSouls.emit(playerId, souls)
		Signals.changeFavors.emit(playerId, favors)
	
	if not Tutorial.tutorial:
		for playerId in Data.players:
			# 5 demonsactionPhase(
			for i in range(3):
				var nr : String = Decks.getRandomCard("demon")
				print("demon ",nr)
				
				for peer in Connection.peers:
					RpcCalls.addDemon.rpc_id(peer, playerId, nr)
	
	
		for peer in Connection.peers:
			RpcCalls.toogleWaitForPlayer.rpc_id(peer, 0, true)
		if not Settings.skipScreens:
			for peer in Connection.peers:
				ui.confirmStartDemon.rpc_id(peer)
			for peer in Connection.peers:
				print("waiting for peer")
				await Signals.proceedSignal
		for peer in Connection.peers:
			RpcCalls.toogleWaitForPlayer.rpc_id(peer, 0, false)
	#		# 6 arrange the Rank Track
#

		#debug
		debugSectios()

		
		var assignedCircles = []
		var assignedQuarters = []
		for playerId in Data.players:
	#		# 7 sectios
	#		for i in range(4):
	#			var sectio = Decks.getRandomCard("sectio")
	#			occupySectio.rpc_id(peer, playerId, sectio)
			
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

		# debug
#		if playerId == 1:
#			for i in range(Decks.sectioCards.size()-3):
#				var sectio = Decks.getRandomCard("sectio")
#				occupySectio.rpc_id(peer, playerId, sectio)
#		else:
#			for i in range(3):
#				var sectio = Decks.getRandomCard("sectio")
#				occupySectio.rpc_id(peer, playerId, sectio)
		
	if not Tutorial.tutorial:
		for id in Ai.playerIds:
			var bestSectio : Sectio = Ai.getBestStartSectio(id)
			map.placeUnit(bestSectio, id, Data.UnitType.Legion)

	
	print("place units ", Connection.peers)
	if not Tutorial.tutorial:
		if not skipUnitPlacing:
			var peers : Array = Connection.peers.duplicate()
			peers.shuffle()
			for playerId in peers:
				# 8 place one legion
				map.placeFirstLegion.rpc_id(playerId)
				for peer in peers:
					RpcCalls.toogleWaitForPlayer.rpc_id(peer, playerId, true)
				for peer in Connection.peers:
					ui.updateRankTrackCurrentPlayer.rpc_id(peer, playerId)
				await map.unitPlacingDone
				for peer in peers:
					RpcCalls.toogleWaitForPlayer.rpc_id(peer, playerId, false)
		
#	return
		# debug
#		map._on_sectioClicked(Decks.sectioNodes[player.sectios[0]])
	
	for peer in Connection.peers:
		RpcCalls.updateRankTrack.rpc_id(peer, rankTrackNode.rankTrack)
	
	var phase : int = 0
	match Tutorial.chapter:
		Tutorial.Chapter.Introduction:
			phase = 0
		Tutorial.Chapter.Soul:
			phase = 1
		Tutorial.Chapter.Summoning:
			phase = 2
		Tutorial.Chapter.Actions:
			phase = 3
		Tutorial.Chapter.Combat:
			phase = 4
		Tutorial.Chapter.Petitions:
			phase = 5
		
	sequenceOfPlay(phase)



func _on_incomeChanged(playerId : int):
	var player = Data.players[playerId]
	player.changeIncome()


func sequenceOfPlay(phase : int = 0):
	if debugTroops:
		for playerId in Data.players.keys():
			if Connection.peers.has(playerId):
				spawnDebugTroops1.rpc_id(playerId)
				await get_tree().create_timer(0.5).timeout
			else:
				spawnDebugTroops1(playerId)
	
	if Tutorial.tutorial and Tutorial.chapter == Tutorial.Chapter.Introduction:
		Signals.tutorial.emit(Tutorial.Topic.Introduction, 
			"Demon Games is a game of power-struggle and intrigue among the Demons 
			of Hell. The players each assume the role of a group of Demons thirsty for 
			power and influence and the winner is the first player to claim control of one 
			of Hell's Circles.")
		await Signals.tutorialRead
		
		Signals.tutorial.emit(Tutorial.Topic.Introduction, 
			"The map shows Hell and its vicinity. \n
			Hell itself is divided in nine concentric Circles and is surrounded by the AnteHell. \n
			Each Circle is named after the predominant kind of sinners it cares for and is in
			turn divided into five Sectio, each named after the special kind of sinners the
			Sectio contains.")
		await Signals.tutorialRead
		
		var sectio : Sectio = Decks.sectioNodes["Megalomaniacs"]
		for peer in Connection.peers:
			RpcCalls.occupySectio.rpc_id(peer, Data.id, sectio.sectioName)
		
		for peer in Connection.peers:
			RpcCalls.moveCamera.rpc_id(peer, sectio.global_position)
		await Signals.doneMoving
		
		Signals.tutorial.emit(Tutorial.Topic.Introduction, 
			"Sectio are the sections into which each of Hell’s Circles are divided, and
			since control of these in turn leads to control of Hell’s Circles, \nthey are the
			battleground upon which the struggle for control of Hell is waged. \nEach
			Sectio has the follow ing information printed in it")
		await Signals.tutorialRead
		
		Signals.tutorial.emit(Tutorial.Topic.Introduction, 
			"The number in the circle indicates the amount of souls that the Sectio produces each Soul Phase. \n
			The color of the Sectio shows the owner.")
		await Signals.tutorialRead
		
		for peer in Connection.peers:
			RpcCalls.moveCamera.rpc_id(peer, Vector2(-1500,-1500))
		await Signals.doneMoving
		
		Signals.tutorial.emit(Tutorial.Topic.Introduction, 
			"AnteHell (“Ante” as in “before”) is the name of the wastelands surrounding
			Hell. \nLost Souls, odd incorporeal beings and a few stray Daemons populate
			it. \nOne of the few reasons to visit AnteHell is that you can find and tame the
			fearsome Hellhounds there.")
		await Signals.tutorialRead
		
		for peer in Connection.peers:
			RpcCalls.resetCamera.rpc_id(peer)
		await Signals.doneMoving
		
		Signals.tutorial.emit(Tutorial.Topic.Introduction, 
			"The five-pointed star, the Pentagram, in the centre of Hell marks the location
			of the Infernal Court. It may not be entered.")
		await Signals.tutorialRead
		
		Signals.tutorial.emit(Tutorial.Topic.PlayersTree, 
			"On the left you can observe your and other players stats. \n
			Next to the name of the players are the amount of Souls the player has. \n
			Souls are the 'currency' of the game and are used to pay for raising Legions, empowering magic and so on. \n
			The Income of souls per turn depend on Demons on Earth, occupied Sectios and the upkeep you have to pay for your Units. \n
			Players receive Favors/Disfavors when they do things that are regarded by Lucifer as particularly good/amusing or bad/tasteless.")
		await Signals.tutorialRead
		
		await get_tree().create_timer(0.1).timeout
		Signals.returnToMainMenu.emit()
		await Signals.tutorialRead
		
		
		
		
	await get_tree().create_timer(0.1).timeout
	for peer in Connection.peers:
		RpcCalls.updatePhaseLabel.rpc_id(peer, phase, Data.phases.keys()[phase])
	await get_tree().create_timer(0.1).timeout
#	var phase = null
	while(true):
		# hell phase
#		phase = Data.phases.Hell
#		if phase == 0:
#			phase = Data.nextPhase()
		for peer in Connection.peers:
				RpcCalls.showArcanaCardsContainer.rpc_id(peer)
		print("hell phase ",phase, " ", Data.phases.Hell)
		if phase == Data.phases.Hell and not skipHell:
			await sequence.hellPhase()
		
		if phase == Data.phases.Hell:
			phase = Data.nextPhase()
		for peer in Connection.peers:
			RpcCalls.updatePhaseLabel.rpc_id(peer, phase, Data.phases.keys()[phase])
		await get_tree().create_timer(0.1).timeout
		Save.saveGame()
		
		print("soul phase ",phase, " ", Data.phases.Soul)
		if phase == Data.phases.Soul and not skipSouls:
			await sequence.soulPhase(ui)
		
		if phase == Data.phases.Soul:
			phase = Data.nextPhase()
		for peer in Connection.peers:
			RpcCalls.updatePhaseLabel.rpc_id(peer, phase, Data.phases.keys()[phase])
		await get_tree().create_timer(0.1).timeout
		Save.saveGame()
		
#		spawnDebugTroops.rpc_id(peer, )
		print("Summoning phase ",phase, " ", Data.phases.Summoning)
		for peer in Connection.peers:
			RpcCalls.showPlayerStatusMarginContainer.rpc_id(peer)
		if phase == Data.phases.Summoning and not skipSummoning:
			await sequence.summoningPhase(phase, ui)
		
		if phase == Data.phases.Summoning:
			phase = Data.nextPhase()
		for peer in Connection.peers:
			RpcCalls.updatePhaseLabel.rpc_id(peer, phase, Data.phases.keys()[phase])
		await get_tree().create_timer(0.1).timeout
		Save.saveGame()
		
		print("Action phase ",phase, " ", Data.phases.Action)
		for peer in Connection.peers:
			RpcCalls.showRankTrackMarginContainer.rpc_id(peer)
		if phase == Data.phases.Action and not skipAction:
			var rankTrack : Array = rankTrackNode.rankTrack.duplicate()
			await sequence.actionPhase(phase, rankTrack, ui, map, rankTrackNode)
#
		if phase == Data.phases.Action:
			phase = Data.nextPhase()
		for peer in Connection.peers:
			RpcCalls.updatePhaseLabel.rpc_id(peer, phase, Data.phases.keys()[phase])
			RpcCalls.combatPhase.rpc_id(peer)
		await get_tree().create_timer(0.1).timeout
		Save.saveGame()
		
		print("Combat phase ",phase, " ", Data.phases.Combat)
		sequence.combatWinner = {}
		if phase == Data.phases.Combat and not skipCombat:
			if Tutorial.tutorial:
				for playerId in Data.players:
					if playerId == Data.id:
						Signals.spawnUnit.emit("Megalomaniacs", playerId, Data.UnitType.Lieutenant, "Dabriel")
						Signals.spawnUnit.emit("Megalomaniacs", playerId, Data.UnitType.Legion)
						Signals.spawnUnit.emit("Megalomaniacs", playerId, Data.UnitType.Legion)
						Signals.spawnUnit.emit("Megalomaniacs", playerId, Data.UnitType.Legion)
						
						Signals.spawnUnit.emit("Bad People", playerId, Data.UnitType.Legion)
						Signals.spawnUnit.emit("Bad People", playerId, Data.UnitType.Legion)
						Signals.spawnUnit.emit("Bad People", playerId, Data.UnitType.Legion)
						Signals.spawnUnit.emit("Bad People", playerId, Data.UnitType.Legion)
						
					else:
						Signals.spawnUnit.emit("Megalomaniacs", playerId, Data.UnitType.Legion)
						Signals.spawnUnit.emit("Megalomaniacs", playerId, Data.UnitType.Legion)
						Signals.spawnUnit.emit("Megalomaniacs", playerId, Data.UnitType.Legion)
						Signals.spawnUnit.emit("Megalomaniacs", playerId, Data.UnitType.Legion)
						Signals.spawnUnit.emit("Megalomaniacs", playerId, Data.UnitType.Legion)
						
						Signals.spawnUnit.emit("Bad People", playerId, Data.UnitType.Lieutenant, "Shalmaneser")
						Signals.spawnUnit.emit("Bad People", playerId, Data.UnitType.Legion)
						Signals.spawnUnit.emit("Bad People", playerId, Data.UnitType.Legion)
				
				var nr : String
				for playerId in Data.players:
					if playerId == Data.id:
						nr = Decks.getSpecificCard("demon", "Caim") #29
						for peer in Connection.peers:
							RpcCalls.addDemon.rpc_id(peer, playerId, nr)
						nr = Decks.getSpecificCard("demon", "Beelzebub") #8
						for peer in Connection.peers:
							RpcCalls.addDemon.rpc_id(peer, playerId, nr)
						nr = Decks.getSpecificCard("demon", "Gomory") #38
						for peer in Connection.peers:
							RpcCalls.addDemon.rpc_id(peer, playerId, nr)
						for peer in Connection.peers:
							RpcCalls.demonStatusChange.rpc_id(peer, 38, "earth")
					else:
						nr = Decks.getSpecificCard("demon", "Ashtaroth") #11
						for peer in Connection.peers:
							RpcCalls.addDemon.rpc_id(peer, playerId, nr)
				for peer in Connection.peers:
					RpcCalls.updateRankTrack.rpc_id(peer, rankTrackNode.rankTrack)
				rankTrack = rankTrackNode.rankTrack.duplicate()
				Signals.collapseDemonCards.emit()
				
				Signals.tutorial.emit(Tutorial.Topic.Phase, "This is the Combat Phase. \nEach Sectio with Units that belong to more than two Players will fight for the ownership of the Sectio.")
				await Signals.tutorialRead
			await sequence.combat(map)
		for peer in Connection.peers:
			RpcCalls.combatOver.rpc_id(peer)
			
		if phase == Data.phases.Combat:
			phase = Data.nextPhase()
		for peer in Connection.peers:
			RpcCalls.updatePhaseLabel.rpc_id(peer, phase, Data.phases.keys()[phase])
		await get_tree().create_timer(0.1).timeout
		Save.saveGame()
		
		print("Petitions phase ",phase, " ", Data.phases.Petitions)
		if phase == Data.phases.Petitions and not skipPetitions:
			if Tutorial.tutorial:
				Signals.changeFavors.emit(Data.id, 1)
				for playerId in Data.players:
					if playerId == Data.id:
						Signals.spawnUnit.emit("Thieves", playerId, Data.UnitType.Legion)
						Signals.spawnUnit.emit("Orgastica", playerId, Data.UnitType.Legion)
				
				Signals.tutorial.emit(Tutorial.Topic.Phase, "This is the Petition Phase. \nLegions can capture Sectios that are either neutral or in enemy hands. \nThis will cost a Favor so choose wisely.")
				await Signals.tutorialRead
			
			
			var petitionSectios = {}
			for sectio in Decks.sectioNodes.values():
				var playerId = null
				for unitName in sectio.troops:
					var unit = Data.troops[unitName]
					if unit.unitType == Data.UnitType.Lieutenant:
						continue
					if playerId == null:
						playerId = unit.triumphirate
						petitionSectios[sectio.sectioName] = playerId
					if unit.triumphirate != playerId:
						petitionSectios.erase(sectio.sectioName)
					print(Data.players[playerId].sectios, " compare ", sectio.sectioName)
					if Data.players[playerId].sectios.has(sectio.sectioName):
						print(playerId, "has already ",sectio.sectioName)
						petitionSectios.erase(sectio.sectioName)
			var petitionSectiosByTriumphirate = {}
			for sectioName in petitionSectios:
				# dont ask for a Favor if the sectio was occupied in battle
				if sequence.combatWinner.values().has(sectioName):
					continue
				if petitionSectiosByTriumphirate.has(petitionSectios[sectioName]):
					petitionSectiosByTriumphirate[petitionSectios[sectioName]].append(sectioName)
				else:
					petitionSectiosByTriumphirate[petitionSectios[sectioName]] = [sectioName]
#				petitionSectio.rpc_id(petitionSectios[sectioName], sectioName)
#				print("waiting for petition ", sectioName)
#				var petition = await petitionConfirmed
#				if petition:
#					occupySectio.rpc_id(peer, petitionSectios[sectioName], sectioName)
			
			for winner in sequence.combatWinner:
				for peer in Connection.peers:
					RpcCalls.occupySectio.rpc_id(peer, winner, sequence.combatWinner[winner])
			
			Signals.tutorial.emit(Tutorial.Topic.Combat, "Notice, the winner of the Battle will occupy the Sectio for free.")
			await Signals.tutorialRead
			
			Signals.tutorial.emit(Tutorial.Topic.Combat, "Now use the menu to the left to pick the Sectio you want to capture.")
			await Signals.tutorialRead
			
			for triumphirate in petitionSectiosByTriumphirate:
				print("wait ",triumphirate, petitionSectiosByTriumphirate[triumphirate])
				if Connection.peers.has(triumphirate):
					for peer in Connection.peers:
						ui.updateRankTrackCurrentPlayer.rpc_id(peer, triumphirate)
					RpcCalls.petitionSectiosRequest.rpc_id(triumphirate, petitionSectiosByTriumphirate[triumphirate])
					await Signals.petitionConfirmed
					print("done")
					for sectio in Decks.sectioNodes.values():
						sectio.changeClickable.rpc_id(triumphirate, false)
				else:
					# AI
					var player = Data.players[triumphirate]
					while player.hasFavor():
						var sectioNameToOccupy : String = ""
						for sectioName in petitionSectiosByTriumphirate[triumphirate]:
							var sectio = Decks.sectioNodes[sectioName]
#							var circle : int = WorldState.get_state("circle_to_capture")
							var circle : int = Ai.worldStates[triumphirate].get_state("circle_to_capture")
							if sectio.circle == circle:
								sectioNameToOccupy = sectioName
						petitionSectiosByTriumphirate[triumphirate].erase(sectioNameToOccupy)
						if not sectioNameToOccupy == "":
							var favors = player.favors - 1
							Signals.changeFavors.emit(triumphirate, favors)
							for peer in Connection.peers:
								RpcCalls.occupySectio.rpc_id(peer, triumphirate, sectioNameToOccupy)
						else:
							break
			print("petitions done")
			if Tutorial.tutorial:
				Signals.tutorial.emit(Tutorial.Topic.Combat, "You have no more Favors left, and cannot occupy the last Sectio.")
				await Signals.tutorialRead
				await get_tree().create_timer(0.1).timeout
				Signals.returnToMainMenu.emit()
				await Signals.tutorialRead
			
		
		if phase == Data.phases.Petitions :
			phase = Data.nextPhase()
		for peer in Connection.peers:
			RpcCalls.updatePhaseLabel.rpc_id(peer, phase, Data.phases.keys()[phase])
		await get_tree().create_timer(0.1).timeout
		Save.saveGame()
		
		print("End phase ",phase, " ", Data.phases.End)
		if phase == Data.phases.End and not skipEnd:
			var winCondition = false
			var winner
			for playerId in Data.players:
				var player = Data.players[playerId]
				var circleCount = {}
				for sectioName in player.sectios:
					var sectio = Decks.sectioNodes[sectioName]
					if circleCount.has(sectio.circle):
						circleCount[sectio.circle] += 1
					else:
						circleCount[sectio.circle] = 1
					if circleCount[sectio.circle] >= 5:
						winCondition = true
						winner = playerId
						
			if winCondition: 
				for peer in Connection.peers:
					RpcCalls.win.rpc_id(peer, winner)
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




func _on_map_unit_placing_done():
#	pass # Replace with function body.
	print("done")


func _on_phase_done():
	pass # Replace with function body.


func _on_demon_done_with_phase(fleeAction):
	pass
#	actionsNode.demonActionDone()


func _on_host():
	Main.StartServer()
	
	Connection.connectToServer()
	await get_tree().create_timer(0.5).timeout
	
	Server.create_room.rpc_id(1, "Debug")
	Connection.host = Data.id
	
	await get_tree().create_timer(0.5).timeout
	RpcCalls.peerReady.rpc_id(Connection.host)
	ui.start()


func peer_connected(id):
	print("joined: ",id)
#	map.addSpawner(id)
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
	ui.start()


func _on_playerjoinedRoom(roomId : int, room_name : String, player_id : int, playersIdNameDict : Dictionary):
	print(Data.id, "joined")
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


func _on_recruiting():
	Signals.toggleRecruitLegionsButtonEnabled.emit(false)


func _on_recruitingDone():
	Signals.toggleEndPhaseButton.emit(true)
	for sectioName in Data.player.sectiosWithoutEnemies:
		Decks.sectioNodes[sectioName].changeClickable(false)
	Data.player.checkPlayerSummoningCapabilities(0)


func _on_recruit_legions():
	Signals.recruiting.emit()
	Data.changeState(Data.States.RECRUITING)
	
	Sectios.sectiosWithoutEnemiesClickable()
	
	while true:
		var sectio = await Signals.sectioClicked
		if sectio == null:
			break
		if Data.player.hasEnoughSouls(3):
			map.placeUnit(sectio, Data.id, Data.UnitType.Legion)
			var souls = Data.players[sectio.player].souls - 3
			Signals.changeSouls.emit(sectio.player, souls)
			if not Data.player.hasEnoughSouls(3):
				break
			
			Sectios.sectiosLeftClickable(sectio.sectioName)
			Signals.tutorialRead.emit()
	
	Data.changeState(Data.States.IDLE)
	Signals.recruitingDone.emit()


func _on_recruit_lieutenant(lieutenantName : String):
	Signals.recruiting.emit()
	Signals.toggleEndPhaseButton.emit(false)
	Signals.toggleBuyArcanaCardButtonEnabled.emit(false)
	
	Sectios.sectiosClickable(Data.player.sectiosWithoutEnemies)
	
	var sectio = await Signals.sectioClicked
	
	map.placeUnit(sectio, Data.id, Data.UnitType.Lieutenant, lieutenantName)
	
	if Data.player.hasEnoughSouls(3):
		Sectios.remainingSectiosClickable(Data.player.sectiosWithoutEnemies.duplicate())
	else:
		Sectios.sectiosUnclickable(Data.player.sectiosWithoutEnemies)
	
	Signals.recruitingDone.emit()
	
	if Tutorial.tutorial:
		Signals.tutorialRead.emit()

func _on_picked_demon(demonRank : int):
	RpcCalls.pickedDemonForCombat.rpc_id(Connection.host, demonRank)


# not used
#func _on_pick_combat_hit_control_legions_hit(unitNames):
#	pickedHitsForCombat.rpc_id(Connection.host, unitNames)





func _on_buyArcanaCard():
	Data.player.checkPlayerSummoningCapabilities(5)
#	if Data.player.hasEnoughSouls(10):
#		%BuyArcanaCardMarginContainer.show()
#	else:
#		%BuyArcanaCardMarginContainer.hide()
	if Data.player.hasEnoughSouls(5):
		var souls = Data.players[Data.id].souls - 5
		Signals.changeSouls.emit(Data.id, souls)
		RpcCalls.requestArcanaCardsToPick.rpc_id(Connection.host)


func _on_removeLieutenantFromAvailableLieutenantsBox(lieutenantName : String):
	Decks.availableLieutenants.erase(lieutenantName)
	ui.removeLieutenantFromAvailableLieutenantsBox(lieutenantName)
	


func _on_demon_status_change(demonRank, status):
	for peer in Connection.peers:
		RpcCalls.demonStatusChange.rpc_id(peer, demonRank, status)
	Signals.incomeChanged.emit(Data.id)


func _on_no_demon_picked():
	Data.pickDemon = false
	RpcCalls.pickedDemonForCombat.rpc_id(Connection.host, 0)


func _on_petition_approved(sectioName):
#	confirmPetition.rpc_id(Connection.host, true)
	var favors = Data.player.favors - 1
	Signals.changeFavors.emit(Data.id, favors)
	for peer in Connection.peers:
		RpcCalls.occupySectio.rpc_id(peer, Data.id, sectioName)


func _on_peititonsDone():
	RpcCalls.petitionsDone.rpc_id(Connection.host)


func _on_map_pick_unit(sectio):
	ui.pickUnitToMove(sectio)


func _on_taming_hellhound():
	var result = Dice.roll(1)
	if result[0] <= 4:
		pass
	elif result[0] == 5:
		pass
	elif result[0] == 6:
		pass
#		map.removeUnit.rpc_id(peer, unitName)


func _on_proceed():
	RpcCalls.proceed.rpc_id(Connection.host)


func _on_returnToMainMenu():
	Signals.resetGame.emit()
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")


func _on_returnToLobby():
	Server.return_to_lobby.rpc_id(1)
	Signals.resetGame.emit()
	get_tree().change_scene_to_file("res://ui/lobby.tscn")


func _on_addPlayer(playerScene : Player):
	playersNode.add_child(playerScene)


func _on_updateTurnTrack(_turn : int):
	turn = _turn
