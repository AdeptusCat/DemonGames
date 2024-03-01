extends CanvasLayer
class_name UI

@export var playerIcon : CompressedTexture2D

@export var PickMoveUnitVBoxContainerScene : PackedScene
@export var menuContainer : PackedScene
@export var pickLegionsScene : PackedScene
@export var arcanaScene : PackedScene
@export var playerDisconnectedContainer : PackedScene

@onready var currentPlayerLabel = %CurrentPlayerLabel
@onready var fleeControl = %FleeControl
@onready var waitForPlayerControl = %WaitForPlayerControl
@onready var waitForPlayerLabel = %WaitForPlayerLabel

@export var pickUnitControl : PackedScene
@export var actionsMenu : PackedScene
@export var summoningMenu : PackedScene
@export var actionMenu : PackedScene


var actionMenuScene : Control
var summoningMenuScene : Control

var sectioTextures : Dictionary = {}

var currentDemonRoot : TreeItem
var currentDemonEntries : Dictionary = {}
var demonActions : Dictionary = {}
var iconColorVisible : Color = Color8(200,200,200,255)
var iconColorInvisible : Color = Color8(200,200,200,0)

var rankTrack: Array:
	set(array):
		rankTrack = array
		%RankTrack.rankTrack = rankTrack
		print(Data.id, " updating ranktrack")


func _ready():
	Signals.emitSoulsFromCollectionPosition.connect(_on_emitSoulsFromCollectionPosition)
	Signals.emitSoulsFromTreasury.connect(_on_emitSoulsFromTreasury)
	Signals.emitFavorsFromCollectionPosition.connect(_on_emitFavorsFromCollectionPosition)
	Signals.emitFavorsFromTreasury.connect(_on_emitFavorsFromTreasury)
	Signals.showSectioPreview.connect(showSectioPreview)
	Signals.hideSectioPreview.connect(hideSectioPreview)
	Signals.showFleeControl.connect(showFleeControl)
	Signals.hideFleeControl.connect(hideFleeControl)
	Signals.showMessage.connect(showMessage)
	Signals.hideMessage.connect(hideMessage)
	Signals.pickLegions.connect(pickLegions)
	Signals.toogleSummoningMenu.connect(_on_toogleSummoningMenu)
	Signals.toogleBuyLieutenant.connect(toogleBuyLieutenant)
	Signals.toggleDiscardArcanaCardControl.connect(_on_toggleDiscardArcanaCardControl)
	Signals.hidePickArcanaCardContainer.connect(_on_hidePickArcanaCardContainer)
	Signals.fleeDialog.connect(_on_fleeDialog)
	Signals.forceFleeDialog.connect(_on_forceFleeDialog)
	Signals.pickUnit.connect(_on_pickUnit)
	
	Signals.menu.connect(_on_menu)
	Signals.toogleWaitForPlayer.connect(toogleWaitForPlayer)
	Signals.addArcanaCardToUi.connect(addArcanaCard)
	Signals.updateRankTrack.connect(_on_updateRankTrack)
	Signals.fillPickArcanaCardsContainer.connect(fillPickArcanaCardsContainer)
	Signals.removeDemon.connect(removeDemon)
	Signals.changePlayerName.connect(changePlayerName)
	
	Signals.showArcanaCardsContainer.connect(_on_showArcanaCardsContainer)
	Signals.hideArcanaCardsContainer.connect(_on_hideArcanaCardsContainer)
	Signals.showRankTrackMarginContainer.connect(_on_showRankTrackMarginContainer)

	Signals.updateTurnTrack.connect(_on_updateTurnTrack)
	
	Signals.tutorial.connect(_on_tutorial)
	Signals.tutorialRead.connect(_on_tutorialRead)
	
	
	Server.playerLeft.connect(_on_playerLeft)
	
	Signals.action.connect(_on_action)
	
	Signals.playerDoneWithPhase.connect(_on_playerDoneWithPhase)
	Signals.toggleAvailableLieutenants.connect(_on_toggleAvailableLieutenants)
	Signals.showChosenLieutenantFromAvailableLieutenantsBox.connect(_on_showChosenLieutenantFromAvailableLieutenantsBox)
	
	currentDemonRoot = %CurrentDemonTopTree.create_item()
	%CurrentDemonTopTree.set_column_title(0, "")
	%CurrentDemonTopTree.set_column_title(1, "Demon")
	%CurrentDemonTopTree.set_column_title(2, "Status")
	%CurrentDemonTopTree.set_column_title(3, "Action")
	%CurrentDemonTopTree.set_column_expand_ratio(0, 1)
	%CurrentDemonTopTree.set_column_expand_ratio(1, 3)
	%CurrentDemonTopTree.set_column_expand_ratio(2, 1)
	%CurrentDemonTopTree.set_column_expand_ratio(3, 2)
