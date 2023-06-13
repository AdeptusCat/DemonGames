extends Node


func phase(phase : int, ui : UI):
	if Tutorial.tutorial:
		await tutorialSetup()
	
	# sort players by souls
	var playersSortedBySouls : Array = sortPlayersBySouls()
	
	for playerId in playersSortedBySouls:
		for peer in Connection.peers:
			ui.updateRankTrackCurrentPlayer.rpc_id(peer, playerId)
		
		if Tutorial.tutorial:
			await tutorial1()
		
		if Connection.isAiPlayer(playerId):
			var player = Data.players[playerId]
			Data.currentAiPlayer = player
			var arcanaCardsNames = player.arcanaCards
			var recruitLieutenantCards : Array = []
			for cardName in arcanaCardsNames:
				var arcanaCard = Data.arcanaCards[cardName]
				if arcanaCard:
					if not player.hasEnoughSouls(arcanaCard.cost):
						continue
					var MinorSpell = Decks.MinorSpell
					if arcanaCard.minorSpell == MinorSpell.RecruitLieutenants:
						recruitLieutenantCards.append(arcanaCard)
			Ai.worldStates[playerId].set_state("recruitLieutenantCards", recruitLieutenantCards)
#					WorldState.set_state("recruitLieutenantCards", recruitLieutenantCards)
			
			var lieutenants : Array = []
			for unitName in player.troops:
				var unit = Data.troops[unitName]
				if unit.unitType == Data.UnitType.Lieutenant:
					lieutenants.append(unit)
			Ai.worldStates[playerId].set_state("lieutenants", lieutenants)
#					WorldState.set_state("lieutenants", lieutenants)
			
			var sectiosWithoutEnemies : Array = Sectios.getSectiosWithoutEnemies(player.sectios, playerId)
			player.sectiosWithoutEnemies = sectiosWithoutEnemies.duplicate()
			player.sectiosWithoutEnemiesLeft = sectiosWithoutEnemies.duplicate()
			
			var agent = GoapAgent.new()
			agent.init(self, [
				HasMoreLegionsGoal.new(),
				EndPhaseGoal.new()
			])
			add_child(agent)
			
			await agent.finish_phase()
			agent.queue_free()
			continue
		
		var player = Data.players[playerId]
		if Tutorial.tutorial:
			setupTutorialArcanaCards(player)
		
		if hasLegionInAnteHell(player.troops):
			RpcCalls.toogleTameHellhound.rpc_id(playerId, true)
		
		var sectiosWithoutEnemies : Array = Sectios.getSectiosWithoutEnemies(player.sectios, playerId)
		RpcCalls.sendSectiosWithoutEnemies.rpc_id(playerId, sectiosWithoutEnemies)
		
		highlightAffordableLieutenantCards(player)
		
		for peer in Connection.peers:
			RpcCalls.toogleWaitForPlayer.rpc_id(peer, playerId, true, phase)
		RpcCalls.phaseStart.rpc_id(playerId, Data.phases.Summoning)
		
		if Tutorial.tutorial:
			await tutorial2()
		
		await Signals.phaseDone
		
		if Tutorial.tutorial:
			await tutorialEnd()
		
		RpcCalls.phaseEnd.rpc_id(playerId, Data.phases.Summoning)
		for peer in Connection.peers:
			RpcCalls.toogleWaitForPlayer.rpc_id(peer, playerId, false)


func occupyTutorialSectios() -> void:
	var sectio : Sectio = Decks.sectioNodes["Megalomaniacs"]
	for peer in Connection.peers:
		RpcCalls.occupySectio.rpc_id(peer, Data.id, sectio.sectioName)
	sectio = Decks.sectioNodes["Idolaters"]
	for peer in Connection.peers:
		RpcCalls.occupySectio.rpc_id(peer, Data.id, sectio.sectioName)


func sortPlayersBySouls() -> Array:
	var players = Data.players.duplicate()
	var soulsPerPlayer : Array = []
	var playersSortedBySouls : Array = []
	while players.size() > 0:
		var souls : int = 0
		var richestPlayer
		for playerId in players:
			var player = Data.players[playerId]
			if player.souls >= souls:
				souls = player.souls
				richestPlayer = playerId
		playersSortedBySouls.append(richestPlayer)
		players.erase(richestPlayer)
	return playersSortedBySouls


