extends Node


func phase(ui : UI):
	if Tutorial.tutorial:
		addTutorialDemons()
		Signals.collapseDemonCards.emit()
		spawnTutorialUnits()
		occupyTutorialSectios()
		
	for peer in Connection.peers:
		ui.updateRankTrackCurrentPlayer.rpc_id(peer, 0)
	
	var soulSummary : Dictionary = setupSoulSummary()
	
	for demon in Data.demons.values():
		if not demon.incapacitated:
			if demon.onEarth:
				soulSummary = collectFavorOnEarth(demon, soulSummary)
				soulSummary = gatherSoulsOnEarth(demon, soulSummary)
	
	for playerId in Data.players:
		soulSummary = await gatherSoulsInHell(playerId, soulSummary)

	for playerId in Data.players:
		soulSummary = payUnits(playerId, soulSummary)
	
	for peer in Connection.peers:
		print("send soul summary")
		RpcCalls.sendSoulSummary.rpc_id(peer, soulSummary)
	
	for triumphirate in Connection.peers:
		await Signals.doneGatheringSouls
	
	if Tutorial.tutorial:
		await get_tree().create_timer(0.1).timeout
		Signals.returnToMainMenu.emit()
		await Signals.tutorialRead


func addTutorialDemons() -> void:
	var nr : String
	for playerId in Data.players:
		if playerId == Data.id:
			nr = Decks.getSpecificCard("demon", "Gomory") #38
			for peer in Connection.peers:
				RpcCalls.addDemon.rpc_id(peer, playerId, nr)
			for peer in Connection.peers:
				RpcCalls.demonStatusChange.rpc_id(peer, 38, "earth")


func spawnTutorialUnits() -> void:
	for playerId in Data.players:
		if playerId == Data.id:
			Signals.spawnUnit.emit("Megalomaniacs", playerId, Data.UnitType.Legion)
		else:
			Signals.spawnUnit.emit("Idolaters", playerId, Data.UnitType.Legion)


func occupyTutorialSectios() -> void:
	var sectio : Sectio = Decks.sectioNodes["Megalomaniacs"]
	for peer in Connection.peers:
		RpcCalls.occupySectio.rpc_id(peer, Data.id, sectio.sectioName)
	sectio = Decks.sectioNodes["Idolaters"]
	for peer in Connection.peers:
		RpcCalls.occupySectio.rpc_id(peer, Data.id, sectio.sectioName)
	sectio = Decks.sectioNodes["Snake Eyes Saloon"]
	for peer in Connection.peers:
		RpcCalls.occupySectio.rpc_id(peer, Data.id, sectio.sectioName)


func setupSoulSummary() -> Dictionary:
	var soulSummary : Dictionary = {}
	for playerId in Data.players:
		soulSummary[playerId] = {"earth" : {}, "hell" : {}, "payment" : {}}
	return soulSummary


func collectFavorOnEarth(demon : Demon, soulSummary : Dictionary) -> Dictionary:
	var player = Data.players[demon.player]
	soulSummary[player.playerId]["earth"][demon.demonName] = {"favors" : 0, "souls": 0, "rank": demon.rank}
	# gather Favors on earth
	if Dice.disfavorRoll(player.disfavors):
		var favors = Data.players[player.playerId].favors + 1
		favors = clamp(favors, 0, 20)
		Signals.changeFavors.emit(player.playerId, favors)
		soulSummary[player.playerId]["earth"][demon.demonName]["favors"] = 1
		print(demon.demonName, " earned a Favor on Earth")
	else:
		print(demon.demonName, " failed the disfavor roll")
	return soulSummary


