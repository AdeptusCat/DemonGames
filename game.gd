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

var combatWinner = {}
var triumphiratesThatWantToFlee : Array = []

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

var canHitLieutenants : bool = true
var lieutenantBonus : bool = true


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
	Signals.arcanaClicked.connect(_on_arcanaClicked)
	Signals.minorSpell.connect(_on_MinorSpell)
	Signals.pickedDemon.connect(_on_picked_demon)
	Signals.recruitLieutenant.connect(_on_recruit_lieutenant)
	Signals.recruitLegions.connect(_on_recruit_legions)
	Signals.host.connect(_on_host)
	Signals.join.connect(_on_join)
	Signals.start.connect(_on_start)
	Signals.phaseDone.connect(_on_phase_done)
	Signals.demonDoneWithPhase.connect(_on_demon_done_with_phase)
	Signals.buyArcanaCard.connect(_on_buyArcanaCard)
	Signals.triumphiratWantsToFlee.connect(_on_triumphiratesWantToFlee)
	Signals.allPlayersReady.connect(_on_allPlayersReady)
	Signals.recruitedLieutenant.connect(_on_recruitedLieutenant)
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
func loadUnit(sectioName : String, lieutenant : bool = false):
	if lieutenant:
		map.recruitLieutenant = true
	map._on_sectioClicked(Decks.sectioNodes[sectioName])


@rpc("any_peer", "call_local")
func spawnDebugTroops1(ai : int = 0):
	var sectio
	if Connection.dedicatedServer:
		return
	if not ai == 0:
		map.lieutenantNameToSpawn = "Shalmaneser"
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
		
		map.lieutenantNameToSpawn = "Shalmaneser"
		sectio = Decks.sectioNodes["Bad People"]
		map.placeUnit(sectio, Data.id, Data.UnitType.Lieutenant)
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
		map.lieutenantNameToSpawn = "Shalmaneser"
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


func _on_arcanaClicked(arcanaCard : ArcanaCard, mode):
	if mode == "discard":
		if Tutorial.tutorial:
			if arcanaCard.minorSpell == Decks.MinorSpell.RecruitLieutenants:
				return
			else:
				Signals.tutorialRead.emit()
		var player : Player = Data.players[arcanaCard.player]
#		player.arcanaCards.erase(arcanaCard.cardName)
		for peer in Connection.peers:
			RpcCalls.discardArcanaCard.rpc_id(peer, arcanaCard.cardName, arcanaCard.player)
		arcanaCard.queue_free()
		if player.arcanaCards.size() > 5:
			player.discardModeArcanaCard()
		else:
			for card in player.arcanaCards:
				Data.arcanaCardNodes[card].mode = ""
			RpcCalls.checkEndPhaseCondition()
	elif mode == "pick":
		if Tutorial.tutorial:
			if arcanaCard.minorSpell == Decks.MinorSpell.RecruitLieutenants:
				Signals.tutorialRead.emit()
			else:
				return
		for peer in Connection.peers:
			RpcCalls.addArcanaCard.rpc_id(peer, Data.id, arcanaCard.cardName)
		Signals.hidePickArcanaCardContainer.emit(arcanaCard.cardName)


func _on_recruitedLieutenant():
	canAffordRecruitLieutenants(Data.id)
	RpcCalls.recruitedLieutenant.rpc_id(Connection.host)


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


func setupSaveGame1(playerIds : Array):
	Signals.phaseReminder.emit("Start Phase")
	var playerNameIdDict = {}
	for playerId in playerIds:
		print("start phase ",Connection.playerIdNamesDict)
		var newName = Connection.playerIdNamesDict[playerId]
		var oldName = Connection.NewPlayerNamesDictToloadedPlayerNames[newName]
		Save.savegame.players[newName] = Save.savegame.players[oldName]
		print(newName, " ", oldName, " ", Save.savegame.players)
		for peer in Connection.peers:
			RpcCalls.addPlayer.rpc_id(peer, playerId, Save.savegame.players[newName])
			RpcCalls.changeColor.rpc_id(peer, playerId, Save.savegame.players[oldName].colorName)
			RpcCalls.changePlayerName.rpc_id(peer, playerId, newName)
		playerNameIdDict[newName] = playerId
		playerNameIdDict[oldName] = playerId
		Save.savegame.players[playerId] = Save.savegame.players[oldName]
	
	
	
	for playerId in Data.players:
		var player = Data.players[playerId]
#		# 4 legions and souls/favors
		print("setup load")
		Signals.changeSouls.emit(playerId, Save.savegame.players[playerId].souls)
		Signals.changeFavors.emit(playerId, Save.savegame.players[playerId].favors)
		Signals.changeDisfavors.emit(playerId, Save.savegame.players[playerId].disfavors)
		
#		player.souls = Save.savegame.players[playerId].souls
#		player.favors = Save.savegame.players[playerId].favors
#		player.disfavors = Save.savegame.players[playerId].disfavors
	
	for playerId in Data.players:
		# 5 demons
		for demonName in Save.savegame.players[playerId].demons:
			# for some reason it tries to load the rank values in int
			# but the array only contains the names of the demons???
			if demonName is String:
				for peer in Connection.peers:
					RpcCalls.addDemon.rpc_id(peer, playerId, demonName + ".tres", Save.savegame.demons[demonName])
	
	# when loading you cannot change start demon
#	toogleWaitForPlayer.rpc_id(peer, 0, true)
#	if not Settings.skipScreens:
#		ui.confirmStartDemon.rpc_id(peer, )
#		for playerId in Data.players:
#			await proceedSignal
#	toogleWaitForPlayer.rpc_id(peer, 0, false)
#		# 6 arrange the Rank Track
#

	for playerId in Data.players:
		for sectioName in Save.savegame.players[playerId].sectios:
			for peer in Connection.peers:
				RpcCalls.occupySectio.rpc_id(peer, playerId, sectioName)
	
	#debug
#	debugSectios()
	
