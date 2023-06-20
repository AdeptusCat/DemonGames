extends Node


const playerScene = preload("res://player.tscn")
const demonScene = preload("res://demon.tscn")


@rpc("any_peer", "call_local")
func peerReady():
	var playerId = multiplayer.get_remote_sender_id()
	Connection.playerReady(playerId)


@rpc ("any_peer", "call_local")
func startCombat(unitNames : Dictionary, sectioName : String):
	Signals.hightlightCombat.emit(unitNames, sectioName)


@rpc ("any_peer", "call_local")
func endCombat():
	Signals.endCombat.emit()


@rpc ("any_peer", "call_local")
func showCombat():
	Signals.showCombat.emit()


@rpc ("any_peer", "call_local")
func hideCombat():
	Signals.hideCombat.emit()


@rpc ("any_peer", "call_local")
func unitsAttack():
	Signals.unitsAttack.emit()


@rpc ("any_peer", "call_local")
func unitsHit(unitNamesDict : Dictionary):
	Signals.unitsHit.emit(unitNamesDict)


@rpc ("any_peer", "call_local")
func unitsKilled(unitNamesDict : Dictionary):
	Signals.unitsKilled.emit(unitNamesDict)


@rpc("any_peer", "call_local")
func combatPhase():
	Signals.combatPhaseStarted.emit()


@rpc("any_peer", "call_local")
func combatOver():
	Signals.combatOver.emit()


@rpc ("any_peer", "call_local")
func resetCamera():
	Signals.resetCamera.emit()


@rpc ("any_peer", "call_local")
func moveCamera(_position : Vector2):
	Signals.moveCamera.emit(_position)


@rpc ("any_peer", "call_local")
func sendSectiosWithoutEnemies(sectioNames : Array):
	# this is stupid. you cant pass a typed array properly without doing this shit
#	var sectioNamesTyped : Array[String] = []
#	for sectioName in sectioNames:
#		sectioNamesTyped.append(sectioName)
	Data.player.sectiosWithoutEnemies = sectioNames


@rpc ("any_peer", "call_local")
func win(playerId):
	if playerId == Data.id:
		Signals.win.emit(true, playerId)
	else:
		Signals.win.emit(false, playerId)


@rpc ("any_peer", "call_local")
func petitionSectiosRequest(sectioNames : Array):
	Signals.populatePetitionsContainer.emit(sectioNames)


@rpc ("any_peer", "call_local")
func toogleBuyLieutenant(boolean : bool):
	Signals.toogleBuyLieutenant.emit(boolean)


@rpc ("any_peer", "call_local")
func toogleWaitForPlayer(playerId, boolean : bool, phase = null):
	Signals.toogleWaitForPlayer.emit(playerId, boolean, phase)


@rpc ("any_peer", "call_local")
func toogleTameHellhound(boolean : bool):
	Signals.toogleTameHellhoundContainer.emit(boolean)


@rpc("any_peer", "call_local")
func occupySectio(id : int, sectio):
	var formerPlayerId = Decks.sectioNodes[sectio].player
	if not formerPlayerId == 0:
		Data.players[formerPlayerId].sectios.erase(sectio)
	
	Decks.sectioNodes[sectio].player = id
	Data.players[id].addSectio(sectio)
	
	if Data.id == Connection.host:
		Signals.incomeChanged.emit(id)
	
	if not Connection.dedicatedServer:
		Decks.sectioNodes[sectio].changeColor(id)
	
	if not Data.id == id and not Connection.dedicatedServer:
		Data.player.sectios.erase(sectio)


@rpc("any_peer", "call_local")
func addArcanaCard(id, cardName):
	var player : Player = Data.players[id]
	player.addArcanaCard(cardName)
	# strip edges to get rid of the 'space' right of the name
	# this was used in the naming of the card
	# to be able to habe multiple cards of the same type
	# weird huh
	var cardReference : Dictionary = Decks.arcanaCardsReference[cardName.strip_edges(false, true)]
	# add only the cardName : cardReference to the dict, 
	# and overwrite the dict for the actual player with 
	# cardName : cardNode
	# otherwise you would instantiate the card for the server 
	# which is too much overhead
	# also every card needs a unique name
	# some cards are twice in the game
	# solution is to give the second card a whitespace at the end
	# this gets removed with 'strip_edges' if the referenceCard is needed
	var newCardReference : Dictionary = {}
	for key in cardReference:
		newCardReference[key] = int(cardReference[key])
	Data.arcanaCards[cardName] = newCardReference
	if Data.id == id:
		Signals.addArcanaCardToUi.emit(id, cardName)
		if Data.phase == Data.phases.Summoning:
			player.canAffordRecruitLieutenants()
		if not Data.phase == null and not Data.phase == 0:
			checkEndPhaseCondition()