func gatherSoulsOnEarth(demon : Demon, soulSummary : Dictionary) -> Dictionary:
	var player : Player = Data.players[demon.player]
	var result = Dice.roll(1)
	var soulsGathered = 0
	soulsGathered += result[0]
	soulsGathered += demon.hearts
	soulsGathered = clamp(soulsGathered, 0, 100)
	var souls = player.souls + soulsGathered
	#if player.playerId == Data.id:
		#Signals.emitSoulsFromCollectionPosition.emit(sectioName, soulsGathered)
	Signals.changeSouls.emit(player.playerId, souls)
	#if player.playerId == Data.id:
		#Signals.changeSoulsInUI.emit(souls)
	soulSummary[player.playerId]["earth"][demon.demonName]["souls"] = soulsGathered
	print(demon.demonName, " gathered ", soulsGathered, " Souls on Earth")
	return soulSummary


func gatherSoulsInHell(playerId : int, soulSummary : Dictionary) -> Dictionary:
	var player = Data.players[playerId]
	var soulsGatheredTotal = 0
	
	for sectioName in player.sectios:
		if enemyInSectio(sectioName, playerId):
			soulSummary[player.playerId]["hell"][sectioName] = {"isolated" : false, "souls": 0, "enemyInSectio": true}
		else:
			gatherSoulsForSectio(sectioName, playerId, soulSummary)
			#gatherSoulsForSectio1(sectioName, playerId, soulSummary)
			#if sectioName == "The Wise Men":
				#getArcanaCardsForTheWiseMen(player.playerId)
	return soulSummary


func gatherSoulsForSectio1(sectioName : String, playerId : int, soulSummary : Dictionary):
	var player = Data.players[playerId]
	var sectio = Decks.sectioNodes[sectioName]
	var isIsolated = sectio.isolated()
	var soulsGathered = sectio.souls
	# check for hellhounds in sectio as well!! hellhounds  hellhounds  hellhounds  hellhounds  hellhounds  hellhounds 
	if isIsolated:
		soulsGathered -= 2
	soulsGathered = clamp(soulsGathered, 0, 100)
	var souls = player.souls + soulsGathered
	if playerId == Data.id:
		Signals.emitSoulsFromCollectionPosition.emit(sectio.get_global_transform_with_canvas().origin, soulsGathered)


func gatherSoulsForSectio(sectioName : String, playerId : int, soulSummary : Dictionary) -> Dictionary:
	var player = Data.players[playerId]
	var sectio = Decks.sectioNodes[sectioName]
	var isIsolated = sectio.isolated()
	var soulsGathered = sectio.souls
	# check for hellhounds in sectio as well!! hellhounds  hellhounds  hellhounds  hellhounds  hellhounds  hellhounds 
	if isIsolated:
		soulsGathered -= 2
	soulsGathered = clamp(soulsGathered, 0, 100)
	var souls = player.souls + soulsGathered
	Signals.changeSouls.emit(playerId, souls)
	soulSummary[player.playerId]["hell"][sectioName] = {"isolated" : isIsolated, "souls": soulsGathered,  "enemyInSectio": false}
	return soulSummary


func enemyInSectio(sectioName : String, playerId : int) -> bool:
	var enemyInSectio : bool = false
	for unitName in Decks.sectioNodes[sectioName].troops:
		if not Data.troops[unitName].triumphirate == playerId:
			enemyInSectio = true
			break
	return enemyInSectio


func getArcanaCardsForTheWiseMen(playerId : int) -> void:
	var result = Dice.roll(1)
	for i in result[0]:
		var cardName : String = Decks.getRandomCard("arcana")
		for peer in Connection.peers:
			RpcCalls.addArcanaCard.rpc_id(peer, playerId, cardName)


func payUnits(playerId : int, soulSummary : Dictionary) -> Dictionary:
	var player = Data.players[playerId]
	var soulsPaid = 0
	for unitName in player.troops:
		var unit = Data.troops[unitName]
		if not unit.unitType == Data.UnitType.Hellhound:
			soulSummary[player.playerId]["payment"][unitName] = {"paid" : 1}
			soulsPaid += 1
	var souls = player.souls - soulsPaid
	Signals.changeSouls.emit(playerId, souls)
	return soulSummary