#	for playerId in Data.players:
##		# 7 sectios
#		for i in range(4):
#			var sectio = Decks.getRandomCard("sectio")
#			occupySectio.rpc_id(peer, playerId, sectio)
		# debug
#		if playerId == 1:
#			for i in range(Decks.sectioCards.size()-3):
#				var sectio = Decks.getRandomCard("sectio")
#				occupySectio.rpc_id(peer, playerId, sectio)
#		else:
#			for i in range(3):
#				var sectio = Decks.getRandomCard("sectio")
#				occupySectio.rpc_id(peer, playerId, sectio)
	
	for legion in Save.savegame.legions.values():
		loadUnit.rpc_id(playerNameIdDict[legion.playerName], legion.occupiedSectio)
	
	for lieutenant in Save.savegame.lieutenants.values():
		# doesnt need to return the name, for its already known
		# but it needs to be removed from the deck
		Decks.getSpecificCard("lieutenant", lieutenant.unitName)
		# need to pass the new triumphirates ID, not the old one
		for peer in Connection.peers:
			map.spawnLieutenant.rpc_id(peer, lieutenant.occupiedSectio, lieutenant.unitNr, lieutenant.unitName, playerNameIdDict[lieutenant.playerName])
	
	# fill Lieutenants Box after spawning the players Lieutenants
	for i in range(3):
		var lieutenantName = Decks.getRandomCard("lieutenant")
		# might be null if there are no Lieutenants left
		if lieutenantName:
			for peer in Connection.peers:
				RpcCalls.fillAvailableLieutenantsBox.rpc_id(peer, lieutenantName)
	
#	if not skipUnitPlacing:
#		for playerId in Data.players:
#			var player = Data.players[playerId]
#			# 8 place one legion
#			for sectio in player.sectios:
#				Decks.sectioNodes[sectio].changeClickable.rpc_id(playerId, true)
#			toogleWaitForPlayer.rpc_id(peer, playerId, true)
#			await map.unitPlacingDone
#			print("unit placed")
#			toogleWaitForPlayer.rpc_id(peer, playerId, false)
#			for sectio in player.sectios:
#				Decks.sectioNodes[sectio].changeClickable.rpc_id(playerId, false)
#	return
		# debug
#		map._on_sectioClicked(Decks.sectioNodes[player.sectios[0]])
		
	for playerId in Data.players:
#		# 9 arcana cards
		for cardName in Save.savegame.players[playerId].arcanaCards:
			# remove card from deck
			Decks.getSpecificCard("arcana", cardName)
			for peer in Connection.peers:
				RpcCalls.addArcanaCard.rpc_id(peer, playerId, cardName)
	for peer in Connection.peers:
		RpcCalls.showStartScreen.rpc_id(peer)

	for peer in Connection.peers:
		RpcCalls.toogleWaitForPlayer.rpc_id(peer, 66, true)
	if not Settings.skipScreens:
		for peer in Connection.peers:
			await Signals.proceedSignal
	for peer in Connection.peers:
		RpcCalls.toogleWaitForPlayer.rpc_id(peer, 66, false)
	
#	ui.rankTrack = rankTrackNode.rankTrack
# udate rank track by loading the savegame
#	updateRankTrack.rpc_id(peer, rankTrackNode.rankTrack)
	
	if Save.savegame.game:
		loadGame(Save.savegame.game)
	sequenceOfPlay()


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
	
	print("wait for finish 0")
	# just do it in the soul phase
#	for playerId in Data.players:
##		# 9 arcana cards
#		for i in range(5):
#			var CardName : String = Decks.getRandomCard("arcana")
#			for peer in Connection.peers:
#				RpcCalls.addArcanaCard.rpc_id(peer, playerId, CardName)
#	for peer in Connection.peers:
##		RpcCalls.showArcanaCardsContainer.rpc_id(peer)
#		RpcCalls.showStartScreen.rpc_id(peer)

	print("wait for finish 1")
#	if Connection.peers.size() > 1:
#		for peer in Connection.peers:
#			RpcCalls.toogleWaitForPlayer.rpc_id(peer, 66, true)
#	if not Settings.skipScreens and Connection.peers.size() > 1:
#		for peer in Connection.peers:
#			await Signals.proceedSignal
#	for peer in Connection.peers:
#		RpcCalls.toogleWaitForPlayer.rpc_id(peer, 66, false)
	print("wait for finish 2")
#	ui.rankTrack = rankTrackNode.rankTrack
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
	changeIncome(playerId)


func changeIncome(playerId : int):
	var player = Data.players[playerId]
	var income : int = 0
	var enemyInSectio : bool = false
	var demonsOnEarth : int = 0
	var demonHearts : int = 0
	for demonRank in player.demons:
		demonRank = demonRank as int
		var demon : Demon = Data.demons[demonRank]
		if not demon.incapacitated:
			if demon.onEarth:
				demonsOnEarth += 1
				demonHearts += demon.hearts
	
	for sectioName in player.sectios:
		for unitName in Decks.sectioNodes[sectioName].troops:
			if not Data.troops[unitName].triumphirate == playerId:
				enemyInSectio = true
				break
		if not enemyInSectio:
			var sectio = Decks.sectioNodes[sectioName]
			var isIsolated = sectio.isolated()
			var soulsGathered = sectio.souls
			# check for hellhounds in sectio as well!! hellhounds  hellhounds  hellhounds  hellhounds  hellhounds  hellhounds 
			if isIsolated:
				soulsGathered -= 2
			soulsGathered = clamp(soulsGathered, 0, 100)
			income += soulsGathered

	for unitName in player.troops:
		var unit = Data.troops[unitName]
		if not unit.unitType == Data.UnitType.Hellhound:
			income -= 1
	
	income += demonHearts
	var incomeString = str(income + demonsOnEarth)
	if demonsOnEarth > 0:
		incomeString += " - " + str(demonsOnEarth * 6 + income)
	Signals.changeIncome.emit(playerId, incomeString)


