extends Node


func getWinnersIds() -> Array:
	var winnerIds : Array = []
	for playerId in Data.players:
		var player = Data.players[playerId]
		var circleCount = {}
		for sectioName in player.sectios:
			var sectio = Decks.sectioNodes[sectioName]
			if circleCount.has(sectio.circle):
				circleCount[sectio.circle] += 1
			else:
				circleCount[sectio.circle] = 1
			if circleCount[sectio.circle] >= 5:
				winnerIds.append(playerId)
	return winnerIds


func getPlayerIdWithMostFavorsAndFewerDisfavors(winnerIds : Array) -> int:
	var mostFavors : int = 0
	var winnerDisfavors : int = 0
	var winnerId : int = winnerIds[0]
	for playerId in winnerIds:
		var player : Player = Data.players[playerId]
		if player.favors > mostFavors:
			mostFavors = player.favors
			winnerDisfavors = player.disfavors
			winnerId = playerId
		elif player.favors == mostFavors:
			if player.disfavors < winnerDisfavors:
				mostFavors = player.favors
				winnerDisfavors = player.disfavors
				winnerId = playerId
	return winnerId


func phase() -> bool:
	var winCondition = false
	var winnerIds : Array = getWinnersIds()
	
	# players can get rid of disfavors 
	# price is two favors for one disfavor
	
	# recover from incapacitation
	# every demon that rolls 5 or 6 to recovers
	
	if winnerIds.is_empty(): 
		return false
	else:
		var winnerId : int = getPlayerIdWithMostFavorsAndFewerDisfavors(winnerIds)
		print("winner ", winnerId, winnerIds)
		for peer in Connection.peers:
			RpcCalls.win.rpc_id(peer, winnerId)
		return true
