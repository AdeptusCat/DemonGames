extends Node


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
		Signals.placeLegion.emit(sectio, ai)
		sectio = Decks.sectioNodes["Dogs Of War"]
		Signals.placeLegion.emit(sectio, ai)
		sectio = Decks.sectioNodes["Atheists Surprise"]
		Signals.placeLegion.emit(sectio, ai)
#		Signals.placeLegion.emit(sectio, ai)
#		Signals.placeLegion.emit(sectio, ai)
#		Signals.placeLegion.emit(sectio, ai)
		return
#	return
#	if Data.id == 1:
	if Data.player.playerName == "Player 1":
		sectio = Decks.sectioNodes["Bad People"]
		Signals.placeLieutenant.emit(sectio, Data.id, "Shalmaneser")
		Signals.placeLegion.emit(sectio, Data.id)
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
		Signals.placeLegion.emit(sectio, Data.id)
		sectio = Decks.sectioNodes["Megalomaniacs"]
		Signals.placeLegion.emit(sectio, Data.id)
		sectio = Decks.sectioNodes["Dogs Of War"]
		Signals.placeLegion.emit(sectio, Data.id)
#		Signals.placeLegion.emit(sectio, Data.id)
#		Signals.placeLegion.emit(sectio, Data.id)
#		Signals.placeLegion.emit(sectio, Data.id)
#		Signals.placeLegion.emit(sectio, Data.id)
		
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
		Signals.sectioClicked.emit(Decks.sectioNodes["Liars"])
#		map._on_sectioClicked(Decks.sectioNodes["Spies"])
#		map._on_sectioClicked(Decks.sectioNodes["Traitors"])
	return
	Signals.sectioClicked.emit(Decks.sectioNodes["Bad People"])
