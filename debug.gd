extends Node


func debugSectios():
	return
	for peer in Connection.peers:
#		occupySectio.rpc_id(peer, Ai.playerIds[0], "The Wise Men")
#		RpcCalls.occupySectio.rpc_id(peer, Data.id, "The Wise Men")
	#	occupySectio.rpc_id(peer, 1, "Thieves")
	#	occupySectio.rpc_id(peer, 1, "The Envious")
	#	occupySectio.rpc_id(peer, 1, "Sugar Hill")

		RpcCalls.occupySectio.rpc_id(peer, Data.id, "The Wise Men")
		#RpcCalls.occupySectio.rpc_id(peer, Data.id, "Sugar Hill")
		#RpcCalls.occupySectio.rpc_id(peer, Data.id, "Addiction")
		#RpcCalls.occupySectio.rpc_id(peer, Data.id, "Sea Of Lard")
		#RpcCalls.occupySectio.rpc_id(peer, Data.id, "The Insatiable")
		#RpcCalls.occupySectio.rpc_id(peer, Data.id, "Tavern Of Endless Revelry")
	#
		#RpcCalls.occupySectio.rpc_id(peer, Connection.aiPlayersId[0], "Traitors")
		#RpcCalls.occupySectio.rpc_id(peer, Connection.aiPlayersId[0], "Betrayers of Confidence")
		#RpcCalls.occupySectio.rpc_id(peer, Connection.aiPlayersId[0], "Adulterers In Heat")
		#RpcCalls.occupySectio.rpc_id(peer, Connection.aiPlayersId[0], "Desecrators Of The Flesh")
		#RpcCalls.occupySectio.rpc_id(peer, Connection.aiPlayersId[0], "Spies")


func debugFavors():
	return
	Signals.changeFavors.emit(Connection.aiPlayersId[0], 3)
	Signals.changeFavors.emit(Data.id, 3)


func debugDisfavors():
	return
	Signals.changeDisfavors.emit(Connection.aiPlayersId[0], 1)
	Signals.changeDisfavors.emit(Data.id, 2)


@rpc("any_peer", "call_local")
func spawnDebugTroops1(ai : int = 0):
	var sectio
	if Connection.dedicatedServer:
		return
	if not ai == 0:
		sectio = Decks.sectioNodes["Megalomaniacs"]
		Signals.placeLegion.emit(sectio, ai)
		sectio = Decks.sectioNodes["Bad People"]
		Signals.placeLieutenant.emit(sectio, ai, "Shalmaneser")
		Signals.placeLegion.emit(sectio, ai)
		#Signals.placeLegion.emit(sectio, ai)
		#Signals.placeLegion.emit(sectio, ai)
		#Signals.placeLegion.emit(sectio, ai)
		#Signals.placeLegion.emit(sectio, ai)
		#Signals.placeLegion.emit(sectio, ai)
		sectio = Decks.sectioNodes["Dogs Of War"]
		Signals.placeLegion.emit(sectio, ai)
		Signals.placeLegion.emit(sectio, ai)
		sectio = Decks.sectioNodes["Atheists Surprise"]
		Signals.placeLegion.emit(sectio, ai)
		Signals.placeLegion.emit(sectio, ai)
		Signals.placeLegion.emit(sectio, ai)
		sectio = Decks.sectioNodes["Liars"]
		Signals.placeLegion.emit(sectio, ai)
		Signals.placeLegion.emit(sectio, ai)
		Signals.placeLegion.emit(sectio, ai)
		Signals.placeLegion.emit(sectio, ai)
		sectio = Decks.sectioNodes["Sowers Of Scandal"]
		Signals.placeLegion.emit(sectio, ai)
		sectio = Decks.sectioNodes["Basement Of Wanton Killers"]
		Signals.placeLegion.emit(sectio, ai)
#		Signals.placeLegion.emit(sectio, ai)
#		Signals.placeLegion.emit(sectio, ai)
#		Signals.placeLegion.emit(sectio, ai)
		return
#	return
#	if Data.id == 1:
	#if Data.player.playerName == "Player 1":
		#sectio = Decks.sectioNodes["Bad People"]
		#Signals.placeLieutenant.emit(sectio, Data.id, "Shalmaneser")
		#Signals.placeLegion.emit(sectio, Data.id)
		#Signals.placeLegion.emit(sectio, ai)
		#Signals.placeLegion.emit(sectio, ai)
		#Signals.placeLegion.emit(sectio, ai)
		#Signals.placeLegion.emit(sectio, ai)
		#Signals.placeLegion.emit(sectio, ai)
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
		#Signals.placeLieutenant.emit(sectio, Data.id, "Shalmaneser")
		Signals.placeLegion.emit(sectio, Data.id)
		Signals.placeLegion.emit(sectio, Data.id)
		Signals.placeLegion.emit(sectio, Data.id)
		Signals.placeLegion.emit(sectio, Data.id)
		Signals.placeLegion.emit(sectio, Data.id)
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
		sectio = Decks.sectioNodes["Basement Of Wanton Killers"]
		Signals.placeLegion.emit(sectio, Data.id)
#		sectio = Decks.sectioNodes["Dogs Of War"]
#		map.placeUnit(sectio, Data.UnitType.Legion)
		sectio = Decks.sectioNodes["Sowers Of Scandal"]
		Signals.placeLegion.emit(sectio, Data.id)
		
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
		sectio = Decks.sectioNodes["Liars"]
		Signals.placeLegion.emit(sectio, Data.id)
#		map._on_sectioClicked(Decks.sectioNodes["Traitors"])
	return
	Signals.sectioClicked.emit(Decks.sectioNodes["Bad People"])
