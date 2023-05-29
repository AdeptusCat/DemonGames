extends Node


func tutorialStart(rankTrack, rankTrackNode) -> void:
	var cardNames : Array = ["Rotten Sweetness", "Sisyphus' Rock", "The Frenzied Feeder", "The Shaker"]
	var cardsToDraw : int = cardNames.size()
	for i in range(cardsToDraw):
		var CardName : String = Decks.getSpecificCard("arcana", cardNames.pop_back())
		for peer in Connection.peers:
			RpcCalls.addArcanaCard.rpc_id(peer, Data.id, CardName)
	
#		sectio = Decks.sectioNodes["Megalomaniacs"]
#		sectio = Decks.sectioNodes["Bad People"]
	for playerId in Data.players:
		if playerId == Data.id:
			Signals.spawnUnit.emit("Megalomaniacs", playerId, Data.UnitType.Lieutenant, "Dabriel")
			Signals.spawnUnit.emit("Megalomaniacs", playerId, Data.UnitType.Legion)
			Signals.spawnUnit.emit("Megalomaniacs", playerId, Data.UnitType.Legion)
			Signals.spawnUnit.emit("Megalomaniacs", playerId, Data.UnitType.Legion)
			Signals.spawnUnit.emit("Megalomaniacs", playerId, Data.UnitType.Legion)
		else:
#				Signals.spawnUnit.emit("Bad People", playerId, Data.UnitType.Lieutenant, "Shalmaneser")
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
#				nr = Decks.getSpecificCard("demon", "Balban") #35
#				for peer in Connection.peers:
#					RpcCalls.addDemon.rpc_id(peer, playerId, nr)
#				nr = Decks.getSpecificCard("demon", "Xaphan") #59
#				for peer in Connection.peers:
#					RpcCalls.addDemon.rpc_id(peer, playerId, nr)
	for peer in Connection.peers:
		RpcCalls.updateRankTrack.rpc_id(peer, rankTrackNode.rankTrack)
	rankTrack = rankTrackNode.rankTrack.duplicate()
	Signals.collapseDemonCards.emit()
	
	var sectio : Sectio = Decks.sectioNodes["Megalomaniacs"]
	for peer in Connection.peers:
		RpcCalls.occupySectio.rpc_id(peer, Data.id, sectio.sectioName)
	
	Signals.tutorial.emit(Tutorial.Topic.Phase, "This is the Action Phase. \nHere the Demons of the Players will take turns to march Legions through Hell, Walk with them on the Earth or do other feindish things.")
	await Signals.tutorialRead