@rpc("any_peer", "call_local")
func checkEndPhaseCondition():
	if Data.player.arcanaCards.size() > 5:
		Data.player.discardModeArcanaCard()
		Signals.toggleDiscardArcanaCardControl.emit(true)
		Signals.toggleEndPhaseButton.emit(false)
		
		for cardName in Data.player.arcanaCards:
			Data.arcanaCardNodes[cardName].disable()
		Signals.toggleRecruitLegionsButtonEnabled.emit(false)
	else:
		Data.player.checkPlayerSummoningCapabilities()
		Signals.toggleDiscardArcanaCardControl.emit(false)
		Signals.toggleEndPhaseButton.emit(true)
		

@rpc("any_peer", "call_local")
func updatePhaseLabel(phase, phaseText):
	Data.phase = phase
	Signals.phaseReminder.emit(phaseText)
	Signals.phaseDescription.emit(phase, phaseText)


@rpc("any_peer", "call_local")
func hightlightArcanaCard(cardName):
	Data.arcanaCardNodes[cardName].highlight()


@rpc("any_peer", "call_local")
func disableArcanaCard(cardName):
	if Data.arcanaCardNodes[cardName]:
		Data.arcanaCardNodes[cardName].disable()

@rpc("any_peer", "call_local")
func nextDemon(demonRank):
	Signals.nextDemon.emit(demonRank)


@rpc("any_peer", "call_local")
func phaseStart(phase : Data.phases):
	if phase == Data.phases.Summoning:
	#	Signals.toogleBuyLieutenant.emit(true)
		Signals.toogleTameHellhoundContainer.emit(true)
		Signals.toogleBuyLieutenant.emit(true)
		RpcCalls.checkEndPhaseCondition()
	#	toogleBuyArcanaCard(true)
		Data.player.checkPlayerSummoningCapabilities(0)
		Signals.toogleSummoningMenu.emit(true)
		Signals.toggleEndPhaseButton.emit(true)
		Data.player.sectiosWithoutEnemiesLeft = Data.player.sectiosWithoutEnemies.duplicate()
		
		Signals.help.emit(Data.HelpSubjects.SummoningPhase)


@rpc ("any_peer", "call_local")
func sendSoulSummary(soulSummary : Dictionary):
	if Settings.skipSoulsSummary:
		await get_tree().create_timer(1.0).timeout
		doneGatheringSouls.rpc_id(Connection.host)
		return
	
	if Tutorial.tutorial:
		Signals.tutorial.emit(Tutorial.Topic.Phase, "This is the Soul Phase, where: \n1. Arcana Cards are filled up to five Cards \n2. Receive Souls for owning Sectios \n3. Demons on Earth are collecting Souls and a Favor")
		await Signals.tutorialRead
	else:
		await Signals.phaseReminderDone
	Signals.showSoulsSummary.emit(soulSummary)
	
	Signals.expandDemonCards.emit()
	for demonName in soulSummary[Data.id]["earth"]:
		var souls = soulSummary[Data.id]["earth"][demonName]["souls"]
		var favors = soulSummary[Data.id]["earth"][demonName]["favors"]
		var rank = soulSummary[Data.id]["earth"][demonName]["rank"]
		var demon : Demon = Data.demons[rank]
		
		if Tutorial.tutorial:
			Signals.tutorial.emit(Tutorial.Topic.Soul, "'" + demon.demonName + "' is one of your Demons on Earth and gathers Souls and a Favor each Turn. \nThe amount of Souls gathered depends on the amount of Hearts of the Demon.")
			await Signals.tutorialRead
		
		demon.showSoulsGathered(souls, favors)
		await Signals.animationDone
	Signals.collapseDemonCards.emit()
	
	var sectioNr : int = 0
	for sectioName in soulSummary[Data.id]["hell"]:
		var souls = soulSummary[Data.id]["hell"][sectioName]["souls"]
		var sectio : Sectio = Decks.sectioNodes[sectioName]
		Signals.moveCamera.emit(sectio.global_position)
		await Signals.doneMoving
		
		if Tutorial.tutorial:
			match sectioNr:
				0: 
					Signals.tutorial.emit(Tutorial.Topic.Soul, "'" + sectioName + "' is one of your Sectios and generates three Souls each Soul Phase.")
				1:
					Signals.tutorial.emit(Tutorial.Topic.Soul, "In '" + sectioName + "' is an enemy Unit inside, so it generates no Souls until there is no enemy Unit present.")
				2:
					Signals.tutorial.emit(Tutorial.Topic.Soul, "'" + sectioName + "' has no friendly Sectio adjacent. So it generates two Souls less, until it is connected with another friendly Sectio.")
			sectioNr += 1
			await Signals.tutorialRead
		
		sectio.showSoulsGathered(souls)
		await Signals.animationDone
	
	for unitName in soulSummary[Data.id]["payment"]:
		var souls = soulSummary[Data.id]["payment"][unitName]["paid"]
		var unit : Unit = Data.troops[unitName]
		Signals.moveCamera.emit(unit.global_position)
		await Signals.doneMoving
		
		if Tutorial.tutorial:
			Signals.tutorial.emit(Tutorial.Topic.Soul, "Every Unit you own costs you one Soul per Turn.")
			await Signals.tutorialRead
		
		unit.showSoulsPaid(souls)
		await Signals.animationDone
	
	Signals.resetCamera.emit()
	print("w1 ",Connection.host)
	doneGatheringSouls.rpc_id(Connection.host)





