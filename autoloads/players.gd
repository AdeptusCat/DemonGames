extends Node


func _ready():
	Signals.changeSouls.connect(_on_changeSouls)
	Signals.changeSoulsInUI.connect(_on_changeSoulsInUI)
	Signals.changeIncome.connect(_on_changeIncome)
	Signals.changeFavors.connect(_on_changeFavors)
	Signals.changeFavorsInUI.connect(_on_changeFavorsInUI)
	Signals.changeDisfavors.connect(_on_changeDisfavors)
	Signals.incomeChanged.connect(_on_incomeChanged)
	Signals.buyArcanaCard.connect(_on_buyArcanaCard)


func _on_buyArcanaCard():
	Data.player.checkPlayerSummoningCapabilities(5)
	if Data.player.hasEnoughSouls(5):
		var souls = Data.players[Data.id].souls - 5
		Signals.changeSouls.emit(Data.id, souls)
		Signals.changeSoulsInUI.emit(Data.id, souls)
		RpcCalls.requestArcanaCardsToPick.rpc_id(Connection.host)


func _on_incomeChanged(playerId : int):
	var player = Data.players[playerId]
	player.changeIncome()


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
	for peer in Connection.peers:
		changeSouls.rpc_id(peer, playerId, value)


func _on_changeSoulsInUI(playerId : int, value : int):
	changeSoulsInUI.rpc_id(playerId, playerId, value)


func _on_changeIncome(playerId : int, value : String):
	for peer in Connection.peers:
		changeIncome.rpc_id(peer, playerId, value)


func _on_changeFavors(playerId : int, value : int):
	for peer in Connection.peers:
		changeFavors.rpc_id(peer, playerId, value)


func _on_changeFavorsInUI(playerId : int, value : int):
	changeFavorsInUI.rpc_id(playerId, playerId, value)


func _on_changeDisfavors(playerId : int, value : int):
	for peer in Connection.peers:
		changeDisfavors.rpc_id(peer, playerId, value)


@rpc("any_peer", "call_local")
func changeSouls(playerId : int, value : int):
	Data.players[playerId].souls = value
#	if playerId == Data.id:
#		Data.player.souls = value


@rpc("any_peer", "call_local")
func changeSoulsInUI(playerId : int, value : int):
	Signals.changeSoulsInUiContainer.emit(value)


@rpc("any_peer", "call_local")
func changeFavorsInUI(playerId : int, value : int):
	Signals.changeFavorsInUiContainer.emit(value)
#	if playerId == Data.id:
#		Data.player.souls = value



@rpc("any_peer", "call_local")
func changeIncome(playerId : int, value : String):
	Data.players[playerId].income = value
#	if playerId == Data.id:
#		Data.player.souls = value


@rpc("any_peer", "call_local")
func changeFavors(playerId : int, value : int):
	Data.players[playerId].favors = value
	#if playerId == Data.id:
		#Signals.changeFavorsInUI.emit(value)
#	if playerId == Data.id:
#		Data.player.favors = value


@rpc("any_peer", "call_local")
func changeDisfavors(playerId : int, value : int):
	Data.players[playerId].disfavors = value
#	if playerId == Data.id:
#		Data.player.disfavors = value