func sequenceOfPlay(phase : int = 0):
	if debugTroops:
		for playerId in Data.players.keys():
			if Connection.peers.has(playerId):
				spawnDebugTroops1.rpc_id(playerId)
				await get_tree().create_timer(0.5).timeout
			else:
				spawnDebugTroops1(playerId)
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
		combatWinner = {}
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
			await combat()
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
				if combatWinner.values().has(sectioName):
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
			
			for winner in combatWinner:
				for peer in Connection.peers:
					RpcCalls.occupySectio.rpc_id(peer, winner, combatWinner[winner])
			
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
		


func combat():
	# get all sectios with two or more different triumphirates
	var battleSectios = []
	for sectio in Decks.sectioNodes.values():
		var playerId = null
		for unitName in sectio.troops:
			var unit = Data.troops[unitName]
			print(sectio, " ",Data.troops[unitName])
			if not unit.unitType == Data.UnitType.Legion:
				continue
			if playerId == null:
				playerId = unit.triumphirate
			if unit.triumphirate != playerId:
				if not battleSectios.has(sectio):
					battleSectios.append(sectio)
	print("battle ",battleSectios)
	# sort the sectios with the most units in it to the fewest
	var battleSectiosSorted = []
	for sectio in battleSectios:
		if battleSectiosSorted.size() == 0:
			battleSectiosSorted.append(sectio)
			continue
		for sortedSectio in battleSectiosSorted:
			if sectio.troops.size() >= sortedSectio.troops.size():
				battleSectiosSorted.insert(battleSectiosSorted.find(sortedSectio), sectio)
				break
	
	print("sorted 1")
	if battleSectiosSorted.size() <= 0:
		return
	
	print("sorted 2")
	var battleCount : int = 0
	# battle for each sectio
	for sectio in battleSectiosSorted:
		# which triumphirate has the most legions in the sectio
		# first, a dict with Playerid and unitCount
		for peer in Connection.peers:
			RpcCalls.moveCamera.rpc_id(peer, sectio.global_position)
		await Signals.doneMoving
		print("first")
		var unitsDict = {}
		var unitsNameDict = {}
		for unitName in sectio.troops:
			var unitNames = unitName
			var unit = Data.troops[unitName]
			# only count legion strength
			if unit.unitType == Data.UnitType.Legion:
				if not unitsDict.has(unit.triumphirate):
					unitsDict[unit.triumphirate] = 1
				else:
					unitsDict[unit.triumphirate] += 1
			if unitsNameDict.has(unit.triumphirate):
				unitsNameDict[unit.triumphirate] = unitsNameDict[unit.triumphirate] + [unitName]
			else:
				unitsNameDict[unit.triumphirate] = [unitName]
		print("second")
		# second, two array with parallel the Playerid and unitCount
		var triumphirates = []
		var unitCount = []
		for triumphirate in unitsDict:
			triumphirates.append(triumphirate)
			unitCount.append(unitsDict[triumphirate])
		print("third")
		# third, sort the two array by finding the index of the maxValue
		var triumphiratesSorted = []
		var range = unitCount.size()
		for count in range:
			var max = unitCount.max()
			var index = unitCount.find(max)
			triumphiratesSorted.append(triumphirates[index])
			triumphirates.remove_at(index)
			unitCount.remove_at(index)
		
		for peer in Connection.peers:
			RpcCalls.startCombat.rpc_id(peer, unitsNameDict, sectio.sectioName)
		
		print("pick demon")
		# all this, so that the triumphirate with the most legion, can pick his demon first
		var demonDict = {}
		for triumphirate in triumphiratesSorted:
			if Connection.peers.has(triumphirate):
				RpcCalls.pickDemonForCombat.rpc_id(triumphirate)
				print("pick demon ", Data.players[triumphirate].playerName)
				
				Signals.tutorial.emit(Tutorial.Topic.Combat, "Demons can help your Units in Combat. Depending on the amount on Skull they have, the survivability of Units increases. \nA Demon can only fight once per Combat Phase. \nYou can also choose to not use a Demon in Combat. \nDemons on Earth cannot fight in Hell.")
				
				var demonName = await Signals.pickedDemonInGame
				print("player ", Data.players[triumphirate].playerName, " chose demon ", demonName)
				if not demonName == 0:
					demonDict[triumphirate] = demonName
		
		Signals.tutorial.emit(Tutorial.Topic.Combat, "Lieutenants help your Legions to hit enemy Units. \nThe number with the '+' sign on the left shows the combat bonus. \nThe number on the right shows the number of Legions the Lieutenant can support.")
		await Signals.tutorialRead
		
		Signals.tutorial.emit(Tutorial.Topic.Combat, "You can at anytime decide to flee from Combat, but if you do, it counts as a win for the enemy and will occupy the Sectio for free.")
		await Signals.tutorialRead
		
		var fleeingFromCombat = false
		var noMoreEnemies = false
		var nobodyLeft = false
		while not fleeingFromCombat:
			for peer in Connection.peers:
				RpcCalls.showCombat.rpc_id(peer)
			unitsDict = {}
			unitsNameDict = {}
			var unitsNameHitPropabilityDict = {}
			var lieutenantsBonusDict = {}
			for unitName in sectio.troops:
				var unitNames = unitName
				var unit = Data.troops[unitName]
				var triumphirateName = unit.triumphirate
				# only count legion strength
				if unit.unitType == Data.UnitType.Legion:
					if not unitsDict.has(triumphirateName):
						unitsDict[triumphirateName] = 1
					else:
						unitsDict[triumphirateName] += 1
					if not unitsNameHitPropabilityDict.has(triumphirateName):
						unitsNameHitPropabilityDict[triumphirateName] = [unitName]
					else:
						unitsNameHitPropabilityDict[triumphirateName] = unitsNameHitPropabilityDict[triumphirateName] + [unitName]
				if unit.unitType == Data.UnitType.Lieutenant:
					if not unitsNameHitPropabilityDict.has(triumphirateName):
						unitsNameHitPropabilityDict[triumphirateName] = [unitName]
					else:
						unitsNameHitPropabilityDict[triumphirateName] = unitsNameHitPropabilityDict[triumphirateName] + [unitName]
					if not lieutenantsBonusDict.has(triumphirateName):
						lieutenantsBonusDict[triumphirateName] = []
					for capacity in unit.capacity:
						lieutenantsBonusDict[triumphirateName] = lieutenantsBonusDict[triumphirateName] + [unit.combatBonus]
				if unitsNameDict.has(triumphirateName):
					unitsNameDict[triumphirateName] = unitsNameDict[triumphirateName] + [unitName]
				else:
					unitsNameDict[triumphirateName] = [unitName]
