extends Node


func phase(combatWinner : Dictionary, ui):
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
	
	if Tutorial.tutorial:
		Signals.tutorial.emit(Tutorial.Topic.Combat, "Notice, the winner of the Battle will occupy the Sectio for free.")
		await Signals.tutorialRead
		
		Signals.tutorial.emit(Tutorial.Topic.Combat, "Now use the menu to the left to pick the Sectio you want to capture.")
		await Signals.tutorialRead
	
	for triumphirate in petitionSectiosByTriumphirate:
		if Connection.peers.has(triumphirate):
			for peer in Connection.peers:
				ui.updateRankTrackCurrentPlayer.rpc_id(peer, triumphirate)
			RpcCalls.petitionSectiosRequest.rpc_id(triumphirate, petitionSectiosByTriumphirate[triumphirate])
			await Signals.petitionConfirmed
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
	if Tutorial.tutorial:
		Signals.tutorial.emit(Tutorial.Topic.Combat, "You have no more Favors left, and cannot occupy the last Sectio.")
		await Signals.tutorialRead
		await get_tree().create_timer(0.1).timeout
		Signals.returnToMainMenu.emit()
		await Signals.tutorialRead
