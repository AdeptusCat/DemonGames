extends Node
class_name SequenceOfPlay


func hellPhase():
	for playerId in Data.players:
		var player = Data.players[playerId]
		var cardsToDraw = 5 - player.arcanaCards.size()
		print(playerId, " need to draw ", cardsToDraw)
		for i in range(cardsToDraw):
			var CardName : String = Decks.getRandomCard("arcana")
			for peer in Connection.peers:
				RpcCalls.addArcanaCard.rpc_id(peer, playerId, CardName)


func soulPhase(ui):
	if Tutorial.tutorial:
		var nr : String
		for playerId in Data.players:
			if playerId == Data.id:
				nr = Decks.getSpecificCard("demon", "Gomory") #38
				for peer in Connection.peers:
					RpcCalls.addDemon.rpc_id(peer, playerId, nr)
				for peer in Connection.peers:
					RpcCalls.demonStatusChange.rpc_id(peer, 38, "earth")
		Signals.collapseDemonCards.emit()
		
		for playerId in Data.players:
			if playerId == Data.id:
				Signals.spawnUnit.emit("Megalomaniacs", playerId, Data.UnitType.Legion)
			else:
				Signals.spawnUnit.emit("Idolaters", playerId, Data.UnitType.Legion)
		
		var sectio : Sectio = Decks.sectioNodes["Megalomaniacs"]
		for peer in Connection.peers:
			RpcCalls.occupySectio.rpc_id(peer, Data.id, sectio.sectioName)
		sectio = Decks.sectioNodes["Idolaters"]
		for peer in Connection.peers:
			RpcCalls.occupySectio.rpc_id(peer, Data.id, sectio.sectioName)
		sectio = Decks.sectioNodes["Snake Eyes Saloon"]
		for peer in Connection.peers:
			RpcCalls.occupySectio.rpc_id(peer, Data.id, sectio.sectioName)
		
	for peer in Connection.peers:
		ui.updateRankTrackCurrentPlayer.rpc_id(peer, 0)
	var soulSummary = {}
	for playerId in Data.players:
		soulSummary[playerId] = {"earth" : {}, "hell" : {}, "payment" : {}}
	for demon in Data.demons.values():
		if not demon.incapacitated:
			if demon.onEarth:
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

				# gather souls on earth
				var result = Dice.roll(1)
				var soulsGathered = 0
				soulsGathered += result[0]
				soulsGathered += demon.hearts
				soulsGathered = clamp(soulsGathered, 0, 100)
				var souls = player.souls + soulsGathered
				Signals.changeSouls.emit(player.playerId, souls)
				soulSummary[player.playerId]["earth"][demon.demonName]["souls"] = soulsGathered
				print(demon.demonName, " gathered ", soulsGathered, " Souls on Earth")

	# gather souls in hell
	for playerId in Data.players:
		var player = Data.players[playerId]
		var soulsGatheredTotal = 0
#				print("player ", player, " has sectios ", player.sectios)
		for sectioName in player.sectios:
			var enemyInSectio = false
			for unitName in Decks.sectioNodes[sectioName].troops:
				if not Data.troops[unitName].triumphirate == playerId:
					enemyInSectio = true
					soulSummary[player.playerId]["hell"][sectioName] = {"isolated" : false, "souls": 0, "enemyInSectio": true}
					break
			if not enemyInSectio:
				var sectio = Decks.sectioNodes[sectioName]
				var isIsolated = sectio.isolated()
				var soulsGathered = sectio.souls
				soulsGatheredTotal += soulsGathered
				# check for hellhounds in sectio as well!! hellhounds  hellhounds  hellhounds  hellhounds  hellhounds  hellhounds 
				if isIsolated:
					soulsGathered -= 2
				soulsGathered = clamp(soulsGathered, 0, 100)
				var souls = player.souls + soulsGathered
				Signals.changeSouls.emit(playerId, souls)
				soulSummary[player.playerId]["hell"][sectioName] = {"isolated" : isIsolated, "souls": soulsGathered,  "enemyInSectio": false}
				if sectioName == "The Wise Men":
					var result = Dice.roll(1)
					for i in result[0]:
						var cardName : String = Decks.getRandomCard("arcana")
						for peer in Connection.peers:
							RpcCalls.addArcanaCard.rpc_id(peer, player.playerId, cardName)
						print("add arcana the wisea", result[0])
		print("player ", player, " gathered ", soulsGatheredTotal, " Souls in Hell")

	for playerId in Data.players:
		var player = Data.players[playerId]
		var soulsPaid = 0
		for unitName in player.troops:
			var unit = Data.troops[unitName]
			if not unit.unitType == Data.UnitType.Hellhound:
				soulSummary[player.playerId]["payment"][unitName] = {"paid" : 1}
				soulsPaid += 1
		var souls = player.souls - soulsPaid
		Signals.changeSouls.emit(playerId, souls)
	
	for peer in Connection.peers:
		print("send soul summary")
		RpcCalls.sendSoulSummary.rpc_id(peer, soulSummary)
	# pay legions and lieutenants
	
	for triumphirate in Connection.peers:
		await Signals.doneGatheringSouls
	
	if Tutorial.tutorial:
		await get_tree().create_timer(0.1).timeout
		Signals.returnToMainMenu.emit()
		await Signals.tutorialRead