func tutorial2(tutorialSequence : int, nextDemonRank : int, playerId : int, map) -> void:
	if tutorialSequence == 1:
		for peer in Connection.peers:
			RpcCalls.demonAction.rpc_id(peer, nextDemonRank, "Marching")
		
		Signals.tutorial.emit(Tutorial.Topic.MarchEnemy, "The enemy Demon 'Ashtaroth' chose to use the March Action. Lets see where it will move its Legion to.")
		await Signals.tutorialRead
		
		var sectioToMoveTo : Sectio = Decks.sectioNodes["Megalomaniacs"]
		Ai.worldStates[playerId].set_state("sectio_to_move_to", sectioToMoveTo)
		var player : Player = Data.players[playerId]
		var unitsWithoutPlan : Array = player.troops.values()
		var unit : Unit = unitsWithoutPlan.pop_back()
		var occupiedSectio : Sectio = Decks.sectioNodes[unit.occupiedSectio]
		var path : Array = Astar.astar.get_id_path(occupiedSectio.id, sectioToMoveTo.id)
		print("moving unit start ", unit.occupiedSectio)
		print("moving demon ", nextDemonRank)
		print("moving unit path size ", path.size())
		print("moving unit from1 ", occupiedSectio.sectioName, " to ", sectioToMoveTo.sectioName)
		if path.size() > 1:
			path.pop_front()
			unit.sectiosMoved = 0
			var pathIndex : int = 0
			for sectioId in path:
				print("moving unit moved ", unit.sectiosMoved)
				if unit.sectiosMoved >= unit.maxSectiosMoved:
					break
				if unit.sectiosMoved == 0:
					Data.currentDemon.skullsUsed += 1
				unit.sectiosMoved += 1
				var nextSectio = Astar.sectioIdsNodeDict[sectioId]
				print("moving unit from2 ", occupiedSectio.sectioName, " to ", nextSectio.sectioName)
				Signals.moveUnits.emit([unit], occupiedSectio, nextSectio)
				await unit.arrivedAtDestination
				
				pathIndex += 1
				if pathIndex >= path.size(): 
					print("moving unit done erasing ", unit.unitNr, " from ", unitsWithoutPlan, " true? ", unitsWithoutPlan.has(unit.unitNr))
					unitsWithoutPlan.erase(unit.unitNr)
					print("moving unit done", unit.unitNr, unitsWithoutPlan)
				
				var enemies = 0
				var enemiesFled = 0
				var fleeingConfirmed = false
				for unitNr in nextSectio.troops:
					var nextUnit = Data.troops[unitNr]
					if unitNr == unit.unitNr:
						continue
					if not nextUnit.triumphirate == unit.triumphirate:
						# solitary lieutenant would have to flee automatically
						print("enemy in sectio")
						enemies += 1
						
						Signals.tutorial.emit(Tutorial.Topic.FleePromt, "The enemy Legion entered the 'Megalomaniacs' Sectio, where your Units are. \nYou now have the option to either flee or stay. \nFor the sake of this Tutorial, choose to flee.")
						
						if Connection.peers.has(nextUnit.triumphirate):
							map.promtToFlee.rpc_id(nextUnit.triumphirate, nextUnit.triumphirate, nextSectio.sectioName, occupiedSectio.sectioName)
						else:
							map.promtToFlee.rpc_id(Connection.host, nextUnit.triumphirate, nextSectio.sectioName, occupiedSectio.sectioName)
						
						if Connection.peers.has(nextUnit.triumphirate):
							fleeingConfirmed = await map.fleeConfirmation
							
						fleeingConfirmed = true
						if fleeingConfirmed:
							enemiesFled += 1
			#						%EventDialog.dialog_text = "The Enemy fled."
						print("result of flee ", fleeingConfirmed)
						break
					else:
						print("friend in sectio")
				
				if enemies > 0 and not fleeingConfirmed:
#											map.neightboursClickable(false)
					unitsWithoutPlan.erase(unit.unitNr)
					break
				
				var  troopsRemaining = false
				for troopName in nextSectio.troops:
					var troop = Data.troops[troopName]
					if not troop.triumphirate == unit.triumphirate:
						troopsRemaining = true
					
				if troopsRemaining and fleeingConfirmed:
#											%EventDialog.dialog_text = "The Enemy tried to flee but failed, stopping."
	#				_on_unitMovedMax(closestUnit)3
					unitsWithoutPlan.erase(unit.unitNr)
					break

#										if not troopsRemaining:
#											%EventDialog.dialog_text = "The Enemy fled."
			
				occupiedSectio = nextSectio
	