#	%WaitForPlayerControl.modulate.a = 1.0
#	%WaitForPlayerControl.show()
##			await get_tree().create_timer(10.0).timeout
##			%WaitForPlayerControl.hide()
#	var tw1 = get_tree().create_tween()
#	tw1.set_trans(Tween.TRANS_QUAD)
#	tw1.set_ease(Tween.EASE_IN)
#	tw1.tween_property(%WaitForPlayerControl, "modulate", Color(1,1,1,0), 2.0)#.set_delay(0.5)
#	tw1.tween_callback(turn)


func _on_emitSoulsFromTreasury(position : Vector2, soulsGathered : int):
	for soul in soulsGathered:
		var label = load("res://scenes/ui/soul_phase/soul.tscn").instantiate()
		label.position = %SoulsMarginContainer.global_position
		label.targetPosition = position
		add_child(label)
		label.pay()
		await get_tree().create_timer(0.3).timeout


func _on_emitSoulsFromCollectionPosition(position : Vector2, soulsGathered : int):
	for soul in soulsGathered:
		var label = load("res://scenes/ui/soul_phase/soul.tscn").instantiate()
		label.position = position
		label.targetPosition = %SoulsMarginContainer.global_position
		add_child(label)
		label.collect()
		await get_tree().create_timer(0.3).timeout


func _on_emitFavorsFromCollectionPosition(position : Vector2, favorsGathered : int):
	for favor in favorsGathered:
		var label = load("res://scenes/ui/soul_phase/favor.tscn").instantiate()
		label.position = position
		label.targetPosition = %FavorMarginContainer.global_position
		add_child(label)
		label.collect()
		await get_tree().create_timer(0.3).timeout


func _on_emitFavorsFromTreasury(position : Vector2, favorsGathered : int):
	for favor in favorsGathered:
		var label = load("res://scenes/ui/soul_phase/favor.tscn").instantiate()
		label.position = %FavorMarginContainer.global_position
		label.targetPosition = position
		add_child(label)
		label.pay()
		await get_tree().create_timer(0.3).timeout


func highlightCurrentPlayer(player : Player = null):
	Signals.showRankTrackMarginContainer.emit()
	for entryD in currentDemonEntries:
		if currentDemonEntries.has(entryD):
			if is_instance_valid(currentDemonEntries[entryD]):
				currentDemonEntries[entryD].free()
				currentDemonEntries.erase(entryD)
	if not player:
		%CurrentDemonTopTree.hide()
		%CurrentActionLabel.hide()
		return
	%CurrentDemonTopTree.show()
	%CurrentActionLabel.show()
	%CurrentDemonTopTree.set_column_title(0, "")
	%CurrentDemonTopTree.set_column_title(1, "Player")
	%CurrentDemonTopTree.set_column_title(2, "Phase")
	%CurrentDemonTopTree.set_column_title(3, "")
	%CurrentActionLabel.text = "Current Player"
	var line = %CurrentDemonTopTree.create_item(currentDemonRoot)
	line.set_icon(0, playerIcon)
	line.set_icon_modulate(0, iconColorVisible)
	line.set_text_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)
	line.set_selectable(0, false)
	line.set_text(1, player.playerName)
	line.set_metadata(1, 0)
	line.set_custom_color(1, player.color)
	line.set_text_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)
	line.set_selectable(1, true)
	var phaseName : String
	if Data.phases.values().has(Data.phase):
		phaseName = Data.phases.keys()[Data.phase]
	else:
		phaseName = "Place Legion"
	line.set_text(2, phaseName)
	line.set_text_alignment(2, HORIZONTAL_ALIGNMENT_CENTER)
	line.set_selectable(2, false)
	line.set_selectable(3, false)
	line.set_text_alignment(3, HORIZONTAL_ALIGNMENT_CENTER)
	currentDemonEntries[0] = line