#					print(unitsNameHitPropabilityDict[enemyTriumphirate][index], " unittype ", Data.troops[unitsNameHitPropabilityDict[enemyTriumphirate][index]].unitType)

			var hitsDict = {}
			var unitsHitNamesDict = {}
			var unitsKilledNamesDict = {}
			
			print("new round")
			var triumphirateWithSolitaryLieutenants  = []
			for triumphirate in triumphiratesSorted:
				# this means there is only a lieutenant left and he has to flee
				if not unitsDict.has(triumphirate):
					if lieutenantsBonusDict.has(triumphirate):
						triumphirateWithSolitaryLieutenants.append(triumphirate)
					unitsNameDict.erase(triumphirate)
#					print("erasing who is left to fight ", triumphirate)
		
			for triumphirate in triumphiratesSorted.duplicate():
#				print("who is left to fight ", triumphiratesSorted)
				if not unitsNameDict.has(triumphirate):
					triumphiratesSorted.erase(triumphirate)
			if triumphiratesSorted.size() <= 1:
#				print("somebody left to fight")
				noMoreEnemies = true
			if triumphiratesSorted.size() <= 0:
#				print("nobody left to fight")
				nobodyLeft = true
			
			# if only one lieutenant is left, he can stay and occupy the sectio
			# otherwise they have to flee
			if nobodyLeft:
#				print("nobody left")
				if triumphirateWithSolitaryLieutenants.size() > 1:
					for triumphirate in triumphirateWithSolitaryLieutenants:
						for peer in Connection.peers:
							RpcCalls.hideCombat.rpc_id(peer)
						RpcCalls.endCombat.rpc_id(triumphirate)
						fleeingFromCombat = await map.forceFleeFromCombat(triumphirate, sectio)
						
			else:
#				print("somebody left")
				if noMoreEnemies:
					for triumphirate in triumphirateWithSolitaryLieutenants:
						for peer in Connection.peers:
							RpcCalls.hideCombat.rpc_id(peer)
						RpcCalls.endCombat.rpc_id(triumphirate)
						fleeingFromCombat = await map.forceFleeFromCombat(triumphirate, sectio)
			
			
			if noMoreEnemies:
#				print("battle done")
				
				if nobodyLeft:
					if triumphirateWithSolitaryLieutenants.size() == 1:
						combatWinner[triumphirateWithSolitaryLieutenants.pop_front()] = sectio.sectioName
					# two solitary lieutenants from different triumphirates? shouls flee...
#							else:
#								combatWinner[triumphiratesSorted.pop_front()] = sectio.sectioName
				else:
					combatWinner[triumphiratesSorted.pop_front()] = sectio.sectioName
				break
			
			for peer in Connection.peers:
				RpcCalls.showCombat.rpc_id(peer, )
			
			for triumphirate in triumphiratesSorted:
				var units = unitsNameDict[triumphirate]
				var legions = unitsDict[triumphirate]
				var lieutenantsBonus = []
				if lieutenantsBonusDict.has(triumphirate):
					lieutenantsBonus = lieutenantsBonusDict[triumphirate]
#						for unit in units:
#							if "MultiplayerSpawner" in unit.name:
#								continue
#							if unit.unitType == unit.UnitType.Lieutenant:
#								for capacity in unit.capacity:
#									lieutenantsBonus.append(unit.combatBonus)
#							elif unit.unitType == unit.UnitType.Legion:
#								legions += 1
				lieutenantsBonus.sort()
#				print(triumphirate, " has legions: ", legions)
				var hits = 0
				for legion in legions:
					for peer in Connection.peers:
						print("attacking legions ",legions)
						RpcCalls.unitsAttack.rpc_id(peer)
					var result = Dice.roll(1)
					print(Data.players[triumphirate].playerName, " rolls ", result[0])
					if lieutenantsBonus.size() > 0:
#						print("bonus ",lieutenantsBonus)
						result[0] += lieutenantsBonus.pop_back()
					print(Data.players[triumphirate].playerName, " after lieutenant ", result[0])
					if result[0] >= 6: #3
						hits += 1
				hitsDict[triumphirate] = hits
				print(Data.players[triumphirate].playerName, " made ", hits, " hits")
				# hits will hit every other player, which is not ideal ;)
#						for id in triumphiratesSorted:
#							if not id == triumphirate:
#								pickHitsForCombat.rpc_id(id.to_int(), unitsNameDict[id], hits)
				
#						var unitNames : Array = await pickedHits
				var unitNames : Array = []
				var enemyTriumphirates = triumphiratesSorted.duplicate()
				enemyTriumphirates.erase(triumphirate)
#						unitsHitNamesDict[] = []
#						unitsKilledNamesDict[] = []
#				print(unitsNameHitPropabilityDict)
				for hit in hits:
					var i = randi_range(0, enemyTriumphirates.size() - 1)
					var enemyTriumphirate = enemyTriumphirates[i]
					var index = randi_range(0, unitsNameHitPropabilityDict[enemyTriumphirate].size() - 1)
