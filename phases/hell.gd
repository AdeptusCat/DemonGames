extends Node


func phase():
	for playerId in Data.players:
		var player = Data.players[playerId]
		var cardsToDraw = 5 - player.arcanaCards.size()
		print(playerId, " need to draw ", cardsToDraw)
		for i in range(cardsToDraw):
			var CardName : String = Decks.getRandomCard("arcana")
			for peer in Connection.peers:
				RpcCalls.addArcanaCard.rpc_id(peer, playerId, CardName)
