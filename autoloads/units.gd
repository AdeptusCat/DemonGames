extends Node


func _ready():
	Signals.recruitLegions.connect(_on_recruit_legions)
	Signals.tamingHellhound.connect(_on_taming_hellhound)
	Signals.recruitLieutenant.connect(_on_recruit_lieutenant)
	Signals.recruitingDone.connect(_on_recruitingDone)
	Signals.recruiting.connect(_on_recruiting)

func _on_recruit_legions():
	Signals.recruiting.emit()
	Data.changeState(Data.States.RECRUITING)
	
	Sectios.sectiosWithoutEnemiesClickable()
	
	while true:
		var sectio : Sectio = await Signals.sectioClicked
		if sectio == null:
			break
		if Data.player.hasEnoughSouls(3):
			Signals.placeLegion.emit(sectio, Data.id)
			var souls = Data.players[sectio.player].souls - 3
			Signals.changeSouls.emit(sectio.player, souls)
			#Signals.changeSoulsInUI.emit(sectio.player, souls)
			Signals.emitSoulsFromTreasury.emit(sectio.get_global_transform_with_canvas().origin, 3)
			if not Data.player.hasEnoughSouls(3):
				break
			
			Sectios.sectiosLeftClickable(sectio.sectioName)
			Signals.tutorialRead.emit()
	
	Data.changeState(Data.States.IDLE)
	Signals.recruitingDone.emit()


func _on_recruiting():
	Signals.toggleRecruitLegionsButton.emit(false)


func _on_recruitingDone():
	Signals.toggleEndPhaseButton.emit(true)
	for sectioName in Data.player.sectiosWithoutEnemies:
		Decks.sectioNodes[sectioName].changeClickable(false)
	Data.player.checkPlayerSummoningCapabilities(0)


func _on_recruit_lieutenant(lieutenantName : String):
	Signals.recruiting.emit()
	Signals.toggleEndPhaseButton.emit(false)
	Signals.toggleBuyArcanaCardButton.emit(false)
	
	Sectios.sectiosClickable(Data.player.sectiosWithoutEnemies)
	
	var sectio = await Signals.sectioClicked
	
	Signals.placeLieutenant.emit(sectio, Data.id, lieutenantName)
	
	if Data.player.hasEnoughSouls(3):
		Sectios.remainingSectiosClickable(Data.player.sectiosWithoutEnemies.duplicate())
	else:
		Sectios.sectiosUnclickable(Data.player.sectiosWithoutEnemies)
	
	Signals.recruitingDone.emit()
	
	if Tutorial.tutorial:
		Signals.tutorialRead.emit()


func _on_taming_hellhound():
	var result = Dice.roll(1)
	if result[0] <= 4:
		pass
	elif result[0] == 5:
		pass
	elif result[0] == 6:
		pass
#		map.removeUnit.rpc_id(peer, unitName)