#							var index = hit # use this to debug and hit everybody
#					print("index ", index ," size ",unitsNameHitPropabilityDict[enemyTriumphirate].size())
					unitNames.append(unitsNameHitPropabilityDict[enemyTriumphirate][index])
					if unitsHitNamesDict.has(enemyTriumphirate):
						unitsHitNamesDict[enemyTriumphirate].append(unitsNameHitPropabilityDict[enemyTriumphirate][index])
					else:
						unitsHitNamesDict[enemyTriumphirate] = [unitsNameHitPropabilityDict[enemyTriumphirate][index]]
				var unitsDied : Array = []
				for unitName in unitNames.duplicate():
					if not Data.troops.has(unitName):
						continue
					var unit = Data.troops[unitName]
					var result = Dice.roll(1)
					print("unit type: ", unit.unitType, " ", Data.UnitType.Lieutenant)
					print("unit name: ", unit.unitName)
					print("save: ", result[0])
					if unit.unitType == Data.UnitType.Lieutenant or unit.unitType == Data.UnitType.Hellhound:
						result[0] -= 3
						print("lieute: ",3)
					else:
						if demonDict.has(unit.triumphirate):
							var demonRank = demonDict[unit.triumphirate]
	#							print(demonName, " name")
							# Lieutenants and Hellhound save on a 4. Legions use the Demon's skulls
							result[0] -= Data.demons[demonRank].skulls
							print("skulls: ",Data.demons[demonRank].skulls)
					print(result[0])
					if not result[0] <= 1: #3
						print(Data.players[unit.triumphirate].playerName," lost ", unitName)
						unitsDied.append(unitName)
						unitNames.erase(unitName)
						unitsNameDict[unit.triumphirate].erase(unitName)
#						for peer in peers:
#							map.removeUnit.rpc_id(peer, unitName)
						for peer in Connection.peers:
							map.removeUnit.rpc_id(peer, unitName)
						
						if unitsKilledNamesDict.has(unit.triumphirate):
							unitsKilledNamesDict[unit.triumphirate].append(unitName)
						else:
							unitsKilledNamesDict[unit.triumphirate] = [unitName]
						if unit.unitType == Data.UnitType.Lieutenant:
							Decks.addCard(unit.unitName, "lieutenant")
				var unitsInSectioNames : Array = sectio.troops
				for unitName in unitsDied:
					unitsInSectioNames.erase(unitName)
				for peer in Connection.peers:
					map.updateTroopInSectio.rpc_id(peer, sectio.sectioName, unitsInSectioNames)
			for peer in Connection.peers:
				RpcCalls.unitsHit.rpc_id(peer, unitsHitNamesDict)
			await get_tree().create_timer(1.1).timeout
			for peer in Connection.peers:
				RpcCalls.unitsKilled.rpc_id(peer, unitsKilledNamesDict)
			await get_tree().create_timer(1.1).timeout
			
			print("end of round")
			unitsDict = {}
			unitsNameDict = {}
			unitsNameHitPropabilityDict = {}
			lieutenantsBonusDict = {}
			for unitName in sectio.troops:
				var unitNames = unitName
				var unit = Data.troops[unitName]
				var triumphirateName = unit.triumphirate
				# only count legion strength
				if unit.unitType == Data.UnitType.Legion:
					if not unitsDict.has(triumphirateName):
						unitsDict[triumphirateName] = 1
					else:
						unitsDict[triumphirateName] += 1
					if not unitsNameHitPropabilityDict.has(triumphirateName):
						unitsNameHitPropabilityDict[triumphirateName] = [unitName]
					else:
						unitsNameHitPropabilityDict[triumphirateName] = unitsNameHitPropabilityDict[triumphirateName] + [unitName]
				if unit.unitType == Data.UnitType.Lieutenant:
					if canHitLieutenants:
						if not unitsNameHitPropabilityDict.has(triumphirateName):
							unitsNameHitPropabilityDict[triumphirateName] = [unitName]
						else:
							unitsNameHitPropabilityDict[triumphirateName] = unitsNameHitPropabilityDict[triumphirateName] + [unitName]
					if lieutenantBonus:
						if not lieutenantsBonusDict.has(triumphirateName):
							lieutenantsBonusDict[triumphirateName] = []
						for capacity in unit.capacity:
							lieutenantsBonusDict[triumphirateName] = lieutenantsBonusDict[triumphirateName] + [unit.combatBonus]
				if unitsNameDict.has(triumphirateName):
					unitsNameDict[triumphirateName] = unitsNameDict[triumphirateName] + [unitName]
				else:
					unitsNameDict[triumphirateName] = [unitName]
#					print(unitsNameHitPropabilityDict[enemyTriumphirate][index], " unittype ", Data.troops[unitsNameHitPropabilityDict[enemyTriumphirate][index]].unitType)

			hitsDict = {}
			unitsHitNamesDict = {}
			unitsKilledNamesDict = {}
			
			triumphirateWithSolitaryLieutenants  = []
			for triumphirate in triumphiratesSorted:
				# this means there is only a lieutenant left and he has to flee
				if not unitsDict.has(triumphirate):
					if lieutenantsBonusDict.has(triumphirate):
						triumphirateWithSolitaryLieutenants.append(triumphirate)
					unitsNameDict.erase(triumphirate)
#					print("erasing who is left to fight ", triumphirate)
		
			for triumphirate in triumphiratesSorted.duplicate():
#				print("who is left to fight ", triumphiratesSorted)
				if not unitsNameDict.has(triumphirate):
					triumphiratesSorted.erase(triumphirate)
			if triumphiratesSorted.size() <= 1:
#				print("somebody left to fight")
				noMoreEnemies = true
			if triumphiratesSorted.size() <= 0:
#				print("nobody left to fight")
				nobodyLeft = true
			
			# if only one lieutenant is left, he can stay and occupy the sectio
			# otherwise they have to flee
			if nobodyLeft:
#				print("nobody left")
				if triumphirateWithSolitaryLieutenants.size() > 1:
					for triumphirate in triumphirateWithSolitaryLieutenants:
						for peer in Connection.peers:
							RpcCalls.hideCombat.rpc_id(peer, )
						RpcCalls.endCombat.rpc_id(triumphirate)
						fleeingFromCombat = await map.forceFleeFromCombat(triumphirate, sectio)
			else:
#				print("somebody left")
				if noMoreEnemies:
					for triumphirate in triumphirateWithSolitaryLieutenants:
						for peer in Connection.peers:
							RpcCalls.hideCombat.rpc_id(peer, )
						RpcCalls.endCombat.rpc_id(triumphirate)
						fleeingFromCombat = await map.forceFleeFromCombat(triumphirate, sectio)
			
			
			
			if noMoreEnemies:
				print("battle done")
				if nobodyLeft:
					if triumphirateWithSolitaryLieutenants.size() == 1:
						combatWinner[triumphirateWithSolitaryLieutenants.pop_front()] = sectio.sectioName
					# two solitary lieutenants from different triumphirates? shouls flee...
#							else:
#								combatWinner[triumphiratesSorted.pop_front()] = sectio.sectioName
				else:
					combatWinner[triumphiratesSorted.pop_front()] = sectio.sectioName
				break
			
			var fleeing = triumphiratesThatWantToFlee
			for triumphirate in fleeing:
				# the combat window will only be hidden for the fleeing triumphirate
				# should hide for all combat participants until all units fled
				# but the code waits for the fleeing to be done before sending the endCombat message
				# solution: wait for the triumphirate to choose endCombat() to flee
				# then hide combat window for all and wait until done fleeing
				for peer in Connection.peers:
					RpcCalls.hideCombat.rpc_id(peer)
				fleeingFromCombat = await map.fleeFromCombat(triumphirate, sectio)
				if fleeingFromCombat:
					RpcCalls.endCombat.rpc_id(triumphirate)
					triumphiratesSorted.erase(triumphirate)
				else:
					triumphiratesThatWantToFlee.clear()
			
			
#			print("check again for a winner after fleeing")
			unitsDict = {}
			unitsNameDict = {}
			unitsNameHitPropabilityDict = {}
			lieutenantsBonusDict = {}
			for unitName in sectio.troops:
				var unitNames = unitName
				var unit = Data.troops[unitName]
				var triumphirateName = unit.triumphirate
				# only count legion strength
				if unit.unitType == Data.UnitType.Legion:
					if not unitsDict.has(triumphirateName):
						unitsDict[triumphirateName] = 1
					else:
						unitsDict[triumphirateName] += 1
					if not unitsNameHitPropabilityDict.has(triumphirateName):
						unitsNameHitPropabilityDict[triumphirateName] = [unitName]
					else:
						unitsNameHitPropabilityDict[triumphirateName] = unitsNameHitPropabilityDict[triumphirateName] + [unitName]
				if unit.unitType == Data.UnitType.Lieutenant:
					if canHitLieutenants:
						if not unitsNameHitPropabilityDict.has(triumphirateName):
							unitsNameHitPropabilityDict[triumphirateName] = [unitName]
						else:
							unitsNameHitPropabilityDict[triumphirateName] = unitsNameHitPropabilityDict[triumphirateName] + [unitName]
					if lieutenantBonus:
						if not lieutenantsBonusDict.has(triumphirateName):
							lieutenantsBonusDict[triumphirateName] = []
						for capacity in unit.capacity:
							lieutenantsBonusDict[triumphirateName] = lieutenantsBonusDict[triumphirateName] + [unit.combatBonus]
				if unitsNameDict.has(triumphirateName):
					unitsNameDict[triumphirateName] = unitsNameDict[triumphirateName] + [unitName]
				else:
					unitsNameDict[triumphirateName] = [unitName]
#					print(unitsNameHitPropabilityDict[enemyTriumphirate][index], " unittype ", Data.troops[unitsNameHitPropabilityDict[enemyTriumphirate][index]].unitType)


			hitsDict = {}
			unitsHitNamesDict = {}
			unitsKilledNamesDict = {}

			triumphirateWithSolitaryLieutenants  = []
			for triumphirate in triumphiratesSorted:
				# this means there is only a lieutenant left and he has to flee
				if not unitsDict.has(triumphirate):
					if lieutenantsBonusDict.has(triumphirate):
						triumphirateWithSolitaryLieutenants.append(triumphirate)
					unitsNameDict.erase(triumphirate)
#					print("erasing who is left to fight ", triumphirate)

			for triumphirate in triumphiratesSorted.duplicate():
#				print("who is left to fight ", triumphiratesSorted, " ", unitsNameDict)

				if not unitsNameDict.has(triumphirate):
					triumphiratesSorted.erase(triumphirate)
			if triumphiratesSorted.size() <= 1:
#				print("somebody left to fight")
				noMoreEnemies = true
			if triumphiratesSorted.size() <= 0:
#				print("nobody left to fight")
				nobodyLeft = true

			# if only one lieutenant is left, he can stay and occupy the sectio
			# otherwise they have to flee
			if nobodyLeft:
#				print("nobody left")
				if triumphirateWithSolitaryLieutenants.size() > 1:
					for triumphirate in triumphirateWithSolitaryLieutenants:
						for peer in Connection.peers:
							RpcCalls.hideCombat.rpc_id(peer)
						RpcCalls.endCombat.rpc_id(triumphirate)
						fleeingFromCombat = await map.forceFleeFromCombat(triumphirate, sectio)
			else:
#				print("somebody left")
				if noMoreEnemies:
					for triumphirate in triumphirateWithSolitaryLieutenants:
						for peer in Connection.peers:
							RpcCalls.hideCombat.rpc_id(peer)
						RpcCalls.endCombat.rpc_id(triumphirate)
						fleeingFromCombat = await map.forceFleeFromCombat(triumphirate, sectio)


			if noMoreEnemies:
#				print("battle done")
				if nobodyLeft:
					if triumphirateWithSolitaryLieutenants.size() == 1:
						combatWinner[triumphirateWithSolitaryLieutenants.pop_front()] = sectio.sectioName
					# two solitary lieutenants from different triumphirates? shouls flee...
#							else:
#								combatWinner[triumphiratesSorted.pop_front()] = sectio.sectioName
				else:
					combatWinner[triumphiratesSorted.pop_front()] = sectio.sectioName
				break
			
			
		for peer in Connection.peers:
			RpcCalls.endCombat.rpc_id(peer)
		
		for unitName in sectio.troops:
			var unit = Data.troops[unitName]
			var i = sectio.slots.find(unit.triumphirate)
			var destination = sectio.slotPositions[i]
			if Connection.peers.has(unit.triumphirate):
				unit.set_destination.rpc_id(unit.triumphirate, destination)
			else:
				unit.set_destination.rpc_id(Connection.host, destination)
				
			
