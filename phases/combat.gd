extends Node

var combatWinner : Dictionary = {}
var canHitLieutenants : bool = true #debug switch
var lieutenantBonus : bool = true #debug switch
var triumphiratesThatWantToFlee : Array = []


func _ready():
	Signals.triumphiratWantsToFlee.connect(_on_triumphiratesWantToFlee)


func phase(map):
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
	
	if battleSectiosSorted.size() <= 0:
		for peer in Connection.peers:
			RpcCalls.hideCombatSectios.rpc_id(peer)
		return
	
	var battleSectiosNamesSorted : Array = []
	for sectio : Sectio in battleSectiosSorted:
		battleSectiosNamesSorted.append(sectio.sectioName)
	for peer in Connection.peers:
		RpcCalls.sendCombatSectios.rpc_id(peer, battleSectiosNamesSorted)
	
	var battleCount : int = 0
	# battle for each sectio
	for sectio : Sectio in battleSectiosSorted:
		triumphiratesThatWantToFlee.clear()
		# which triumphirate has the most legions in the sectio
		# first, a dict with Playerid and unitCount
		for peer in Connection.peers:
			RpcCalls.moveCamera.rpc_id(peer, sectio.global_position)
		await Signals.doneMoving
		var legionsDict = {}
		var unitsNameDict = {}
		for unitName in sectio.troops:
			var unitNames = unitName
			var unit = Data.troops[unitName]
			# only count legion strength
			if unit.unitType == Data.UnitType.Legion:
				if not legionsDict.has(unit.triumphirate):
					legionsDict[unit.triumphirate] = [unit.unitNr]
				else:
					legionsDict[unit.triumphirate] = legionsDict[unit.triumphirate] + [unit.unitNr]
			if unitsNameDict.has(unit.triumphirate):
				unitsNameDict[unit.triumphirate] = unitsNameDict[unit.triumphirate] + [unitName]
			else:
				unitsNameDict[unit.triumphirate] = [unitName]
		
		# second, two array with parallel the Playerid and unitCount
		var triumphirates = []
		var unitCount = []
		for triumphirate in legionsDict:
			triumphirates.append(triumphirate)
			unitCount.append(legionsDict[triumphirate].size())
		
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
		
		
		# all this, so that the triumphirate with the most legion, can pick his demon first
		var demonDict = {}
		for triumphirate in triumphiratesSorted:
			if Connection.peers.has(triumphirate):
				RpcCalls.pickDemonForCombat.rpc_id(triumphirate)
				print("pick demon ", Data.players[triumphirate].playerName)
				
				if Tutorial.tutorial:
					Signals.tutorial.emit(Tutorial.Topic.Combat, "Demons can help your Units in Combat. Depending on the amount on Skull they have, the survivability of Units increases. \nA Demon can only fight once per Combat Phase. \nYou can also choose to not use a Demon in Combat. \nDemons on Earth cannot fight in Hell.")
				
				var demonName = await Signals.pickedDemonInGame
				print("player ", Data.players[triumphirate].playerName, " chose demon ", demonName)
				if not demonName == 0:
					demonDict[triumphirate] = demonName
		
		for triumphirate : int in triumphiratesSorted:
			var defendChance : int = 1
			if demonDict.has(triumphirate):
				defendChance = Data.demons[demonDict[triumphirate]].skulls
			for legionNr : int in legionsDict[triumphirate]:
				for peer in Connection.peers:
					RpcCalls.showDefendChance.rpc_id(peer, legionNr, defendChance)
		
		if Tutorial.tutorial:
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
			legionsDict = {}
			unitsNameDict = {}
			var unitsNameHitPropabilityDict = {}
			var lieutenantsBonusDict = {}
			for unitName in sectio.troops:
				var unitNames = unitName
				var unit = Data.troops[unitName]
				var triumphirateName = unit.triumphirate
				# only count legion strength
				if unit.unitType == Data.UnitType.Legion:
					if not legionsDict.has(triumphirateName):
						legionsDict[triumphirateName] = [unit.unitNr]
					else:
						legionsDict[triumphirateName] = legionsDict[triumphirateName] + [unit.unitNr]
					#if not unitsDict.has(triumphirateName):
						#unitsDict[triumphirateName] = 1
					#else:
						#unitsDict[triumphirateName] += 1
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
				if not legionsDict.has(triumphirate):
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
					var winnerId : int = triumphiratesSorted.pop_front()
					addCombatWinner(winnerId, sectio.sectioName)
				sectio.reorderUnitsinSlots()
				break
			
			for peer in Connection.peers:
				RpcCalls.showCombat.rpc_id(peer, )
			
			for triumphirate in triumphiratesSorted:
				var units = unitsNameDict[triumphirate]
				var legions : Array = legionsDict[triumphirate]
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
				for legionNr : int in legions:
					for peer in Connection.peers:
						RpcCalls.showHitChance.rpc_id(peer, legionNr, 0)
				for legionNr : int in legions:
					for peer in Connection.peers:
						print("attacking legions ",legions)
						RpcCalls.unitsAttack.rpc_id(peer)
					var result : Array = Dice.roll(1)
					var result_mod : Array = result
					var hit : bool = false
					print(Data.players[triumphirate].playerName, " rolls ", result[0])
					if lieutenantsBonus.size() > 0:
#						print("bonus ",lieutenantsBonus)
						var lieutenantBonus : int = lieutenantsBonus.pop_back()
						for peer in Connection.peers:
							RpcCalls.showHitChance.rpc_id(peer, legionNr, lieutenantBonus)
						result_mod[0] += lieutenantBonus
					print(Data.players[triumphirate].playerName, " after lieutenant ", result_mod[0])
					if result_mod[0] >= 6: #3
						hits += 1
						hit = true
					for peer in Connection.peers:
						RpcCalls.showAttackResult.rpc_id(peer, legionNr, result[0], hit)
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
					var result : Array = Dice.roll(1)
					var result_mod : Array = result
					var defended : bool = false
					
					print("unit type: ", unit.unitType, " ", Data.UnitType.Lieutenant)
					print("unit name: ", unit.unitName)
					print("save: ", result[0])
					if unit.unitType == Data.UnitType.Lieutenant or unit.unitType == Data.UnitType.Hellhound:
						result_mod[0] -= 3
						print("lieute: ",3)
					else:
						if demonDict.has(unit.triumphirate):
							var demonRank = demonDict[unit.triumphirate]
	#							print(demonName, " name")
							# Lieutenants and Hellhound save on a 4. Legions use the Demon's skulls
							result_mod[0] -= Data.demons[demonRank].skulls
							print("skulls: ",Data.demons[demonRank].skulls)
					print(result_mod[0])
					if not result_mod[0] <= 1: #3
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
					else:
						defended = true
					for peer in Connection.peers:
						RpcCalls.showDefendResult.rpc_id(peer, unitName, result[0], defended)
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
			
			
			
			legionsDict = {}
			unitsNameDict = {}
			unitsNameHitPropabilityDict = {}
			lieutenantsBonusDict = {}
			for unitName in sectio.troops:
				for peer in Connection.peers:
					RpcCalls.hideHitChance.rpc_id(peer, unitName)
				var unitNames = unitName
				var unit = Data.troops[unitName]
				var triumphirateName = unit.triumphirate
				# only count legion strength
				if unit.unitType == Data.UnitType.Legion:
					if not legionsDict.has(triumphirateName):
						legionsDict[triumphirateName] = [unit.unitNr]
					else:
						legionsDict[triumphirateName] = legionsDict[triumphirateName] + [unit.unitNr]
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
				if not legionsDict.has(triumphirate):
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
				for unitName in sectio.troops:
					for peer in Connection.peers:
						RpcCalls.hideDefendChance.rpc_id(peer, unitName)
				if nobodyLeft:
					if triumphirateWithSolitaryLieutenants.size() == 1:
						combatWinner[triumphirateWithSolitaryLieutenants.pop_front()] = sectio.sectioName
					# two solitary lieutenants from different triumphirates? shouls flee...
#							else:
#								combatWinner[triumphiratesSorted.pop_front()] = sectio.sectioName
				else:
					var winnerId : int = triumphiratesSorted.pop_front()
					addCombatWinner(winnerId, sectio.sectioName)
				sectio.reorderUnitsinSlots()
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
			legionsDict = {}
			unitsNameDict = {}
			unitsNameHitPropabilityDict = {}
			lieutenantsBonusDict = {}
			for unitName in sectio.troops:
				var unitNames = unitName
				var unit = Data.troops[unitName]
				var triumphirateName = unit.triumphirate
				# only count legion strength
				if unit.unitType == Data.UnitType.Legion:
					if not legionsDict.has(triumphirateName):
						legionsDict[triumphirateName] = [unit.unitNr]
					else:
						legionsDict[triumphirateName] = legionsDict[triumphirateName] + [unit.unitNr]
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
				if not legionsDict.has(triumphirate):
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
					var winnerId : int = triumphiratesSorted.pop_front()
					addCombatWinner(winnerId, sectio.sectioName)
				sectio.reorderUnitsinSlots()
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
	
	await phase(map)
	print("combatWinner", combatWinner)


func addCombatWinner(playerId : int, sectioName : String):
	if playerId > 0:
		RpcCalls.combatWon.rpc_id(playerId)
	if combatWinner.has(playerId):
		combatWinner[playerId].append(sectioName)
	else:
		combatWinner[playerId] = [sectioName]


func _on_triumphiratesWantToFlee(triumphirat : int):
	triumphiratesThatWantToFlee.append(triumphirat)