@rpc ("any_peer", "call_local")
func doneGatheringSouls():
	Signals.doneGatheringSouls.emit()


@rpc("any_peer", "call_local")
func proceed():
	Signals.proceedSignal.emit()


@rpc("any_peer", "call_local")
func showStartScreen():
	if Settings.skipScreens:
		RpcCalls.proceed.rpc_id(Connection.host)
		return
	Signals.showStartScreen.emit()


@rpc("any_peer", "call_local")
func showArcanaCardsContainer():
	Signals.showArcanaCardsContainer.emit()


@rpc("any_peer", "call_local")
func showPlayerStatusMarginContainer():
	Signals.showPlayerStatusMarginContainer.emit()


@rpc("any_peer", "call_local")
func showRankTrackMarginContainer():
	Signals.showRankTrackMarginContainer.emit()



@rpc("any_peer", "call_local")
func updateRankTrack(newRankTrack):
	print("rank track ",newRankTrack)
	# weird savegame loading int as float
	var arr : Array = []
	for rank in newRankTrack:
		arr.append(int(rank))
	Signals.updateRankTrack.emit(arr)


@rpc("any_peer", "call_local")
func pickDemonForCombat():
	await get_tree().create_timer(1).timeout
	Data.pickDemon = true
	Signals.expandDemonCards.emit()
	AudioSignals.battleStart.emit()
	
	Signals.help.emit(Data.HelpSubjects.PickDemonForCombat)


@rpc("any_peer", "call_local")
func pickedDemonForCombat(demonRank : int):
	Signals.pickedDemonInGame.emit(demonRank)


@rpc("any_peer", "call_local")
func petitionsDone():
	Signals.petitionConfirmed.emit()


@rpc("any_peer", "call_local")
func discardArcanaCard(arcanaCardName, playerId):
	var player = Data.players[playerId]
	player.arcanaCards.erase(arcanaCardName)


@rpc("any_peer", "call_local")
func recruitedLieutenant():
	var lieutenantName = Decks.getRandomCard("lieutenant")
	if lieutenantName:
		for peer in Connection.peers:
			fillAvailableLieutenantsBox.rpc_id(peer, lieutenantName)


@rpc("any_peer", "call_local")
func confirmPetition(boolean):
	if boolean:
		var playerId = multiplayer.get_remote_sender_id()
		var favors = Data.players[playerId].favors - 1
		Signals.changeFavors.emit(playerId, favors)


@rpc("any_peer", "call_local")
func fillAvailableLieutenantsBox(lieutenantName : String):
	Decks.availableLieutenants.append(lieutenantName)
	Decks.availableLieutenants.shuffle()
	Signals.addLieutenantToAvailableLieutenantsBox.emit(lieutenantName)


@rpc("any_peer", "call_local")
func phaseEnd(phase : Data.phases):
	if phase == Data.phases.Summoning:
		Signals.toogleSummoningMenu.emit(false)
		Signals.toogleTameHellhoundContainer.emit(false)
		Signals.toogleBuyLieutenant.emit(false)
		for cardName in Data.player.arcanaCards:
			var arcanaCard = Data.arcanaCards[cardName]
			var MinorSpell = Decks.MinorSpell
			if arcanaCard.minorSpell == MinorSpell.RecruitLieutenants:
				RpcCalls.disableArcanaCard(cardName)
		for sectio in Data.player.sectios:
			sectio = sectio as String
			Decks.sectioNodes[sectio].changeClickable(false)