#					for triumphirate in triumphiratesSorted:
#						print("round over, await fleeing ")
#						fleeingFromCombat = await map.fleeFromCombat(triumphirate.to_int(), sectio)
#						if fleeingFromCombat:
#							break
			
#					for triumphirate in triumphiratesSorted.duplicate():
	
	await combat()


func _on_triumphiratesWantToFlee(triumphirat : int):
	triumphiratesThatWantToFlee.append(triumphirat)


# not used
#@rpc ("any_peer", "call_local")
#func petitionSectio(sectio):
#	Decks.sectioNodes[sectio].highlight(true)
#	ui.highlightSectioPreview(Decks.sectioNodes[sectio])
#	%Camera2D.moveTo(Decks.sectioNodes[sectio].global_position)
#
#	if Data.player.hasFavor():
#		%PetitionDialog.dialog_text = "Do you want to pay one Favor to occupy the '" + sectio + "' Sectio?"
#		%PetitionDialog.show()
#	else:
#		%PetitionDialog.dialog_text = "You do not have enough Favors to occupy the '" + sectio + "' Sectio."
#		%PetitionDialog.show()
#	await petitionConfirmed
#	Decks.sectioNodes[sectio].highlight(false)
#	ui.hideSectioPreview(sectio)











#func _input(event):
#	if event is InputEventKey:
#		if event.physical_keycode == KEdoneGatheringSoulsY_SPACE:
#			if Data.phase == Data.phases.Soul:
#				doneGatheringSouls.rpc_id(Connection.host)







# not used
#@rpc ("any_peer", "call_local")
#func pickHitsForCombat(unitNames : Array, hits : int):
#	if hits > 0:
#		%PickCombatHitControl.highlight(unitNames, hits)
#	else:
#		# wait a bit because the signal comes too early, before the await is set
#		await get_tree().create_timer(0.1).timeout
#		pickedHitsForCombat.Connection.host, [])

# not used
#@rpc ("any_peer", "call_local")
#func pickedHitsForCombat(unitNames : Array):
##	test.emit()
#	pickedHits.emit(unitNames)



		

@rpc("any_peer", "call_local")
func spawnDebugTroops():
	if Data.id == 1:
		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
		map.recruitLieutenant = true
		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
		map.recruitLieutenant = true
		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
		map.recruitLieutenant = true
		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
		map.recruitLieutenant = true
		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#	else:
#		await get_tree().create_timer(3).timeout
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
#		map._on_sectioClicked(Decks.sectioNodes["Bad People"])
	
#	for sectio in Decks.sectioNodes.values():
#		map.updateTroopInSectio.rpc_id(peer, sectio.sectioName, sectio.troops)
	return
	if Data.id == 1:
		for sectio in Data.player.sectios:
			map._on_sectioClicked(Decks.sectioNodes[sectio])
	#		map.recruitLieutenant = true
	#		map._on_sectioClicked(Decks.sectioNodes[sectio])
		map.recruitLieutenant = true
		map._on_sectioClicked(Decks.sectioNodes[Data.player.sectios[0]])
	else:
		for sectio in Data.player.sectios:
			map._on_sectioClicked(Decks.sectioNodes[sectio])
		map.recruitLieutenant = true
		map._on_sectioClicked(Decks.sectioNodes[Data.player.sectios[0]])


func _on_MinorSpell(arcanaCard):
#	arcanaCard.disable()
	Signals.sectioClicked.emit(null)
	for cardName in Data.player.arcanaCards:
		Data.arcanaCardNodes[cardName].disable()
	var MinorSpell = Decks.MinorSpell
	if arcanaCard.minorSpell == MinorSpell.Pass:
		actionsNode.passTurns(1)
		if Tutorial.currentTopic == Tutorial.Topic.Pass:
			Signals.tutorialRead.emit()
	if arcanaCard.minorSpell == MinorSpell.DoublePass:
		actionsNode.passTurns(2)
		if Tutorial.currentTopic == Tutorial.Topic.Pass:
			Signals.tutorialRead.emit()
	if arcanaCard.minorSpell == MinorSpell.TriplePass:
		actionsNode.passTurns(3)
		if Tutorial.currentTopic == Tutorial.Topic.Pass:
			Signals.tutorialRead.emit()
	if arcanaCard.minorSpell == MinorSpell.QuadruplePass:
		actionsNode.passTurns(4)
		if Tutorial.currentTopic == Tutorial.Topic.Pass:
			Signals.tutorialRead.emit()
	if arcanaCard.minorSpell == MinorSpell.QuinaryPass:
		actionsNode.passTurns(5)
		if Tutorial.currentTopic == Tutorial.Topic.Pass:
			Signals.tutorialRead.emit()
	if arcanaCard.minorSpell == MinorSpell.SenaryPass:
		actionsNode.passTurns(6)
		if Tutorial.currentTopic == Tutorial.Topic.Pass:
			Signals.tutorialRead.emit()
	if arcanaCard.minorSpell == MinorSpell.SeptenaryPass:
		actionsNode.passTurns(7)
		if Tutorial.currentTopic == Tutorial.Topic.Pass:
			Signals.tutorialRead.emit()
	if arcanaCard.minorSpell == MinorSpell.OctonaryPass:
		actionsNode.passTurns(8)
		if Tutorial.currentTopic == Tutorial.Topic.Pass:
			Signals.tutorialRead.emit()
	if arcanaCard.minorSpell == MinorSpell.NonaryPass:
		actionsNode.passTurns(9)
		if Tutorial.currentTopic == Tutorial.Topic.Pass:
			Signals.tutorialRead.emit()
	
	if arcanaCard.minorSpell == MinorSpell.WalkTheEarth or arcanaCard.minorSpell == MinorSpell.WalkTheEarthSafely:
		if Tutorial.currentTopic == Tutorial.Topic.WalkTheEarth:
			Signals.tutorialRead.emit()
		for peer in Connection.peers:
			RpcCalls.demonStatusChange.rpc_id(peer, actionsNode.demon.rank, "earth")
		actionsNode.walkTheEarth()
	if arcanaCard.minorSpell == MinorSpell.RecruitLieutenants:
		if Tutorial.tutorial:
			Signals.tutorialRead.emit()