func tutorial1(tutorialSequence : int) -> void:
	if tutorialSequence == 0:
		Signals.tutorial.emit(Tutorial.Topic.NextDemon, "The first Demon is 'Beelzebub'.")
		await Signals.tutorialRead
		
		Signals.tutorial.emit(Tutorial.Topic.ClickDemonOnRankTrack, "To see in which order the Demons take their actions, \nhover the mouse over the Rank Track to the right. \nHere you see that the current Demon is 'Beelzebub'. \nClick on its name to have a closer look at its Attributes.")
		await Signals.tutorialRead

		Signals.tutorial.emit(Tutorial.Topic.DemonDetails, "On the bottom of the Details Card are the important Attributes: \nThe Skulls show the number of Legions/Lieutenants that can be moved by the Demon. They are also relevant in Combat. \nThe Hearts show the ability to collect Souls/Favors on Earth and influence other Units in Hell. \nThe status shows if the Demon is currently in Hell, on Earth or incapacitated. \nThe Sex symbol next to the Demon's name is relevant for specific Arcana/Hell cards and events. \nThe Rank is relevant to the position of the Demon in the Rank Track at the beginning of the Game. \nClick on the Card to close it.")
		await Signals.tutorialRead

		Signals.tutorial.emit(Tutorial.Topic.PassAction, "On the left you can see the various Actions the Demon can perform. \nSometimes its preferable to make an action after an enemy Demon. \nTo do so, click the Pass Button.")
		await Signals.tutorialRead

		Signals.tutorial.emit(Tutorial.Topic.Pass, "Now cast a Pass Spell by clicking on the Card. \nObserve the Rank Track to see the change in the Order.")
	
	
	if tutorialSequence == 2:
		Signals.tutorial.emit(Tutorial.Topic.NextDemon, "The next Demon is 'Caim'.")
		await Signals.tutorialRead
		
		Signals.tutorial.emit(Tutorial.Topic.WalkTheEarthAttempt, "Having at least one Demon on Earth is important, as it will collect Souls in each Soul Phase. \nTo send a Demon to Earth, you need a 'Walk The Earth' Arcana Card. \nClick the 'Walk The Earth' Button.")
		await Signals.tutorialRead
		
		Signals.tutorial.emit(Tutorial.Topic.WalkTheEarth, "Now you can choose one of the 'Walk The Earth' cards, notice that some are more expensive than others. \nClick on one of them.")
		
	if tutorialSequence == 3:
		Signals.tutorial.emit(Tutorial.Topic.NextDemon, "The next Demon is 'Gomory'.")
		await Signals.tutorialRead
		
		Signals.tutorial.emit(Tutorial.Topic.DoEvilDeeds, "While on Earth, the Demon can also collect Favors, which are needed to capture Sectios. The Demon 'Gomory' is already on Earth. \nClick the 'Do Evil Deeds' Button.")
	
	if tutorialSequence == 4:
		Signals.tutorial.emit(Tutorial.Topic.NextDemon, "Now its 'Beelzebub's turn again.")
		await Signals.tutorialRead
		
		Signals.tutorial.emit(Tutorial.Topic.MarchAction, "The Demon 'Beelzebub' has four Skulls and is therefore good suited to move Units around. \nClick on the 'March' Button.")
		await Signals.tutorialRead
		
		Signals.tutorial.emit(Tutorial.Topic.March, "For the cost a Skull, a Legion can move up to two Sectios. \nLieutenants can move up to three Sectios and can carry other Legions with them for free. \n Click on a (flashing) Sectio with Units in them and select the Unit you want to move. Right Click if you want to cancel/finish the Unit's move. \nTry it out until you have no Skulls left or click the 'End March' Button.")


func getAffordableWalkTheEarthCards(arcanaCardsNames : Array, player : Player) -> Array:
	var affordableWalkTheEarthCardNames : Array = []
	for cardName in arcanaCardsNames:
		var arcanaCard = Data.arcanaCards[cardName]
		if arcanaCard:
			if not player.hasEnoughSouls(arcanaCard.cost):
				continue
			var MinorSpell = Decks.MinorSpell
			if arcanaCard.minorSpell == MinorSpell.WalkTheEarth or arcanaCard.minorSpell == MinorSpell.WalkTheEarthSafely:
				affordableWalkTheEarthCardNames.append(cardName)
	return affordableWalkTheEarthCardNames


func getHeartScoresOfDemons(demonRanks : Array) -> Array:
	var heartScore : Array = []
	for demonRank in demonRanks:
		var demon : Demon = Data.demons[demonRank]
		var score : float = demon.hearts - demon.skulls * 0.25
		heartScore.append(demon.hearts)
	return heartScore


func hasDemonOnEarth(demonRanks : Array) -> bool:
	var hasDemonOnEarth : bool = false
	for demonRank in demonRanks:
		var demon : Demon = Data.demons[demonRank]
		if demon.onEarth:
			hasDemonOnEarth = true
	return hasDemonOnEarth


func getNameOfCheapestCard(cardNames) -> String:
	var cheapestCardName : String = ""
	var minCost : int = 100
	for cardName in cardNames:
		var card : Dictionary = Data.arcanaCards[cardName]
		if card.cost < minCost:
			minCost = card.cost
			cheapestCardName = cardName
	return cheapestCardName


func isDemonWithMaxHeartScore(nextDemonRank : int, demonRanks : Array, heartScore : Array) -> bool:
	var maxHearts : int = heartScore.max()
	var i : int = heartScore.find(maxHearts)
	if Data.demons[demonRanks[i]] == Data.demons[nextDemonRank]:
		return true
	else:
		return false


func sendsDemonToEarth():
	var randomNr : int = randi_range(1, 100)
	if randomNr < 90:
		return true
	else:
		return false