func highlightCurrentDemon(rank):
	Signals.showRankTrackMarginContainer.emit()
	%CurrentDemonTopTree.show()
	%CurrentActionLabel.show()
	%CurrentDemonTopTree.set_column_title(0, "")
	%CurrentDemonTopTree.set_column_title(1, "Demon")
	%CurrentDemonTopTree.set_column_title(2, "Status")
	%CurrentDemonTopTree.set_column_title(3, "Action")
	%CurrentActionLabel.text = "Current Demon"
	for entry in %RankTrack.entries:
		if entry == rank:
			%RankTrack.entries[entry].set_icon_modulate(0, iconColorVisible)
			for entryD in currentDemonEntries:
				if currentDemonEntries.has(entryD):
					if is_instance_valid(currentDemonEntries[entryD]):
						currentDemonEntries[entryD].free()
						currentDemonEntries.erase(entryD)
			_on_addCurrentDemonLine(rank)
		else:
			%RankTrack.entries[entry].set_icon_modulate(0, iconColorInvisible)
			
#	var line = entries[rank]
#	line.set_custom_bg_color(0, Data.players[demonLabelsByRank[rank].player].color, true)


func _on_addCurrentDemonLine(demonRank):
	var demonName = Data.demons[demonRank].demonName
	var status = ""
	if Data.demons[demonRank].onEarth:
		status = "On Earth"
	elif Data.demons[demonRank].incapacitated:
		status = "Incapacitated"
	else:
		status = "In Hell"
	
	var player = Data.players[Data.demons[demonRank].player]
	var color = player.color
	var line = %CurrentDemonTopTree.create_item(currentDemonRoot)
	line.set_icon(0, playerIcon)
	line.set_icon_modulate(0, iconColorVisible)
	line.set_text_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)
	line.set_selectable(0, false)
	line.set_text(1, demonName)
	line.set_metadata(1, demonRank)
	line.set_custom_color(1, color)
	line.set_text_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)
	line.set_selectable(1, true)
	line.set_text(2, status)
	line.set_text_alignment(2, HORIZONTAL_ALIGNMENT_CENTER)
	line.set_selectable(2, false)
	if demonActions.has(demonRank):
		line.set_text(3, demonActions[demonRank])
	else:
		line.set_text(3, "")
	line.set_text_alignment(3, HORIZONTAL_ALIGNMENT_CENTER)
	line.set_selectable(3, false)
	currentDemonEntries[demonRank] = line


func _on_action(demonRank : int, action : String):
	if demonRank == 0:
		if currentDemonEntries.size() > 0:
			for rank in demonActions:
				demonActions[rank] = ""
			for entry in currentDemonEntries:
				currentDemonEntries[entry].set_text(3, "")
			for entry in %RankTrack.entries:
				if %RankTrack.entries[entry]:
					%RankTrack.entries[entry].set_text(3, "")
	else:
		demonActions[demonRank] = action
		if currentDemonEntries.has(demonRank):
				if is_instance_valid(currentDemonEntries[demonRank]):
					currentDemonEntries[demonRank].set_text(3, action)
		%RankTrack.entries[demonRank].set_text(3, action)


func _on_playerLeft(playerId : int):
	if Data.players.has(playerId):
		var scene = playerDisconnectedContainer.instantiate()
		scene.playerName = Data.players[playerId].playerName
		add_child(scene)