func summoningPhase(phase : int, ui : UI):
	if Tutorial.tutorial:
		Signals.changeSouls.emit(Data.id, 42)
		
		var sectio : Sectio = Decks.sectioNodes["Megalomaniacs"]
		for peer in Connection.peers:
			RpcCalls.occupySectio.rpc_id(peer, Data.id, sectio.sectioName)
		sectio = Decks.sectioNodes["Idolaters"]
		for peer in Connection.peers:
			RpcCalls.occupySectio.rpc_id(peer, Data.id, sectio.sectioName)
		
		Signals.tutorial.emit(Tutorial.Topic.Phase, "This is the Summoning Phase. \nHere you will be able to recruit Units like Legions and Lieutenants or buy Arcana Cards.")
		await Signals.tutorialRead
	# sort players by souls
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
	
	
	
	print("players by souls ", playersSortedBySouls)
	for playerId in playersSortedBySouls:
		
		for peer in Connection.peers:
			ui.updateRankTrackCurrentPlayer.rpc_id(peer, playerId)
		
		if Tutorial.tutorial:
			Signals.tutorial.emit(Tutorial.Topic.PlayerStatus, "The Player with the most Souls will summon first. \nThe Souls owned by the Players can be observed here.")
			await Signals.tutorialRead
		
		if Tutorial.tutorial:
			Signals.tutorial.emit(Tutorial.Topic.CurrentPlayer, "The Player that is currently summoning is displayed here.")
			await Signals.tutorialRead
		
		if not Connection.peers.has(playerId):
			print("is ai player")
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
			
			var sectiosWithoutEnemies = []
			for sectio in player.sectios:
				var enemyInSectio = false
				for unitName in Decks.sectioNodes[sectio].troops:
					if not Data.troops[unitName].triumphirate == playerId:
						enemyInSectio = true
						break
				if not enemyInSectio:
					sectiosWithoutEnemies.append(sectio)
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
		
		print("summoning ", playerId)
		var player = Data.players[playerId]
		
		if Tutorial.tutorial:
			var cardsToDraw : int = 5 - player.arcanaCards.size()
			var cardNames : Array = ["Reincarnation", "Rotten Sweetness", "Sisyphus' Rock", "The Frenzied Feeder", "The Shaker"]
			for i in range(cardsToDraw):
				var CardName : String = Decks.getSpecificCard("arcana", cardNames.pop_back())
				for peer in Connection.peers:
					RpcCalls.addArcanaCard.rpc_id(peer, playerId, CardName)
		
		for unitName in player.troops:
			var unit = Data.troops[unitName]
			if unit.occupiedCircle == 9 and unit.unitType == Data.UnitType.Legion:
				RpcCalls.toogleTameHellhound.rpc_id(playerId, true)
		var sectiosWithoutEnemies = []
#				for sectio in Decks.sectioNodes.values():
#					sectio.changeClickable.rpc_id(playerId, false)
		for sectio in player.sectios:
			var enemyInSectio = false
			for unitName in Decks.sectioNodes[sectio].troops:
				if not Data.troops[unitName].triumphirate == playerId:
					enemyInSectio = true
					break
			if not enemyInSectio:
#						Decks.sectioNodes[sectio].changeClickable.rpc_id(playerId, true)
				sectiosWithoutEnemies.append(sectio)
		RpcCalls.sendSectiosWithoutEnemies.rpc_id(playerId, sectiosWithoutEnemies)

		var arcanaCardsNames = player.arcanaCards
		if player.arcanaCards.size() <= 5:
			for cardName in arcanaCardsNames:
				var arcanaCard = Data.arcanaCards[cardName]
				if arcanaCard:
					if not player.hasEnoughSouls(arcanaCard.cost):
						continue
					var MinorSpell = Decks.MinorSpell
					if arcanaCard.minorSpell == MinorSpell.RecruitLieutenants and Data.player.arcanaCards.size() <= 5:
						RpcCalls.hightlightArcanaCard.rpc_id(playerId, cardName)
#				toogleBuyArcanaCard.rpc_id(playerId, true)
		for peer in Connection.peers:
			RpcCalls.toogleWaitForPlayer.rpc_id(peer, playerId, true, phase)
#				toogleBuyLieutenant.rpc_id(playerId, true)
#				checkEndPhaseCondition.rpc_id(playerId)
		RpcCalls.phaseStart.rpc_id(playerId, Data.phases.Summoning)
		
		if Tutorial.tutorial:
			Signals.tutorial.emit(Tutorial.Topic.RecruitLegion, "Click the highlighted Button to summon Legions for three Souls each.")
			await Signals.tutorialRead
		
		if Tutorial.tutorial:
			Signals.tutorial.emit(Tutorial.Topic.PlaceLegion, "Click on a highlighted Sectio to place a Legion. \nYou can place Legions only in Sectio that you own and that have no enemy Units inside.")
			await Signals.tutorialRead
		
		if Tutorial.tutorial:
			Signals.tutorial.emit(Tutorial.Topic.PlaceLegionTwice, "Notice that you have to place a Legions in each Sectio you own, bevore you can place another Legion in the same Sectio.")
			await Signals.tutorialRead
		
		if Tutorial.tutorial:
			Signals.tutorial.emit(Tutorial.Topic.RecruitLieutenantAttempt, "To summon a Lieutenant, you need the appropriate Arcana Card. \nIt seems you dont have the right Arcana Card.")
			await Signals.tutorialRead
		
		if Tutorial.tutorial:
			Signals.tutorial.emit(Tutorial.Topic.BuyArcanaCard, "Click the highlighted Button to buy one Arcana Card for five Souls.")
			await Signals.tutorialRead
		
		if Tutorial.tutorial:
			Signals.tutorial.emit(Tutorial.Topic.PickArcanaCard, "Now pick one of the three shown Arcana Cards that sais 'Recruit Lieutenant'.")
			await Signals.tutorialRead
		
		if Tutorial.tutorial:
			Signals.tutorial.emit(Tutorial.Topic.TooManyArcanaCards, "You can only have five Arcana Cards at all times. Click one to discards it. \nNotice, it can also be the one you just bought. But we need still need it so keep it for now.")
			await Signals.tutorialRead
		
		if Tutorial.tutorial:
			Signals.tutorial.emit(Tutorial.Topic.RecruitLieutenantCard, "Now you can recruit a Lieutenant by clicking on the Card that sais 'Recruit Lieutenant'.")
			await Signals.tutorialRead
		
		if Tutorial.tutorial:
			Signals.tutorial.emit(Tutorial.Topic.PlaceLieutenant, "Now you can place the Lieutenant on a Sectio that you own and where no enemy Unit is.")
			await Signals.tutorialRead
		
		if Tutorial.tutorial:
			Signals.tutorial.emit(Tutorial.Topic.EndSummoningPhase, "Great. Now you can end the Summoning Phase by clicking the highlighted Button.")

		await Signals.phaseDone
		
		if Tutorial.tutorial:
			await get_tree().create_timer(0.1).timeout
			Signals.returnToMainMenu.emit()
			await Signals.tutorialRead
		
		RpcCalls.phaseEnd.rpc_id(playerId, Data.phases.Summoning)
#				toggleEndPhaseButton.rpc_id(playerId, false)
#				toogleBuyArcanaCard.rpc_id(playerId, false)
#				toogleTameHellhound.rpc_id(playerId, false)
		for peer in Connection.peers:
			RpcCalls.toogleWaitForPlayer.rpc_id(peer, playerId, false)