func sendingDemonToEarth(nextDemonRank : int, playerId : int, walkTheEarthCardName : String) -> void:
	for peer in Connection.peers:
		RpcCalls.demonStatusChange.rpc_id(peer, nextDemonRank, "earth")
	Signals.incomeChanged.emit(playerId)
	for peer in Connection.peers:
		RpcCalls.discardArcanaCard.rpc_id(peer, walkTheEarthCardName, playerId)
	for peer in Connection.peers:
		RpcCalls.demonAction.rpc_id(peer, nextDemonRank, "Walk The Earth")


func doEvilDeeds(demon : Demon) -> void:
	var rollResult = Dice.roll(demon.hearts)
	var favorsGathered = 0
	for roll in rollResult:
		if roll >= 6:
			favorsGathered += 1
			var favors = Data.players[demon.player].favors + 1
			Signals.changeFavors.emit(demon.player, favors)
			print(demon, " evil deeds earned a favor on earth")
		else:
			print(demon, " evil deeds didnt earn a favor on earth")
	for peer in Connection.peers:
		RpcCalls.demonAction.rpc_id(peer, demon.rank, "Do Evil Deeds: " + str(favorsGathered))
	Signals.doEvilDeedsResult.emit(demon.player, demon.demonName, favorsGathered)


func getSectioToMoveToInCircle(circle : int, playerId : int) -> Sectio:
	var sectio_to_move_to : Sectio
	for sectioName in Decks.sectioNodes:
		var sectio : Sectio = Decks.sectioNodes[sectioName]
		if not circle == sectio.circle:
			continue
		if sectio.player == playerId:
			continue
		sectio_to_move_to = sectio
		break
	return sectio_to_move_to


func removeUnitsThatCannotMove(unitsWithoutPlan : Dictionary, playerId : int) -> Dictionary:
	var unitsWithoutPlanDuplicate : Dictionary = unitsWithoutPlan.duplicate()
	for friendlyUnitName in unitsWithoutPlanDuplicate:
		var friendlyUnit : Unit = unitsWithoutPlan[friendlyUnitName]
		var sectio : Sectio = Decks.sectioNodes[friendlyUnit.occupiedSectio]
		for unitName in sectio.troops:
			var unit : Unit = Data.troops[unitName]
			if not unit.triumphirate == playerId:
				unitsWithoutPlan.erase(friendlyUnitName)
				break
	return unitsWithoutPlan


#func removeUnitsThatCannotMove(unitsWithoutPlan : Dictionary, sectio : Sectio, playerId : int) -> Dictionary:
#	for unitName in sectio.troops:
#		var unit = Data.troops[unitName]
#		if not unit.triumphirate == playerId:
#			for unitNr in sectio.troops:
#				unitsWithoutPlan.erase(unitNr)
#			break
#	return unitsWithoutPlan


func getQuarterClockwise(quarter : int) -> int:
	var quarterClockwise : int = posmod((quarter + 1), 5)
	return quarterClockwise


func getQuarterCounterclockwise(quarter : int) -> int:
	var quarterCounterclockwise : int = posmod((quarter + 1), 5)
	return quarterCounterclockwise


func getSectioFromCircleAndQuarter(circle, quarter) -> Sectio:
	var sectio : Sectio = Decks.sectios[circle][quarter]
	return sectio


func removeUnitsAlreadyInPosition(unitsWithoutPlan : Dictionary, sectio : Sectio, playerId : int) -> Dictionary:
	var quarterClockwise = getQuarterClockwise(sectio.quarter)
	var sectioClockwise = getSectioFromCircleAndQuarter(sectio.circle, quarterClockwise)
	if not sectioClockwise.player == playerId:
		for unitName in sectioClockwise.troops:
			var unit = Data.troops[unitName]
			if unit.occupiedSectio == sectioClockwise.sectioName:
				unitsWithoutPlan.erase(unitName)
	
	var quarterCounterclockwise = getQuarterCounterclockwise(sectio.quarter)
	var sectioCounterclockwise = getSectioFromCircleAndQuarter(sectio.circle, quarterCounterclockwise)
	if not sectioCounterclockwise.player == playerId:
		for unitName in sectioCounterclockwise.troops:
			var unit = Data.troops[unitName]
			if unit.occupiedSectio == sectioCounterclockwise.sectioName:
				unitsWithoutPlan.erase(unitName)
	
	return unitsWithoutPlan


func sectioIsOwnedByPlayer(sectioPlayerId : int, playerId : int) -> bool:
	if sectioPlayerId == playerId:
		return true
	else:
		return false