func _on_tutorial(topic, text : String):
	Signals.disableActionMenuButtons.emit()
	match topic:
		Tutorial.Topic.PlayersTree:
			var pos : Transform2D = %PlayersTree.get_global_transform_with_canvas()
			%PlayersTree.top_level = true
			%PlayersTree.global_position = pos.origin
		Tutorial.Topic.NextDemon:
			var pos : Transform2D = %NextDemonContainer.get_global_transform_with_canvas()
			%NextDemonContainer.top_level = true
			%NextDemonContainer.global_position = pos.origin
		Tutorial.Topic.CurrentPlayer:
			%RankTrackMarginContainer.z_index = 1
		Tutorial.Topic.PlayerStatus:
			%PlayersTree.z_index = 1
		Tutorial.Topic.RecruitLieutenantAttempt:
			var pos : Transform2D = %ArcanaCardsMarginContainer.get_global_transform_with_canvas()
			%ArcanaCardsMarginContainer.top_level = true
			%ArcanaCardsMarginContainer.global_position = pos.origin
		Tutorial.Topic.PickArcanaCard:
			var pos : Transform2D = %PickArcanaCardContainer.get_global_transform_with_canvas()
			%PickArcanaCardContainer.top_level = true
			%PickArcanaCardContainer.global_position = pos.origin
		Tutorial.Topic.RecruitLieutenantCard:
			var pos : Transform2D = %ArcanaCardsMarginContainer.get_global_transform_with_canvas()
			%ArcanaCardsMarginContainer.top_level = true
			%ArcanaCardsMarginContainer.global_position = pos.origin
		Tutorial.Topic.RankTrack:
			var pos : Transform2D = %RankTrackMarginContainer.get_global_transform_with_canvas()
			%RankTrackMarginContainer.top_level = true
			%RankTrackMarginContainer.global_position = pos.origin
		Tutorial.Topic.ClickDemonOnRankTrack:
			var pos : Transform2D = %RankTrackMarginContainer.get_global_transform_with_canvas()
			%RankTrackMarginContainer.top_level = true
			%RankTrackMarginContainer.global_position = pos.origin
		Tutorial.Topic.DemonDetails:
			var pos : Transform2D = %DemonDetailsControl.get_global_transform_with_canvas()
			%DemonDetailsControl.top_level = true
			%DemonDetailsControl.global_position = pos.origin
		Tutorial.Topic.PassAction:
			%PassButton.disabled = false
			%PassButton.get_material().set_shader_parameter("active", true)
		Tutorial.Topic.Pass:
			var pos : Transform2D = %ArcanaCardsMarginContainer.get_global_transform_with_canvas()
			%ArcanaCardsMarginContainer.top_level = true
			%ArcanaCardsMarginContainer.global_position = pos.origin
		Tutorial.Topic.WalkTheEarthAttempt:
			%WalkTheEarthButton.disabled = false
			%WalkTheEarthButton.get_material().set_shader_parameter("active", true)
		Tutorial.Topic.WalkTheEarth:
			var pos : Transform2D = %ArcanaCardsMarginContainer.get_global_transform_with_canvas()
			%ArcanaCardsMarginContainer.top_level = true
			%ArcanaCardsMarginContainer.global_position = pos.origin
		Tutorial.Topic.DoEvilDeeds:
			%DoEvilDeedsButton.disabled = false
			%DoEvilDeedsButton.get_material().set_shader_parameter("active", true)
		Tutorial.Topic.DoEvilDeedsResult:
			var pos : Transform2D = %RankTrackMarginContainer.get_global_transform_with_canvas()
			%RankTrackMarginContainer.top_level = true
			%RankTrackMarginContainer.global_position = pos.origin
			%DoEvilDeedsButton.global_position = pos.origin
		Tutorial.Topic.MarchAction:
			%MarchButton.disabled = false
			%MarchButton.get_material().set_shader_parameter("active", true)
		Tutorial.Topic.March:
			%MarchButton.disabled = false
			%MarchButton.get_material().set_shader_parameter("active", true)


func _on_tutorialRead():
	return
	%RankTrackMarginContainer.z_index = 0
	%PlayersTree.z_index = 0
	
	if %PlayersTree.top_level:
		%PlayersTree.top_level = false
		%PlayersTree.visible = false
		%PlayersTree.visible = true
	
	if %ArcanaCardsMarginContainer.top_level:
		%ArcanaCardsMarginContainer.top_level = false
		%ArcanaCardsMarginContainer.visible = false
		%ArcanaCardsMarginContainer.visible = true
	if %RankTrackMarginContainer.top_level:
		%RankTrackMarginContainer.top_level = false
		%RankTrackMarginContainer.visible = false
		%RankTrackMarginContainer.visible = true
	if %DemonDetailsControl.top_level:
		%DemonDetailsControl.top_level = false
		%DemonDetailsControl.visible = false
		%DemonDetailsControl.visible = true
		%DemonDetailsControl.visible = false
	if %PassButton.top_level:
		%PassButton.top_level = false
		%PassButton.visible = false
		%PassButton.visible = true
		%PassButton.visible = false
	if %WalkTheEarthButton.top_level:
		%WalkTheEarthButton.top_level = false
		%WalkTheEarthButton.visible = false
		%WalkTheEarthButton.visible = true
	if %DoEvilDeedsButton.top_level:
		%DoEvilDeedsButton.top_level = false
		%DoEvilDeedsButton.visible = false
		%DoEvilDeedsButton.visible = true
	if %MarchButton.top_level:
		%MarchButton.top_level = false
		%MarchButton.visible = false
		%MarchButton.visible = true
	if %NextDemonContainer.top_level:
		%NextDemonContainer.top_level = false
		%NextDemonContainer.visible = false
		%NextDemonContainer.visible = true
		%NextDemonContainer.visible = false

