extends MarginContainer

#signal demonDone(passAction)
signal backToHell(boolean)

@onready var skullTexture = preload("res://assets/00698-3170758600-drawing of a skull, digital art, game asset.png")
@onready var heartTexture = preload("res://assets/00690-2262657839-drawing of a heart, digital art, game asset.png")


var spellObject : Spells = Spells.new()
var player : Player
var currentDemonNode : Demon
var currentDemonRank: int:
	set(demonRank):
		currentDemonRank = demonRank
		currentDemonNode = Data.demons[currentDemonRank]
		player = Data.players[currentDemonNode.player]
		var demonName : String = currentDemonNode.demonName
		%CurrentDemonLabel.text = "Demon " + demonName
		if currentDemonNode.incapacitated:
			var result = Dice.roll(1)
			if result[0] >= 5:
				Signals.demonStatusChange.emit(currentDemonNode.rank, "recovered")
				toggleActionMenu(true)
			else:
				await get_tree().create_timer(0.1).timeout
				Signals.demonDone.emit(null)
		else:
			toggleActionMenu(true)


func _ready():
	%PassButton.disabled = true
	%WalkTheEarthButton.disabled = true
	%DoEvilDeedsButton.disabled = true
	%ConspireButton.disabled = true
	Signals.skullUsed.connect(skullUsed)
	Signals.cancelMarch.connect(_on_cancelMarch)
	Signals.doEvilDeedsResult.connect(_on_doEvilDeedsResult)
	Signals.actionThroughArcana.connect(_on_actionThroughArcana)


func _on_actionThroughArcana(minorSpell : Decks.MinorSpell):
	var MinorSpell = Decks.MinorSpell
	spellObject.objects[minorSpell].playCard(minorSpell, currentDemonRank)


func _on_cancelMarch():
	toggleActionMenu(true)


func toggleActionMenu(boolean : bool):
	if boolean:
		activateActionButtons()
		
		removeSkullsFromMenu()
		addSkullsToMenu()
		
		removeHeartsFromMenu()
		addHeartsToMenu()
		
		show()
	else:
		deactivateActionButtons()
		deactivateArcanaCards()
		hide()


func deactivateArcanaCards():
	for cardName in player.arcanaCards:
		var arcanaCard = Data.arcanaCardNodes[cardName]
		arcanaCard.disable()


func activateActionButtons():
	for cardName in player.arcanaCards:
		if not Data.arcanaCards.has(cardName):
			continue
		var arcanaCard : Dictionary = Data.arcanaCards[cardName]
		if not player.hasEnoughSouls(arcanaCard.cost):
			continue
		if not spellObject.objects.has(arcanaCard.minorSpell):
			continue
		spellObject.objects[arcanaCard.minorSpell].activatePassButton(%PassButton)
		spellObject.objects[arcanaCard.minorSpell].activateWalkTheEarthButton(%WalkTheEarthButton)
	
	%MarchButton.text = "March"
	%MarchButton.disabled = false
	
	%PassForGoodButton.disabled = false
		
	# not implemented yet
#		%AtonementAndSuplicationButton.disabled = true
	%InfluenceUnitsButton.disabled = true
	%UseMagicButton.disabled = true
	
	if currentDemonNode.onEarth:
		%DoEvilDeedsButton.disabled = false
#			%ConspireButton.disabled = false
		%WalkTheEarthButton.disabled = true
	else:
		%DoEvilDeedsButton.disabled = true
#			%ConspireButton.disabled = true


func deactivateActionButtons():
	%PassButton.disabled = true
	%WalkTheEarthButton.disabled = true


func removeSkullsFromMenu():
	for child in %SkullsHBoxContainer.get_children():
		child.queue_free()


func addSkullsToMenu():
	for skull in currentDemonNode.skulls:
		var textureRect = TextureRect.new()
		textureRect.expand_mode = textureRect.EXPAND_IGNORE_SIZE
		textureRect.custom_minimum_size = Vector2(32, 32)
		textureRect.texture = skullTexture
		%SkullsHBoxContainer.add_child(textureRect)


func removeHeartsFromMenu():
	for child in %HeartsHBoxContainer.get_children():
		child.queue_free()


func addHeartsToMenu():
	for heart in currentDemonNode.hearts:
		var textureRect = TextureRect.new()
		textureRect.expand_mode = textureRect.EXPAND_IGNORE_SIZE
		textureRect.custom_minimum_size = Vector2(32, 32)
		textureRect.texture = heartTexture
		%HeartsHBoxContainer.add_child(textureRect)


func skullUsed():
	var children = %SkullsHBoxContainer.get_children()
	children[-1].queue_free()


func _input(event):
	if visible:
		if Data.phase == Data.phases.Action:
			if Input.is_action_pressed("w"):
				if not %WalkTheEarthButton.disabled:
					%WalkTheEarthButton.pressed.emit()
			if Input.is_action_pressed("m"):
				if not Data.state == Data.States.MARCHING:
					%MarchButton.pressed.emit()
			if Input.is_action_pressed("p"):
				if not %PassButton.disabled:
					%PassButton.pressed.emit()
			if Input.is_action_pressed("g"):
				if not %PassForGoodButton.disabled:
					%PassForGoodButton.pressed.emit()
			if Input.is_action_pressed("ui_accept"):
				if Data.state == Data.States.MARCHING:
					%MarchButton.pressed.emit()