func moveUnit(unitsWithoutPlan : Dictionary, occupiedSectioByClosestUnit : Sectio, closestUnit : Unit, startingSectioId : int, targetSectioId : int, map) -> Dictionary:
	var path : Array = Astar.astar.get_id_path(startingSectioId, targetSectioId)
	if path.size() > 1:
		path.pop_front()
		closestUnit.sectiosMoved = 0
		var pathIndex : int = 0
		for sectioId in path:
			if closestUnit.sectiosMoved >= closestUnit.maxSectiosMoved:
				break
			if closestUnit.sectiosMoved == 0:
				Data.currentDemon.skullsUsed += 1
			closestUnit.sectiosMoved += 1
			var nextSectio = Astar.sectioIdsNodeDict[sectioId]
			Signals.moveUnits.emit([closestUnit], occupiedSectioByClosestUnit, nextSectio)
			await closestUnit.arrivedAtDestination
			
			pathIndex += 1
			if pathIndex >= path.size(): 
				unitsWithoutPlan.erase(closestUnit.unitNr)
			
			var enemies = 0
			var enemiesFled = 0
			var fleeingConfirmed = false
			for unitNr in nextSectio.troops:
				var unit = Data.troops[unitNr]
				if unitNr == closestUnit.unitNr:
					continue
				if not unit.triumphirate == closestUnit.triumphirate:
					# solitary lieutenant would have to flee automatically
					print("enemy in sectio")
					enemies += 1
					if Connection.peers.has(unit.triumphirate):
						map.promtToFlee.rpc_id(unit.triumphirate, unit.triumphirate, nextSectio.sectioName, occupiedSectioByClosestUnit.sectioName)
					else:
						map.promtToFlee.rpc_id(Connection.host, unit.triumphirate, nextSectio.sectioName, occupiedSectioByClosestUnit.sectioName)
					if Connection.peers.has(unit.triumphirate):
						fleeingConfirmed = await map.fleeConfirmation
					if fleeingConfirmed:
						enemiesFled += 1
					print("result of flee ", fleeingConfirmed)
					break
				else:
					print("friend in sectio")
			
			if enemies > 0 and not fleeingConfirmed:
				unitsWithoutPlan.erase(closestUnit.unitNr)
				break
			
			var  troopsRemaining = false
			for troopName in nextSectio.troops:
				var troop = Data.troops[troopName]
				if not troop.triumphirate == closestUnit.triumphirate:
					troopsRemaining = true
				
			if troopsRemaining and fleeingConfirmed:
				unitsWithoutPlan.erase(closestUnit.unitNr)
				break
			
			occupiedSectioByClosestUnit = nextSectio
	return unitsWithoutPlan


func moveUnitLoop(unitsWithoutPlan : Dictionary, sectiosNextToFriendlySectioInSameCircle : Array, map):
	while Data.currentDemon.skullsUsed < Data.currentDemon.skulls:
		var shortestPhaseSize : int = 100
		var closestUnit
		var occupiedSectioByClosestUnit
		var closestSectio
		print("moving units without plan 1 ", unitsWithoutPlan)
		for unitName in unitsWithoutPlan:
			sectiosNextToFriendlySectioInSameCircle.shuffle()
			for sectioNextToFriendlySectioInSameCircle in sectiosNextToFriendlySectioInSameCircle:
				var unit = Data.troops[unitName]
				var occupiedSectio = Decks.sectioNodes[unit.occupiedSectio]
#										print("moving sectiosNextToFriendlySectioInSameCircle ", sectioNextToFriendlySectioInSameCircle.sectioName)
				var path = Astar.astar.get_id_path(occupiedSectio.id, sectioNextToFriendlySectioInSameCircle.id)
				print("moving comparing", path.size(), " from ", occupiedSectio.sectioName, " to ", sectioNextToFriendlySectioInSameCircle.sectioName)
				if path.size() < shortestPhaseSize and path.size() > 1:
					shortestPhaseSize = path.size()
					occupiedSectioByClosestUnit = occupiedSectio
					closestUnit = unit
					closestSectio = sectioNextToFriendlySectioInSameCircle
		
		if not closestUnit:
			break
		
		await moveUnit(unitsWithoutPlan, occupiedSectioByClosestUnit, closestUnit, occupiedSectioByClosestUnit.id, closestSectio.id, map)