func _on_updateRankTrack(arr : Array):
	if arr.is_empty():
		updateRankTrack()
	else:
		rankTrack = arr


func _on_toggleEndPhaseButton(boolean : bool):
	if boolean:
		%EndPhaseButton.disabled = false
	else:
		%EndPhaseButton.disabled = true


func pickLegions(possibleLegionsToMoveWithLieutenant, unitsAlreadyMovingWithLieutenant : Array, capacity):
	var scene = pickLegionsScene.instantiate()
	scene.capacity = capacity
	scene.possibelLegions = possibleLegionsToMoveWithLieutenant
	scene.unitsAlreadyMovingWithLieutenant = unitsAlreadyMovingWithLieutenant
	$Control.add_child(scene)
	var legions = await scene.done
	Signals.pickedLegions.emit(legions)


func showMessage(message : String):
	%WaitForPlayerLabel.text = message
	%WaitForPlayerControl.show()


func hideMessage():
	%WaitForPlayerControl.hide()


func _on_playerDoneWithPhase():
	done.rpc_id(Connection.host)


@rpc("any_peer", "call_local")
func done():
	Signals.tutorialRead.emit()
	Signals.phaseDone.emit()


@rpc("any_peer", "call_local")
func confirmStartDemon():
	if not Settings.debug:
		%GoalMarginContainer.show()
	%DemonCardsMarginContainer.expandDemonCards(false)
	Signals.help.emit(Data.HelpSubjects.SwapDemonOnStart)


@rpc("any_peer", "call_local")
func nextDemon(nextDemon : int):
	Signals.help.emit(Data.HelpSubjects.ActionPhase)
	AudioSignals.playerTurn.emit()
	var demonNode = Data.demons[nextDemon]
	demonNode.skullsUsed = 0
	currentPlayerLabel.text = str(demonNode.stats.player)
	print("action for demon")
	var actionMenuScene = actionMenu.instantiate()
	%SideMenuVBoxContainer.add_child(actionMenuScene)
	actionMenuScene.currentDemonRank = demonNode.stats.rank
	Data.currentDemon = demonNode
	print(demonNode.stats.rank)
	var action = await Signals.demonDone
	
	# do this or _on_march wont come out of the loop
	Data.currentDemon.skullsUsed = Data.currentDemon.skulls 
	
	for troopName in Data.player.troops:
		Data.troops[troopName].sectiosMoved = 0
	#actionMenuScene.toggleActionMenu(false)
	actionMenuScene.queue_free()
	demonActionDone.rpc_id(Connection.host, action)
	AudioSignals.playerTurnDone.emit()


@rpc("any_peer", "call_local")
func updateRankTrackCurrentDemon(nextDemon : int):
	%RankTrack.highlightCurrentDemon(nextDemon)
	highlightCurrentDemon(nextDemon)


@rpc("any_peer", "call_local")
func updateRankTrackCurrentPlayer(playerId : int):
	if playerId == 0:
		%RankTrack.highlightCurrentPlayer(null)
		highlightCurrentPlayer(null)
	else:
		var player : Player = Data.players[playerId]
		%RankTrack.highlightCurrentPlayer(player)
		highlightCurrentPlayer(player)
		

@rpc("any_peer", "call_local")
func demonActionDone(action):
	if Tutorial.tutorial:
		if Tutorial.currentTopic == Tutorial.Topic.Pass:
			Signals.tutorialRead.emit()
	Signals.demonDoneWithPhase.emit(action)