func setupTutorialArcanaCards(player : Player) -> void:
	var cardsToDraw : int = 5 - player.arcanaCards.size()
	var cardNames : Array = ["Reincarnation", "Rotten Sweetness", "Sisyphus' Rock", "The Frenzied Feeder", "The Shaker"]
	for i in range(cardsToDraw):
		var CardName : String = Decks.getSpecificCard("arcana", cardNames.pop_back())
		for peer in Connection.peers:
			RpcCalls.addArcanaCard.rpc_id(peer, player.playerId, CardName)


func hasLegionInAnteHell(unitNames : Dictionary) -> bool:
	var hasLegionInAnteHell : bool = false
	for unitName in unitNames:
			var unit = Data.troops[unitName]
			if unit.occupiedCircle == 9 and unit.unitType == Data.UnitType.Legion:
				hasLegionInAnteHell = true
				break
	return hasLegionInAnteHell


func highlightAffordableLieutenantCards(player : Player):
	var arcanaCardsNames = player.arcanaCards
	if player.arcanaCards.size() <= 5:
		for cardName in arcanaCardsNames:
			var arcanaCard = Data.arcanaCards[cardName]
			if arcanaCard:
				if not player.hasEnoughSouls(arcanaCard.cost):
					continue
				var MinorSpell = Decks.MinorSpell
				if arcanaCard.minorSpell == MinorSpell.RecruitLieutenants and Data.player.arcanaCards.size() <= 5:
					RpcCalls.hightlightArcanaCard.rpc_id(player.playerId, cardName)


func tutorialSetup():
	Signals.changeSouls.emit(Data.id, 42)
	occupyTutorialSectios()
	Signals.tutorial.emit(Tutorial.Topic.Phase, "This is the Summoning Phase. \nHere you will be able to recruit Units like Legions and Lieutenants or buy Arcana Cards.")
	await Signals.tutorialRead


func tutorial1():
	Signals.tutorial.emit(Tutorial.Topic.PlayerStatus, "The Player with the most Souls will summon first. \nThe Souls owned by the Players can be observed here.")
	await Signals.tutorialRead

	Signals.tutorial.emit(Tutorial.Topic.CurrentPlayer, "The Player that is currently summoning is displayed here.")
	await Signals.tutorialRead


func tutorial2():
	Signals.tutorial.emit(Tutorial.Topic.RecruitLegion, "Click the highlighted Button to summon Legions for three Souls each.")
	await Signals.tutorialRead

	Signals.tutorial.emit(Tutorial.Topic.PlaceLegion, "Click on a highlighted Sectio to place a Legion. \nYou can place Legions only in Sectio that you own and that have no enemy Units inside.")
	await Signals.tutorialRead

	Signals.tutorial.emit(Tutorial.Topic.PlaceLegionTwice, "Notice that you have to place a Legions in each Sectio you own, bevore you can place another Legion in the same Sectio.")
	await Signals.tutorialRead

	Signals.tutorial.emit(Tutorial.Topic.RecruitLieutenantAttempt, "To summon a Lieutenant, you need the appropriate Arcana Card. \nIt seems you dont have the right Arcana Card.")
	await Signals.tutorialRead

	Signals.tutorial.emit(Tutorial.Topic.BuyArcanaCard, "Click the highlighted Button to buy one Arcana Card for five Souls.")
	await Signals.tutorialRead

	Signals.tutorial.emit(Tutorial.Topic.PickArcanaCard, "Now pick one of the three shown Arcana Cards that sais 'Recruit Lieutenant'.")
	await Signals.tutorialRead

	Signals.tutorial.emit(Tutorial.Topic.TooManyArcanaCards, "You can only have five Arcana Cards at all times. Click one to discards it. \nNotice, it can also be the one you just bought. But we need still need it so keep it for now.")
	await Signals.tutorialRead

	Signals.tutorial.emit(Tutorial.Topic.RecruitLieutenantCard, "Now you can recruit a Lieutenant by clicking on the Card that sais 'Recruit Lieutenant'.")
	await Signals.tutorialRead

	Signals.tutorial.emit(Tutorial.Topic.PlaceLieutenant, "Now you can place the Lieutenant on a Sectio that you own and where no enemy Unit is.")
	await Signals.tutorialRead

	Signals.tutorial.emit(Tutorial.Topic.EndSummoningPhase, "Great. Now you can end the Summoning Phase by clicking the highlighted Button.")


func tutorialEnd():
	await get_tree().create_timer(0.1).timeout
	Signals.returnToMainMenu.emit()
	await Signals.tutorialRead