func _on_march_button_pressed():
	if not Data.state == Data.States.MARCHING:
		for peer in Connection.peers:
			RpcCalls.demonAction.rpc_id(peer, currentDemonRank, "Marching")
		if %MarchButton.text == "End March":
			%MarchButton.text = "March"
			Signals.sectiosUnclickable.emit()
		#	Signals.demonDone.emit(null)
			Signals.sectioClicked.emit(null)
			Signals.sectioClicked.emit(null)
			return
		deactivateArcanaCards()
		if not await backToHellCheck():
			return
		Signals.help.emit(Data.HelpSubjects.March)
		Signals.demonStatusChange.emit(currentDemonNode.rank, "hell")
		disableActions()
		Signals.march.emit()
		%MarchButton.text = "End March"
		%MarchButton.disabled = false
		print("march disabled z")
		if Tutorial.tutorial:
			if Tutorial.currentTopic == Tutorial.Topic.MarchAction:
				Signals.tutorialRead.emit()
	#	print(player, " player troops ",player.troops)
	#	Signals.sectiosClickable.emit()
	#	for troop in player.troops.values():
	#		troop.changeClickable(true)
	#	emit_signal("demonDone", null)
	else:
		for peer in Connection.peers:
			RpcCalls.demonAction.rpc_id(peer, currentDemonRank, "")
		%MarchButton.text = "March"
		Signals.sectiosUnclickable.emit()
	#	Signals.demonDone.emit(null)
		Signals.sectioClicked.emit(null)
		Signals.sectioClicked.emit(null)
		if Tutorial.tutorial:
			if Tutorial.currentTopic == Tutorial.Topic.MarchAction:
				Signals.tutorialRead.emit()
				
				

func _on_pass_button_pressed():
	deactivateArcanaCards()
	for cardName in player.arcanaCards:
		var arcanaCard : ArcanaCard = Data.arcanaCardNodes[cardName]
		if not player.hasEnoughSouls(arcanaCard.cost):
			continue
		spellObject.objects[arcanaCard.minorSpell].highlightPassCard(arcanaCard)
	Signals.tutorialRead.emit()


func _on_pass_for_good_button_pressed():
	for peer in Connection.peers:
		RpcCalls.demonAction.rpc_id(peer, currentDemonRank, "Pass For Good")
	Signals.demonDone.emit(0)
	AudioSignals.passForGood.emit()



func passTurns(demonsPassed):
	for peer in Connection.peers:
		RpcCalls.demonAction.rpc_id(peer, currentDemonRank, "Pass")
	Signals.demonDone.emit(demonsPassed)
	AudioSignals.passAction.emit()


func walkTheEarth():
	for peer in Connection.peers:
		RpcCalls.demonAction.rpc_id(peer, currentDemonRank, "Walk The Earth")
	Signals.demonDone.emit(null)
	AudioSignals.walkTheEarth.emit()
	Signals.incomeChanged.emit(Data.id)


func _recruitLieutenant():
	Signals.recruitLieutenant.emit()
#	emit_signal("demonDone", null)


func _on_walk_the_earth_button_pressed():
	deactivateArcanaCards()
	for cardName in player.arcanaCards:
		var arcanaCard = Data.arcanaCardNodes[cardName]
		if not player.hasEnoughSouls(arcanaCard.cost):
			continue
		spellObject.objects[arcanaCard.minorSpell].highlightWalkTheEarthCard(arcanaCard)
	Signals.tutorialRead.emit()


func _on_do_evil_deeds_button_pressed():
	deactivateArcanaCards()
	var result = Dice.roll(currentDemonNode.hearts)
	var favorsGathered = 0
	for roll in result:
		if roll >= 6:
			favorsGathered += 1
			for peer in Connection.peers:
				earnFavor.rpc_id(peer, currentDemonNode.player)
			print(currentDemonNode, " evil deeds earned a favor on earth")
		else:
			print(currentDemonNode, " evil deeds didnt earn a favor on earth")
	
	for peer in Connection.peers:
		RpcCalls.demonAction.rpc_id(peer, currentDemonRank, "Do Evil Deeds: " + str(favorsGathered))
	for peer in Connection.peers:
		doEvilDeedsResult.rpc_id(peer, currentDemonNode.player, currentDemonNode.demonName, favorsGathered)
	
	if Tutorial.tutorial:
		if Tutorial.currentTopic == Tutorial.Topic.DoEvilDeeds:
			Signals.tutorialRead.emit()
			Signals.tutorial.emit(Tutorial.Topic.DoEvilDeedsResult, "You can always see the History of Actions and their Result on the Rank Track.")
			await Signals.tutorialRead
	Signals.demonDone.emit(null)