@rpc("any_peer", "call_local")
func requestArcanaCardsToPick():
	var playerId = multiplayer.get_remote_sender_id()
	var cardNames = []
	if Tutorial.tutorial:
		cardNames.append(Decks.getSpecificCard("arcana", "A Deliberate Mistake"))
		cardNames.append(Decks.getSpecificCard("arcana", "A Minor Change"))
		cardNames.append(Decks.getSpecificCard("arcana", "Call for Lilith"))
	else:
		for i in range(3):
			var cardName : String = Decks.getRandomCard("arcana")
			cardNames.append(cardName)
	for cardName in Data.player.arcanaCards:
		Data.arcanaCardNodes[cardName].disable()
	fillPickArcanaCardsContainer.rpc_id(playerId, cardNames)


@rpc("any_peer", "call_local")
func fillPickArcanaCardsContainer(cardNames : Array):
	Signals.fillPickArcanaCardsContainer.emit(cardNames)


@rpc("any_peer", "call_local")
func requestNewDemon(playerId : int, oldDemonRank : int):
	Data.players[playerId].favors = Data.players[playerId].favors - 1
	var nr : String = Decks.getRandomCard("demon")
	for peer in Connection.peers:
		removeDemon.rpc_id(peer, playerId, oldDemonRank)
		addDemon.rpc_id(peer, playerId, nr)


@rpc("any_peer", "call_local")
func addDemon(id : int, DemonName : String, savegame : Dictionary = {}):
	var player = Data.players[id]
	var demon = demonScene.instantiate()
	demon.stats = load("res://demons/" + DemonName)
	demon.loadStats()
	player.addDemon(demon.stats.rank)
	Data.demons[demon.rank] = demon
	Signals.addDemon.emit(demon.stats.rank)
	print(Data.id, " adding demon ", demon.rank)
	demon.player = id
	if savegame.size() > 0:
		demon.loadGame(savegame)
	if Data.id == id:
		Signals.addDemonToUi.emit(demon)
		demon.scale = Vector2(0.6, 0.6)


@rpc("any_peer", "call_local")
func demonStatusChange(demonRank, statusName):
	match statusName:
		"earth":
			Data.demons[demonRank].onEarth = true
		"hell":
			Data.demons[demonRank].onEarth = false
		"incapacitated":
			Data.demons[demonRank].incapacitated = true
		"recovered":
			Data.demons[demonRank].incapacitated = false
	Signals.updateRankTrack.emit([])


@rpc("any_peer", "call_local")
func removeDemon(playerId : int, demonRank : int):
	print("erasing demon ")
	Data.players[playerId].removeDemon(demonRank)
	Signals.removeDemon.emit(demonRank)
	Data.demons.erase(demonRank)


@rpc("any_peer", "call_local")
func changePlayerName(id, playerName):
	Data.players[id].playerName = playerName
	Signals.changePlayerDisplayValue.emit(id, "name", playerName)
	if Data.id == id:
		Data.player.playerName = playerName
		Signals.changePlayerName.emit(playerName)


@rpc("any_peer", "call_local")
func changeColor(id, colorName : String):
	var color : Color = Data.colors[colorName]
	print("color_type ",color)
	Data.players[id].color = color
	Data.players[id].colorName = colorName
	if Data.id == id:
		Data.player.color = color
		Data.player.colorName = colorName
#		%PlayerColorRect.color = color
		Signals.buildCircles.emit()


@rpc("any_peer", "call_local")
func initMouseLights():
	Signals.initMouseLights.emit()


@rpc("any_peer", "call_local")
func addPlayer(id, savegame : Dictionary = {}):
	Signals.createPlayerDisplayLine.emit(id)
	Signals.initSectios.emit()
	var scene = playerScene.instantiate()
#	print("init player ",id)
	scene.name = str(id)
	Signals.addPlayer.emit(scene)
	print("init player ",id, " ",scene.name)
	if savegame.size() > 0:
		scene.loadGame(savegame)
	Data.players[id] = scene
	if Data.id == id:
		Data.player = scene


@rpc("any_peer", "call_local")
func followUnit(unitNr):
	var unit = Data.troops[unitNr]
	Signals.followUnit.emit(unit)


@rpc("any_peer", "call_local")
func stopFollowingUnit(unitNr):
	var unit = Data.troops[unitNr]
	Signals.stopFollowingUnit.emit(unit)


@rpc("any_peer", "call_local")
func demonAction(demonRank : int, action : String):
	Signals.action.emit(demonRank, action)


@rpc("any_peer", "call_local")
func updateTurnTrack(turn : int):
	Signals.updateTurnTrack.emit(turn)