#				toogleBuyLieutenant.rpc_id(playerId, false)
#				for cardName in arcanaCardsNames:
#					var arcanaCard = Data.arcanaCards[cardName]
#					var MinorSpell = Decks.MinorSpell
#					if arcanaCard.minorSpell == MinorSpell.RecruitLieutenants:
#						disableArcanaCard.rpc_id(playerId, cardName)
#			for playerId in Data.players.values():
#				var player = Data.players[playerId]
#				for sectio in player.sectios:
#					Decks.sectioNodes[sectio].changeClickable.rpc_id(playerId, false)

func actionPhase(phase, rankTrack : Array, ui, map, rankTrackNode):
	if Tutorial.tutorial:
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
	
	for peer in Connection.peers:
		RpcCalls.demonAction.rpc_id(peer, 0, "Reset")
	
	var tutorialSequence : int = 0
	var newRankTrack : Array = []
	while not rankTrack.size() == 0:
		var nextDemonRank = rankTrack.pop_front()
		newRankTrack.append(nextDemonRank)
#				ui.rankTrack = newRankTrack + rankTrack
		for peer in Connection.peers:
			RpcCalls.updateRankTrack.rpc_id(peer, newRankTrack + rankTrack)
#				var result = await ui.nextDemon(nextDemonRank)
		for peer in Connection.peers:
			ui.updateRankTrackCurrentDemon.rpc_id(peer, nextDemonRank)
		if Connection.peers.has(Data.demons[nextDemonRank].player):
			ui.nextDemon.rpc_id(Data.demons[nextDemonRank].player, nextDemonRank)
		for peer in Connection.peers:
			RpcCalls.nextDemon.rpc_id(peer, nextDemonRank)
			RpcCalls.toogleWaitForPlayer.rpc_id(peer, Data.demons[nextDemonRank].player, true, phase)
		var result
		if Connection.peers.has(Data.demons[nextDemonRank].player):
			if Tutorial.tutorial:
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
					
			result = await Signals.demonDoneWithPhase
			for sectio in Decks.sectioNodes.values():
				sectio.changeClickable.rpc_id(Data.demons[nextDemonRank].player, false)
		else:
			# AI Player
			var playerId = Data.demons[nextDemonRank].player
			var player : Player = Data.players[playerId]
			if Tutorial.tutorial:
				if tutorialSequence == 1:
					for peer in Connection.peers:
						RpcCalls.demonAction.rpc_id(peer, nextDemonRank, "Marching")
					