func phase(phase, rankTrack : Array, ui, map, rankTrackNode):
	if Tutorial.tutorial:
		tutorialStart(rankTrack, rankTrackNode)
	
	for peer in Connection.peers:
		RpcCalls.demonAction.rpc_id(peer, 0, "Reset")
	
	var tutorialSequence : int = 0
	var newRankTrack : Array = []
	while not rankTrack.size() == 0:
		var nextDemonRank = rankTrack.pop_front()
		newRankTrack.append(nextDemonRank)
		
		for peer in Connection.peers:
			RpcCalls.updateRankTrack.rpc_id(peer, newRankTrack + rankTrack)
		for peer in Connection.peers:
			ui.updateRankTrackCurrentDemon.rpc_id(peer, nextDemonRank)
		if Connection.peers.has(Data.demons[nextDemonRank].player):
			ui.nextDemon.rpc_id(Data.demons[nextDemonRank].player, nextDemonRank)
		for peer in Connection.peers:
			RpcCalls.nextDemon.rpc_id(peer, nextDemonRank)
			RpcCalls.toogleWaitForPlayer.rpc_id(peer, Data.demons[nextDemonRank].player, true, phase)
		
		var result
		if not Connection.isAiPlayer(Data.demons[nextDemonRank].player):
			if Tutorial.tutorial:
				tutorial1(tutorialSequence)
			result = await Signals.demonDoneWithPhase
			for sectio in Decks.sectioNodes.values():
				sectio.changeClickable.rpc_id(Data.demons[nextDemonRank].player, false)
		else:
			# AI Player
			var playerId = Data.demons[nextDemonRank].player
			var player : Player = Data.players[playerId]
			if Tutorial.tutorial:
				tutorial2(tutorialSequence, nextDemonRank, playerId, map)
			else:
				var affordableWalkTheEarthCardNames : Array = getAffordableWalkTheEarthCards(player.arcanaCards, player)
				
				var hasDemonOnEarth : bool = hasDemonOnEarth(player.demons)
				var heartScore : Array = getHeartScoresOfDemons(player.demons)
				var demonNode = Data.demons[nextDemonRank]
				demonNode.skullsUsed = 0
				Data.currentDemon = demonNode
				
				# wait for the current demon screen to disappear 
				if not Settings.skipScreens:
					await get_tree().create_timer(3).timeout
				var madeAction : bool = false
				if not hasDemonOnEarth:
					# AI doesnt know how to handle cards
		#						if not walkTheEarthCardNames.is_empty():
					# just make it very likely to get one on the earth the first turn
					
					var cheapestWalkTheEarthCardName : String = getNameOfCheapestCard(affordableWalkTheEarthCardNames)
					
					if isDemonWithMaxHeartScore(nextDemonRank, player.demons, heartScore):
						if sendsDemonToEarth():
							sendingDemonToEarth(nextDemonRank, playerId, cheapestWalkTheEarthCardName)
							madeAction = true
				else:
					# do evil deeds
					var demon = Data.demons[nextDemonRank]
					if demon.onEarth:
						doEvilDeeds(demon)
						madeAction = true
				
				if not madeAction:
					
					for peer in Connection.peers:
						RpcCalls.demonAction.rpc_id(peer, nextDemonRank, "Marching")
					var circle : int = Ai.getBestCircle(playerId)
					var sectio_to_move_to : Sectio = getSectioToMoveToInCircle(circle, playerId)
					
					Ai.worldStates[playerId].set_state("circle_to_capture", circle)
					Ai.worldStates[playerId].set_state("active_player", playerId)
					Ai.worldStates[playerId].set_state("sectio_to_move_to", sectio_to_move_to)
					
					var sectiosNextToFriendlySectioInSameCircle : Array = [] 
					var sectiosNextToFriendlySectioInSameCircleWithoutFriendlies : Array = [] 
					var unitsWithoutPlan : Dictionary = Data.players[playerId].troops.duplicate()
					
					unitsWithoutPlan = removeUnitsThatCannotMove(unitsWithoutPlan, playerId)
					
					for sectioName in Decks.sectioNodes:
						var sectio = Decks.sectioNodes[sectioName]
						
						# ignore sectios not in the preferred circle
						if not circle == sectio.circle:
							continue
						
						# units with enemies in same sectio cant move
