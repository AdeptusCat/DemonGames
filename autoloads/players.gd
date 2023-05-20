extends Node


func _ready():
	Signals.changeSouls.connect(_on_changeSouls)
	Signals.changeIncome.connect(_on_changeIncome)
	Signals.changeFavors.connect(_on_changeFavors)
	Signals.changeDisfavors.connect(_on_changeDisfavors)


func canAffordRecruitLieutenants(playerNr, cardNameToIgnore = ""):
	var player = Data.players[playerNr]
	var arcanaCardsNames = player.arcanaCards
	for cardName in arcanaCardsNames:
		if is_instance_valid(Data.arcanaCardNodes[cardName]):
			if not cardName == cardNameToIgnore:
				var arcanaCard = Data.arcanaCardNodes[cardName]
				arcanaCard.disable()
				if not player.hasEnoughSouls(arcanaCard.cost):
					continue
				var MinorSpell = Decks.MinorSpell
				if arcanaCard.minorSpell == MinorSpell.RecruitLieutenants and Data.player.arcanaCards.size() <= 5:
					arcanaCard.highlight()


func _on_changeSouls(playerId : int, value : int):
	print("change soulssss")
	for peer in Connection.peers:
		changeSouls.rpc_id(peer, playerId, value)


func _on_changeIncome(playerId : int, value : String):
	for peer in Connection.peers:
		changeIncome.rpc_id(peer, playerId, value)


func _on_changeFavors(playerId : int, value : int):
	for peer in Connection.peers:
		changeFavors.rpc_id(peer, playerId, value)


func _on_changeDisfavors(playerId : int, value : int):
	for peer in Connection.peers:
		changeDisfavors.rpc_id(peer, playerId, value)


@rpc("any_peer", "call_local")
func changeSouls(playerId : int, value : int):
	print("change souls ", Data.id, " ", playerId, " ",value)
	Data.players[playerId].souls = value
#	if playerId == Data.id:
#		Data.player.souls = value


@rpc("any_peer", "call_local")
func changeIncome(playerId : int, value : String):
	print("change income ", Data.id, " ", playerId, " ",value)
	Data.players[playerId].income = value
#	if playerId == Data.id:
#		Data.player.souls = value


@rpc("any_peer", "call_local")
func changeFavors(playerId : int, value : int):
	Data.players[playerId].favors = value
#	if playerId == Data.id:
#		Data.player.favors = value


@rpc("any_peer", "call_local")
func changeDisfavors(playerId : int, value : int):
	Data.players[playerId].disfavors = value
#	if playerId == Data.id:
#		Data.player.disfavors = value