func _on_fleeDialog(sectioName : String, fleeFromCombat : bool):
	var sectio = Decks.sectioNodes[sectioName]
	Signals.moveCamera.emit(sectio.global_position)
	if fleeFromCombat:
		%FleeLabel.text = "Are you sure you want to flee from " + sectioName + "?"
	else:
		%FleeLabel.text = "Enemy Legions are entering the Sectio " + sectioName
	%FleeControl.show()

func showFleeControl():
	%FleeControl.show()

func hideFleeControl():
	%FleeControl.hide()

func _on_end_phase_button_pressed():
	Signals.summoningDone.emit()
	done.rpc_id(Connection.host)
	AudioSignals.playerTurnDone.emit()


func _input(event):
	if event is InputEventKey:
		if event.physical_keycode == KEY_ENTER:
			if Data.phase == Data.phases.Summoning:
				if %WaitForPlayerControl.visible == false:
					done.rpc_id(Connection.host)


func _unhandled_input(event):
	if Input.is_action_just_pressed("menu"):
		Signals.menu.emit()


func _on_menu():
	if not Settings.menuOpen:
		var menuNode = menuContainer.instantiate()
		add_child(menuNode)


func _on_forceFleeDialog():
	return
	%ForceFleeDialog.popup()


var currentSectio = ""
func showSectioPreview(sectio):
	currentSectio = sectio.sectioName
	%SectioTextureRect.texture = sectio.sectioTexture
	%CirclePreviewLabel.text = sectio.circleNames[sectio.circle]
	for child in %YourUnitsPreviewHBoxContainer.get_children():
		child.queue_free()
	for child in %EnemyPreviewUnitsHBoxContainer.get_children():
		child.queue_free()
	%NamePreviewLabel.text = sectio.sectioName
	if sectio.sectioName == "The Wise Men":
		%SoulsPreviewLabel1.hide()
		%SoulsPreviewLabel2.text = "1 - 6 Arcana Cards per Turn"
	else:
		%SoulsPreviewLabel1.show()
		%SoulsPreviewLabel2.text = str(sectio.souls)
	%SectioPreviewMarginContainer.show()
	var troopsDict = {}
	for troopName in sectio.troops:
		if Data.troops.has(troopName):
			var troop = Data.troops[troopName]
			if troopsDict.has(troop.triumphirate):
				troopsDict[troop.triumphirate].append(troop)
			else:
				troopsDict[troop.triumphirate] = [troop]
	for triumphirate in troopsDict:
		var units = troopsDict[triumphirate]
		for unit in units:
			if triumphirate == Data.id:
				var scene = PickMoveUnitVBoxContainerScene.instantiate()
				%YourUnitsPreviewHBoxContainer.add_child(scene)
				scene.populate(unit)
			else:
				var scene = PickMoveUnitVBoxContainerScene.instantiate()
				%EnemyPreviewUnitsHBoxContainer.add_child(scene)
				scene.populate(unit)


func hideSectioPreview(sectioName):
	if sectioName == currentSectio:
		%SectioPreviewMarginContainer.hide()


func _on_wait_for_player_button_pressed():
	%WaitForPlayerControl.hide()
	Signals.proceed.emit()


func _on_pickUnit(sectio):
	var pickUnitControlScene = pickUnitControl.instantiate()
	pickUnitControlScene.highlight(sectio)
	add_child(pickUnitControlScene)


func pickUnitToMove(sectio):
	var pickUnitControlScene = pickUnitControl.instantiate()
	pickUnitControlScene.highlight(sectio)
	add_child(pickUnitControlScene)


func toogleBuyLieutenant(boolean : bool):
	if boolean:
		%AvailableLieutenantsMenu.show()
		Signals.toggleAvailableLieutenantsCheckButtonPressed.emit(true)
	else:
		%AvailableLieutenantsMenu.hide()
		Signals.toggleAvailableLieutenantsCheckButtonPressed.emit(false)


func addArcanaCard(id, cardName):
	var arcana = arcanaScene.instantiate()
	arcana.loadStats(cardName)
	Data.arcanaCardNodes[cardName] = arcana
	arcana.player = id
	%ArcanaHBoxContainer.add_child(arcana)