#						unitsWithoutPlan = removeUnitsThatCannotMove(unitsWithoutPlan, sectio, playerId)
						
						# friendly units already next to friendly sectios can stay
						unitsWithoutPlan = removeUnitsAlreadyInPosition(unitsWithoutPlan, sectio, playerId)
						
						# get sectios next to friendly sectios that can be moved to
						if sectioIsOwnedByPlayer(sectio.player, playerId):
							var quarterClockwise : int = getQuarterClockwise(sectio.quarter)
							var sectioClockwise : Sectio = getSectioFromCircleAndQuarter(sectio.circle, quarterClockwise)
							if isSectioNotFriendlyAndNotYetTargetedToMoveThere(sectioClockwise, playerId, sectiosNextToFriendlySectioInSameCircle):
								print("moving sectio clockwise ", sectioClockwise.sectioName)
								unitsWithoutPlan = removeUnitAlreadyInSectio(unitsWithoutPlan, sectioClockwise, playerId)
								sectiosNextToFriendlySectioInSameCircle.append(sectioClockwise)
								if noFriendlyUnitInSectio(sectioClockwise, playerId):
									sectiosNextToFriendlySectioInSameCircleWithoutFriendlies.append(sectioClockwise)
							
							var quarterCounterclockwise : int = getQuarterCounterclockwise(sectio.quarter)
							var sectioCounterclockwise : Sectio = getSectioFromCircleAndQuarter(sectio.circle, quarterCounterclockwise)
							if isSectioNotFriendlyAndNotYetTargetedToMoveThere(sectioCounterclockwise, playerId, sectiosNextToFriendlySectioInSameCircle):
								print("moving sectio counter clockwise ", sectioCounterclockwise.sectioName)
								unitsWithoutPlan = removeUnitAlreadyInSectio(unitsWithoutPlan, sectioCounterclockwise, playerId)
								if noFriendlyUnitInSectio(sectioCounterclockwise, playerId):
									sectiosNextToFriendlySectioInSameCircleWithoutFriendlies.append(sectioCounterclockwise)
							if neighbouringSectioHasNoFriendlyUnits(sectiosNextToFriendlySectioInSameCircleWithoutFriendlies):
								sectiosNextToFriendlySectioInSameCircle = sectiosNextToFriendlySectioInSameCircleWithoutFriendlies
					
					
					if not sectiosNextToFriendlySectioInSameCircle.is_empty():
						await moveUnitLoop(unitsWithoutPlan, sectiosNextToFriendlySectioInSameCircle, map)
		tutorialSequence += 1
		
		for peer in Connection.peers:
			RpcCalls.toogleWaitForPlayer.rpc_id(peer, Data.demons[nextDemonRank].player, false)

		if result:
			if result == 0:
				pass # pass for good
			else:
				print("if I dont print I bug")
				
				newRankTrack.erase(nextDemonRank)
				rankTrack = sortRankTrack(result, rankTrack, nextDemonRank)
	rankTrackNode.updateRankTrack(newRankTrack)
	
	if Tutorial.tutorial:
		await get_tree().create_timer(0.1).timeout
		Signals.returnToMainMenu.emit()
		await Signals.tutorialRead


func noFriendlyUnitInSectio(sectio : Sectio, playerId : int) -> bool:
	var noFriendlyUnitInSectio : bool = true
	for unitName in sectio.troops:
		var unit : Unit = Data.troops[unitName]
		if unit.triumphirate == playerId:
			noFriendlyUnitInSectio = false
	return noFriendlyUnitInSectio


func removeUnitAlreadyInSectio(unitsWithoutPlan : Dictionary, sectio : Sectio, playerId : int) -> Dictionary:
	for unitName in sectio.troops:
		var unit : Unit = Data.troops[unitName]
		if unit.triumphirate == playerId:
			unitsWithoutPlan.erase(unitName)
	return unitsWithoutPlan


func isSectioNotFriendlyAndNotYetTargetedToMoveThere(sectio, playerId, sectiosNextToFriendlySectioInSameCircle) -> bool:
	if not sectioIsOwnedByPlayer(sectio.player, playerId) and not sectiosNextToFriendlySectioInSameCircle.has(sectio):
		return true
	else:
		return false


func neighbouringSectioHasNoFriendlyUnits(sectios : Array) -> bool:
	if not sectios.is_empty():
		return true
	else:
		return false


func sortRankTrack(passedDemons : int, rankTrack : Array, demonRank : int) -> Array:
	if passedDemons > rankTrack.size():
		rankTrack.append(demonRank)
	else:
		rankTrack.insert(passedDemons, demonRank)
	return rankTrack