#					Signals.tutorial.emit(Tutorial.Topic.NextDemon, "The next Demon is 'Ashtaroth'.")
#					await Signals.tutorialRead
					
					Signals.tutorial.emit(Tutorial.Topic.MarchEnemy, "The enemy Demon 'Ashtaroth' chose to use the March Action. Lets see where it will move its Legion to.")
					await Signals.tutorialRead
					
					var sectioToMoveTo : Sectio = Decks.sectioNodes["Megalomaniacs"]
					Ai.worldStates[playerId].set_state("sectio_to_move_to", sectioToMoveTo)
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
			else:
				var arcanaCardsNames = player.arcanaCards
				var walkTheEarthCardNames : Array = []
				for cardName in arcanaCardsNames:
					var arcanaCard = Data.arcanaCards[cardName]
					if arcanaCard:
						if not player.hasEnoughSouls(arcanaCard.cost):
							continue
						var MinorSpell = Decks.MinorSpell
						if arcanaCard.minorSpell == MinorSpell.WalkTheEarth or arcanaCard.minorSpell == MinorSpell.WalkTheEarthSafely:
							walkTheEarthCardNames.append(cardName)
				
				var hasDemonOnEarth : bool = false
				var heartScore : Array = []
				for demonRank in player.demons:
		#						if not rankTrack.has(demonRank):
		#							continue
					var demon = Data.demons[demonRank]
					if demon.onEarth:
						hasDemonOnEarth = true
					var score = demon.hearts - demon.skulls * 0.25
					heartScore.append(demon.hearts)
					print("demonhearts ", demon.demonName, demon.hearts, " ", demon.skulls, " ", score)
				
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
					
					
					var maxHearts = heartScore.max()
					var i = heartScore.find(maxHearts)
					
					var minCost = 100
					var cheapestCardName = ""
					
					for cardName in walkTheEarthCardNames:
						var card = Data.arcanaCards[cardName]
						if card.cost < minCost:
							minCost = card.cost
							cheapestCardName = cardName
					if Data.demons[player.demons[i]] == Data.demons[nextDemonRank]:
						var randomNr = randi_range(1, 100)
						if randomNr < 90:
							for peer in Connection.peers:
								RpcCalls.demonStatusChange.rpc_id(peer, nextDemonRank, "earth")
							Signals.incomeChanged.emit(playerId)
							for peer in Connection.peers:
								RpcCalls.discardArcanaCard.rpc_id(peer, cheapestCardName, playerId)
							madeAction = true
							for peer in Connection.peers:
								RpcCalls.demonAction.rpc_id(peer, nextDemonRank, "Walk The Earth")
				else:
					# do evil deeds
					var demon = Data.demons[nextDemonRank]
					if demon.onEarth:
						
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
							RpcCalls.demonAction.rpc_id(peer, nextDemonRank, "Do Evil Deeds: " + str(favorsGathered))
						Signals.doEvilDeedsResult.emit(demon.player, demon.demonName, favorsGathered)
						madeAction = true
				
				if not madeAction:
					for peer in Connection.peers:
						RpcCalls.demonAction.rpc_id(peer, nextDemonRank, "Marching")
					var circle : int = Ai.getBestCircle(playerId)
					var sectio_to_move_to : Sectio
					for sectioName in Decks.sectioNodes:
						var sectio : Sectio = Decks.sectioNodes[sectioName]
						if not circle == sectio.circle:
							continue
						if sectio.player == playerId:
							continue
						sectio_to_move_to = sectio
						break
					
					Ai.worldStates[playerId].set_state("circle_to_capture", circle)
					Ai.worldStates[playerId].set_state("active_player", playerId)
					Ai.worldStates[playerId].set_state("sectio_to_move_to", sectio_to_move_to)
		#						WorldState.set_state("circle_to_capture", circle)
		#						WorldState.set_state("active_player", playerId)
		#						WorldState.set_state("sectio_to_move_to", sectio_to_move_to)
					
					var sectiosNextToFriendlySectioInSameCircle : Array = [] 
					var sectiosNextToFriendlySectioInSameCircleWithoutFriendlies : Array = [] 
					var unitsWithoutPlan : Dictionary = Data.players[playerId].troops.duplicate()
					for sectioName in Decks.sectioNodes:
						var sectio = Decks.sectioNodes[sectioName]
						# units with enemies in same sectio cant move
						for unitName in sectio.troops:
							var unit = Data.troops[unitName]
							if not unit.triumphirate == playerId:
								for unitNr in sectio.troops:
									unitsWithoutPlan.erase(unitNr)
								break
						# ignore sectios not in the preferred circle
						if not circle == sectio.circle:
							continue
						
						# friendly units already next to friendly sectios can stay
						var quarterClockwise = posmod((sectio.quarter + 1), 5)
						var sectioClockwise = Decks.sectios[sectio.circle][quarterClockwise]
						if not sectioClockwise.player == playerId:
							for unitName in sectioClockwise.troops:
								var unit = Data.troops[unitName]
								if unit.occupiedSectio == sectioClockwise.sectioName:
									unitsWithoutPlan.erase(unitName)
							
						var quarterCounterclockwise = posmod((sectio.quarter - 1), 5)
						var sectioCounterclockwise = Decks.sectios[sectio.circle][quarterCounterclockwise]
						if not sectioCounterclockwise.player == playerId:
							for unitName in sectioCounterclockwise.troops:
								var unit = Data.troops[unitName]
								if unit.occupiedSectio == sectioCounterclockwise.sectioName:
									unitsWithoutPlan.erase(unitName)
						
						# get sectios next to friendly sectios that can be moved to
						if sectio.player == playerId:
							if not sectioClockwise.player == playerId and not sectiosNextToFriendlySectioInSameCircle.has(sectioClockwise):
								print("moving sectio clockwise ", sectioClockwise.sectioName)
								var friendlyUnitInSectio : bool = false
								for unitName in sectioClockwise.troops:
									var unit = Data.troops[unitName]
									if unit.occupiedSectio == sectioClockwise.sectioName:
										unitsWithoutPlan.erase(unitName)
										friendlyUnitInSectio = true
								sectiosNextToFriendlySectioInSameCircle.append(sectioClockwise)
								if not friendlyUnitInSectio:
									sectiosNextToFriendlySectioInSameCircleWithoutFriendlies.append(sectioClockwise)
							
							if not sectioCounterclockwise.player == playerId and not sectiosNextToFriendlySectioInSameCircle.has(sectioCounterclockwise):
								print("moving sectio counter clockwise ", sectioCounterclockwise.sectioName)
								var friendlyUnitInSectio : bool = false
								for unitName in sectioCounterclockwise.troops:
									var unit = Data.troops[unitName]
									if unit.occupiedSectio == sectioCounterclockwise.sectioName:
										unitsWithoutPlan.erase(unitName)
										friendlyUnitInSectio = true
								sectiosNextToFriendlySectioInSameCircle.append(sectioCounterclockwise)
								if not friendlyUnitInSectio:
									sectiosNextToFriendlySectioInSameCircleWithoutFriendlies.append(sectioCounterclockwise)
							if not sectiosNextToFriendlySectioInSameCircleWithoutFriendlies.is_empty():
								sectiosNextToFriendlySectioInSameCircle = sectiosNextToFriendlySectioInSameCircleWithoutFriendlies
					
					
					if not sectiosNextToFriendlySectioInSameCircle.is_empty():
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
							var path : Array = Astar.astar.get_id_path(occupiedSectioByClosestUnit.id, closestSectio.id)
							print("moving unit start ", closestUnit.occupiedSectio)
							print("moving demon ", nextDemonRank)
							print("moving unit path size ", path.size())
							print("moving unit from1 ", occupiedSectioByClosestUnit.sectioName, " to ", closestSectio.sectioName)
							if path.size() > 1:
								path.pop_front()
								closestUnit.sectiosMoved = 0
								var pathIndex : int = 0
								for sectioId in path:
									print("moving unit moved ", closestUnit.sectiosMoved)
									if closestUnit.sectiosMoved >= closestUnit.maxSectiosMoved:
										break
									if closestUnit.sectiosMoved == 0:
										Data.currentDemon.skullsUsed += 1
									closestUnit.sectiosMoved += 1
									var nextSectio = Astar.sectioIdsNodeDict[sectioId]
									print("moving unit from2 ", occupiedSectioByClosestUnit.sectioName, " to ", nextSectio.sectioName)
									Signals.moveUnits.emit([closestUnit], occupiedSectioByClosestUnit, nextSectio)
									await closestUnit.arrivedAtDestination
									
									pathIndex += 1
									if pathIndex >= path.size(): 
										print("moving unit done erasing ", closestUnit.unitNr, " from ", unitsWithoutPlan, " true? ", unitsWithoutPlan.has(closestUnit.unitNr))
										unitsWithoutPlan.erase(closestUnit.unitNr)
										print("moving unit done", closestUnit.unitNr, unitsWithoutPlan)
									
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
								#						%EventDialog.dialog_text = "The Enemy fled."
											print("result of flee ", fleeingConfirmed)
											break
										else:
											print("friend in sectio")
									
									if enemies > 0 and not fleeingConfirmed:
		#											map.neightboursClickable(false)
										unitsWithoutPlan.erase(closestUnit.unitNr)
										break
									
									var  troopsRemaining = false
									for troopName in nextSectio.troops:
										var troop = Data.troops[troopName]
										if not troop.triumphirate == closestUnit.triumphirate:
											troopsRemaining = true
										
									if troopsRemaining and fleeingConfirmed:
		#											%EventDialog.dialog_text = "The Enemy tried to flee but failed, stopping."
						#				_on_unitMovedMax(closestUnit)3
										unitsWithoutPlan.erase(closestUnit.unitNr)
										break

		#										if not troopsRemaining:
		#											%EventDialog.dialog_text = "The Enemy fled."
								
									occupiedSectioByClosestUnit = nextSectio
						
		tutorialSequence += 1
		
		for peer in Connection.peers:
			RpcCalls.toogleWaitForPlayer.rpc_id(peer, Data.demons[nextDemonRank].player, false)
		print("done",nextDemonRank)

		if result:
			if result == 0:
				pass # pass for good
#					elif result = "Walk The Earth":
#
			else:
				print("if I dont print I bug")
				newRankTrack.erase(nextDemonRank)
				if result > rankTrack.size():
					rankTrack.append(nextDemonRank)
				else:
					rankTrack.insert(result, nextDemonRank)
#				actionsNode.toggleActionMenu(false)
	rankTrackNode.updateRankTrack(newRankTrack)
	
	if Tutorial.tutorial:
		await get_tree().create_timer(0.1).timeout
		Signals.returnToMainMenu.emit()
		await Signals.tutorialRead