func _on_doEvilDeedsResult(playerId : int, demonName : String, favorsGathered : int):
	for peer in Connection.peers:
		doEvilDeedsResult.rpc_id(peer, playerId, demonName, favorsGathered)


@rpc("any_peer", "call_local")
func doEvilDeedsResult(player_id : int, demonName : String, favors : int):
	if Settings.skipWaitForPlayers:
		return
	if favors == 0:
		%DoEvilDeedsLabel.text = demonName + " gatherd no Favors on Earth."
	elif favors == 1:
		%DoEvilDeedsLabel.text = demonName + " gatherd " + str(favors) + " Favor on Earth."	
	elif favors > 1:
		%DoEvilDeedsLabel.text = demonName + " gatherd " + str(favors) + " Favors on Earth."
	Signals.showDoEvilDeedsControl.emit(player_id)


@rpc("any_peer", "call_local")
func earnFavor(playerId):
	var favors = Data.players[playerId].favors + 1
	favors = clamp(favors, 0, 20)
	Data.players[playerId].favors = favors
	if playerId == Data.id:
		Data.player.favors = favors


@rpc("any_peer", "call_local")
func loseDisfavor(playerId):
	var disfavors = Data.players[playerId].disfavors - 1
	disfavors = clamp(disfavors, 0, 20)
	Data.players[playerId].disfavors = disfavors
	if playerId == Data.id:
		Data.player.disfavors = disfavors

func _on_conspire_button_pressed():
	for peer in Connection.peers:
		RpcCalls.demonAction.rpc_id(peer, currentDemonRank, "Conspire")
	deactivateArcanaCards()
	pass # Replace with function body.


func _on_influence_units_button_pressed():
	for peer in Connection.peers:
		RpcCalls.demonAction.rpc_id(peer, currentDemonRank, "Influence Units")
	deactivateArcanaCards()
	if not await backToHellCheck():
		return
	Signals.demonStatusChange.emit(currentDemonNode.rank, "hell")
	pass # Replace with function body.


func _on_atonement_and_suplication_button_pressed():
	for peer in Connection.peers:
		RpcCalls.demonAction.rpc_id(peer, currentDemonRank, "Atonement And Suplication")
	deactivateArcanaCards()
	if not await backToHellCheck():
		return
	Signals.demonStatusChange.emit(currentDemonNode.rank, "hell")
	var DiceResults = Dice.roll(2)
	var addedResult = DiceResults[0] + DiceResults[1]
	var index
	if addedResult >= 11:
		index = 4
	elif addedResult >= 9:
		index = 3
	elif addedResult >= 7:
		index = 2
	elif addedResult >= 5:
		index = 1
	elif addedResult >= 2:
		index = 0
	var heartsIndex
	if currentDemonNode.hearts >= 5:
		heartsIndex = 5
	elif currentDemonNode.hearts >= 3:
		heartsIndex = 3
	elif currentDemonNode.hearts >= 2:
		heartsIndex = 2
	elif currentDemonNode.hearts >= 1:
		heartsIndex = 1
	var table = {"hearts" : {
		1 : [null, 0, 0, 1, 1],
		2 : [null, 0, 0, 1, 2],
		3 : [null, 0, 1, 1, 2],
		5 : [null, null, 0, 2 ,3]
		}}
	var result = table["hearts"][heartsIndex][index]
	if result:
		for i in result:
			for peer in Connection.peers:
				loseDisfavor.rpc_id(peer, currentDemonNode.player)
	else:
		Signals.demonStatusChange.emit(currentDemonNode.rank, "incapacitated")
	Signals.demonDone.emit(null)


func _on_use_magic_button_pressed():
	for peer in Connection.peers:
		RpcCalls.demonAction.rpc_id(peer, currentDemonRank, "Using Magic")
	deactivateArcanaCards()
	if not await backToHellCheck():
		return
	Signals.demonStatusChange.emit(currentDemonNode.rank, "hell")
	pass # Replace with function body.


func backToHellCheck():
	if currentDemonNode.onEarth:
		%BackToHellConfirmationDialog.popup()
		var result = await backToHell
		if not result:
			return false
		else:
			return true
	else:
		return true


func _on_end_button_pressed():
	Signals.sectiosUnclickable.emit()
#	Signals.demonDone.emit(null)
	Signals.sectioClicked.emit(null)
	Signals.sectioClicked.emit(null)


func disableActions():
	%MarchButton.disabled = true
	print("march disabled1")
	%WalkTheEarthButton.disabled = true
	%PassButton.disabled = true
	%PassForGoodButton.disabled = true
	%DoEvilDeedsButton.disabled = true
	%ConspireButton.disabled = true
	%InfluenceUnitsButton.disabled = true
	%AtonementAndSuplicationButton.disabled = true
	%UseMagicButton.disabled = true


func _on_back_to_hell_confirmation_dialog_cancelled():
	backToHell.emit(false)


func _on_back_to_hell_confirmation_dialog_confirmed():
	backToHell.emit(true)


