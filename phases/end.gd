extends Node


func phase() -> bool:
	var winCondition = false
	var winner
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
				winCondition = true
				winner = playerId
				
	if winCondition: 
		for peer in Connection.peers:
			RpcCalls.win.rpc_id(peer, winner)
		return true
	else:
		return false