#		actionsNode._recruitLieutenant()
		var lieutenantName = Decks.availableLieutenants.pop_back()
		
		ui.showChosenLieutenantFromAvailableLieutenantsBox(lieutenantName)
		
		map.lieutenantNameToSpawn = lieutenantName
		
		_on_recruit_lieutenant()
#		canAffordRecruitLieutenants(arcanaCard.player, arcanaCard.cardName)

	for peer in Connection.peers:
		RpcCalls.discardArcanaCard.rpc_id(peer, arcanaCard.cardName, Data.id)
	AudioSignals.castArcana.emit()




func canAffordRecruitLieutenants(playerNr, cardNameToIgnore = ""):
	var player = Data.players[playerNr]
	var arcanaCardsNames = player.arcanaCards
	for cardName in arcanaCardsNames:
		if is_instance_valid(Data.arcanaCardNodes[cardName]):
			if not cardName == cardNameToIgnore:
				var arcanaCard = Data.arcanaCardNodes[cardName]
				arcanaCard.disable()
				if not player.hasEnoughSouls(arcanaCard.cost):
					continue
				var MinorSpell = Decks.MinorSpell
				if arcanaCard.minorSpell == MinorSpell.RecruitLieutenants and Data.player.arcanaCards.size() <= 5:
					arcanaCard.highlight()



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
	
#	if not Connection.dedicatedServer:
#		Connection.peers.append(1)
#	print("started hosting")
#	Connection.network.create_server(Connection.port)
#	multiplayer.multiplayer_peer = Connection.network
#	Connection.network.peer_connected.connect(func(id): peer_connected(id))
#	Data.id = multiplayer.get_unique_id()
#	$UI/NetworkHBoxContainer/StartButton.disabled = false
#	%NetworkHBoxContainer.hide()
#	ui.start()
#	_on_start_button_pressed()
#	map.addSpawner(Data.id)
#	add_player_character()


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
	
#	ui.start()
#	Connection.network.create_client("localhost", Connection.port)
#	multiplayer.network = Connection.network
#	Data.id = multiplayer.get_unique_id()

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
#	for peer in Connection.peers:
#		map.addSpawner.rpc_id(peer, peer)
#	print("peers ",Connection.peers)
#	if loadSaveGame:
#		Save.loadGame()
#		setupSaveGame(Connection.peers)
#	else:
#		setup(Connection.peers)
#	ui.start()




func _on_recruiting():
#	Signals.toggleBuyArcanaCardButtonEnabled.emit(false)
	Signals.toggleRecruitLegionsButtonEnabled.emit(false)
#	var arcanaCardsNames = Data.player.arcanaCards
#	for cardName in arcanaCardsNames:
#		Data.arcanaCardNodes[cardName].disable()


func _on_recruitingDone():
	Signals.toggleEndPhaseButton.emit(true)
	for sectioName in Data.player.sectiosWithoutEnemies:
		Decks.sectioNodes[sectioName].changeClickable(false)
	Data.player.checkPlayerSummoningCapabilities(0)


func _on_recruit_legions():
	Signals.recruiting.emit()
	Data.changeState(Data.States.RECRUITING)
	
	if Data.player.sectiosWithoutEnemiesLeft.size() > 0:
		for sectioName in Data.player.sectiosWithoutEnemiesLeft:
			Decks.sectioNodes[sectioName].changeClickable(true)
	else:
		Data.player.sectiosWithoutEnemiesLeft = Data.player.sectiosWithoutEnemies.duplicate()
		for sectioName in Data.player.sectiosWithoutEnemiesLeft:
			Decks.sectioNodes[sectioName].changeClickable(true)
	
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
			
			if Data.player.sectiosWithoutEnemiesLeft.size() > 1:
				Data.player.sectiosWithoutEnemiesLeft.erase(sectio.sectioName)
				Decks.sectioNodes[sectio.sectioName].changeClickable(false)
			else:
				Data.player.sectiosWithoutEnemiesLeft = Data.player.sectiosWithoutEnemies.duplicate()
				for sectioName in Data.player.sectiosWithoutEnemiesLeft:
					Decks.sectioNodes[sectioName].changeClickable(true)
			Signals.tutorialRead.emit()
	
	Data.changeState(Data.States.IDLE)
	Signals.recruitingDone.emit()


func _on_recruit_lieutenant():
	Signals.recruiting.emit()
	Signals.toggleEndPhaseButton.emit(false)
	Signals.toggleBuyArcanaCardButtonEnabled.emit(false)
	
	for sectio in Data.player.sectiosWithoutEnemies:
		if not Decks.sectioNodes[sectio].clickable:
			Decks.sectioNodes[sectio].changeClickable(true)
	
	var sectio = await Signals.sectioClicked
	
	map.placeUnit(sectio, Data.id, Data.UnitType.Lieutenant)
	
	if not Data.player.hasEnoughSouls(3):
		for sectioName in Data.player.sectiosWithoutEnemies:
			Decks.sectioNodes[sectioName].changeClickable(false)
	else:
		var sectiosNotAvailable = Data.player.sectiosWithoutEnemies.duplicate()
		for sectioName in Data.player.sectiosWithoutEnemiesLeft:
			sectiosNotAvailable.erase(sectioName)
		for sectioName in Data.player.sectiosWithoutEnemiesLeft:
			Decks.sectioNodes[sectioName].changeClickable(true)
		for sectioName in sectiosNotAvailable:
			Decks.sectioNodes[sectioName].changeClickable(false)
			
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