func fillPickArcanaCardsContainer(cardNames : Array):
	for cardName in cardNames:
		var arcana = arcanaScene.instantiate()
		arcana.loadStats(cardName)
		%PickArcanaHBoxContainer.add_child(arcana)
		arcana.disable()
		arcana.mode = "pick"
	%PickArcanaCardContainer.show()


func _on_showPickArcanaCardContainer():
	%PickArcanaCardContainer.show()


func _on_hidePickArcanaCardContainer(cardName):
	for child in %PickArcanaHBoxContainer.get_children():
		if not child.cardName == cardName:
			Data.returnArcanaCard.rpc_id(Connection.host, child.cardName, Data.id)
		child.queue_free()
	%PickArcanaCardContainer.hide()


func removeDemon(demonRank):
	%DemonCardsMarginContainer.removeDemon(demonRank)


func _on_host_button_pressed():
	Signals.host.emit()


func _on_join_button_pressed():
	Signals.join.emit()


func _on_start_button_pressed():
	Signals.start.emit()


func updateRankTrack():
	%RankTrack.rankTrack = %RankTrack.rankTrack

func _on_toggleDiscardArcanaCardControl(boolean : bool):
	if boolean:
		%DiscardArcanaCardControl.show()
	else:
		%DiscardArcanaCardControl.hide()


func changePlayerName(playerName):
	pass


func toogleWaitForPlayer(playerId, boolean : bool, phase = null):
	if Settings.skipWaitForPlayers:
		return
	if boolean:
		if playerId == Data.id:
			%WaitForPlayerControl.hide()
		else:
			if phase == null:
				if playerId == 0:
					%WaitForPlayerLabel.text = "Waiting for all players to examine their triumphirate."
				elif playerId == 66:
					%WaitForPlayerLabel.text = "Waiting for all players to be ready."
				else:
					%WaitForPlayerLabel.text = "Waiting for player " + str(Data.players[playerId].playerName) + " to place their legion."
			if phase == Data.phases.Summoning:
				%WaitForPlayerLabel.text = "Waiting for player " + str(Data.players[playerId].playerName) + " to finish summoning."
			if phase == Data.phases.Action:
				%WaitForPlayerLabel.text = "Waiting for player " + str(Data.players[playerId].playerName) + " to use its demon."
			%WaitForPlayerControl.modulate.a = 1.0
			%WaitForPlayerControl.show()
			var tw1 = get_tree().create_tween()
			tw1.set_trans(Tween.TRANS_QUAD)
			tw1.set_ease(Tween.EASE_IN)
			tw1.tween_property(%WaitForPlayerControl, "modulate", Color(1,1,1,0), 3.0)#.set_delay(0.5)
			tw1.tween_callback(hideWaitForPlayerControl)
	else:
		%WaitForPlayerControl.hide()


func hideWaitForPlayerControl():
	%WaitForPlayerControl.hide()
	%WaitForPlayerControl.modulate.a = 1.0


func _on_toggleRecruitLegionsButtonEnabled(boolean : bool):
	Signals.toggleRecruitLegionsButton.emit(boolean)


func _on_toogleSummoningMenu(boolean : bool):
	if boolean:
		if not is_instance_valid(summoningMenuScene):
			summoningMenuScene = summoningMenu.instantiate()
			%SideMenuVBoxContainer.add_child(summoningMenuScene)
	else:
		if is_instance_valid(summoningMenuScene):
			summoningMenuScene.queue_free()


func _on_showArcanaCardsContainer():
	return
	%ArcanaCardsMarginContainer.show()


func _on_hideArcanaCardsContainer():
	%ArcanaCardsMarginContainer.hide()


func _on_showRankTrackMarginContainer():
	%RankTrackMarginContainer.show()


func _on_updateTurnTrack(turn : int):
	%TurnLabel.text = str(turn)


func _on_toggleAvailableLieutenants(toggled_on):
	if toggled_on:
		%AvailableLieutenantsMenu.canPlayerAffordLieutenants()
		%AvailableLieutenantsMenu.show()
		Signals.toggleAvailableLieutenantsCheckButtonPressed.emit(true)
	else:
		%AvailableLieutenantsMenu.hide()
		Signals.toggleAvailableLieutenantsCheckButtonPressed.emit(false)


func _on_showChosenLieutenantFromAvailableLieutenantsBox(marginContainer : MarginContainer):
	add_child(marginContainer)
