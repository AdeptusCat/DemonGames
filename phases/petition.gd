extends Node


func tutorialStart():
	if Tutorial.tutorial:
		Signals.changeFavors.emit(Data.id, 1)
		for playerId in Data.players:
			if playerId == Data.id:
				Signals.spawnUnit.emit("Thieves", playerId, Data.UnitType.Legion)
				Signals.spawnUnit.emit("Orgastica", playerId, Data.UnitType.Legion)
		
		Signals.tutorial.emit(Tutorial.Topic.Phase, "This is the Petition Phase. \nLegions can capture Sectios that are either neutral or in enemy hands. \nThis will cost a Favor so choose wisely.")
		await Signals.tutorialRead


func tutorial1():
	if Tutorial.tutorial:
		Signals.tutorial.emit(Tutorial.Topic.Combat, "Notice, the winner of the Battle will occupy the Sectio for free.")
		await Signals.tutorialRead
		
		Signals.tutorial.emit(Tutorial.Topic.Combat, "Now use the menu to the left to pick the Sectio you want to capture.")
		await Signals.tutorialRead


func removeWinnersFromPetitionSectios(petitionSectios : Dictionary, combatWinner : Dictionary) -> Dictionary:
	var petitionSectiosByTriumphirate : Dictionary = {}
	for sectioName in petitionSectios:
		# dont ask for a Favor if the sectio was occupied in battle
		if combatWinner.values().has(sectioName):
			continue
		if petitionSectiosByTriumphirate.has(petitionSectios[sectioName]):
			petitionSectiosByTriumphirate[petitionSectios[sectioName]].append(sectioName)
		else:
			petitionSectiosByTriumphirate[petitionSectios[sectioName]] = [sectioName]
	return petitionSectiosByTriumphirate


func getPetitionSectios() -> Dictionary:
	var petitionSectios : Dictionary = {}
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
			if Data.players[playerId].sectios.has(sectio.sectioName):
				petitionSectios.erase(sectio.sectioName)
	return petitionSectios


func phase(combatWinner : Dictionary, ui):
	tutorialStart()
	
	winnersOccupySectios(combatWinner)
	
	tutorial1()
	
	var petitionSectiosWithWinners : Dictionary = getPetitionSectios()
	var petitionSectiosWithoutWinners : Dictionary = removeWinnersFromPetitionSectios(petitionSectiosWithWinners, combatWinner)
	
	await petitions(petitionSectiosWithoutWinners, ui)

	tutorialEnd()


func petitions(petitionSectiosByPlayerId : Dictionary, ui) -> void:
	for playerId in petitionSectiosByPlayerId:
		if not Connection.isAiPlayer(playerId):
			await playerChoosePetitions(playerId, petitionSectiosByPlayerId, ui)
		else:
			aiPlayerChoosePetitions(playerId, petitionSectiosByPlayerId)


func winnersOccupySectios(combatWinner : Dictionary) -> void:
	for winner in combatWinner:
		for peer in Connection.peers:
			RpcCalls.occupySectio.rpc_id(peer, winner, combatWinner[winner])


func aiPlayerChoosePetitions(playerId : int,  petitionSectiosByTriumphirate):
	var player : Player = Data.players[playerId]
	while player.hasFavor():
		var sectioNameToOccupy : String = ""
		for sectioName in petitionSectiosByTriumphirate[playerId]:
			var sectio = Decks.sectioNodes[sectioName]
			var circle : int = Ai.worldStates[playerId].get_state("circle_to_capture")
			if sectio.circle == circle:
				sectioNameToOccupy = sectioName
		petitionSectiosByTriumphirate[playerId].erase(sectioNameToOccupy)
		if not sectioNameToOccupy == "":
			var favors = player.favors - 1
			Signals.changeFavors.emit(playerId, favors)
			for peer in Connection.peers:
				RpcCalls.occupySectio.rpc_id(peer, playerId, sectioNameToOccupy)
		else:
			break


func playerChoosePetitions(playerId : int, petitionSectiosByTriumphirate : Dictionary, ui) -> void:
	for peer in Connection.peers:
		ui.updateRankTrackCurrentPlayer.rpc_id(peer, playerId)
	RpcCalls.petitionSectiosRequest.rpc_id(playerId, petitionSectiosByTriumphirate[playerId])
	await Signals.petitionConfirmed
	for sectio in Decks.sectioNodes.values():
		sectio.changeClickable.rpc_id(playerId, false)


func tutorialEnd() -> void:
	if Tutorial.tutorial:
		Signals.tutorial.emit(Tutorial.Topic.Combat, "You have no more Favors left, and cannot occupy the last Sectio.")
		await Signals.tutorialRead
		await get_tree().create_timer(0.1).timeout
		Signals.returnToMainMenu.emit()
		await Signals.tutorialRead
