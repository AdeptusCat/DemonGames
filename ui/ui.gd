extends CanvasLayer
class_name UI

const PickMoveUnitVBoxContainerScene = preload("res://pick_move_unit_v_box_container.tscn")
const menuContainer = preload("res://ui/menu_container.tscn")
const pickLegionsScene = preload("res://pick_legions.tscn")
const arcanaScene = preload("res://arcana.tscn")
var playerIcon = preload("res://assets/icons/pentagram_white.png")

@onready var currentPlayerLabel = %CurrentPlayerLabel
@onready var actionsNode = %Actions
@onready var fleeControl = %FleeControl
@onready var waitForPlayerControl = %WaitForPlayerControl
@onready var waitForPlayerLabel = %WaitForPlayerLabel
@onready var combatParticipantsControl = %CombatParticipantsControl

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
	Signals.showSectioPreview.connect(showSectioPreview)
	Signals.hideSectioPreview.connect(hideSectioPreview)
	Signals.showFleeControl.connect(showFleeControl)
	Signals.hideFleeControl.connect(hideFleeControl)
	Signals.showMessage.connect(showMessage)
	Signals.hideMessage.connect(hideMessage)
	Signals.pickLegions.connect(pickLegions)
	Signals.toggleEndPhaseButton.connect(_on_toggleEndPhaseButton)
	Signals.toogleSummoningMenu.connect(_on_toogleSummoningMenu)
	Signals.toogleBuyLieutenant.connect(toogleBuyLieutenant)
	Signals.spinLieutenantBox.connect(_on_spinLieutenantBox)
	Signals.toggleDiscardArcanaCardControl.connect(_on_toggleDiscardArcanaCardControl)
	Signals.hidePickArcanaCardContainer.connect(_on_hidePickArcanaCardContainer)
	Signals.fleeDialog.connect(_on_fleeDialog)
	Signals.forceFleeDialog.connect(_on_forceFleeDialog)
	Signals.pickUnit.connect(_on_pickUnit)
	Signals.toggleRecruitLegionsButtonEnabled.connect(_on_toggleRecruitLegionsButtonEnabled)
	Signals.toggleBuyArcanaCardButtonEnabled.connect(_on_toggleBuyArcanaCardButtonEnabled)
	Signals.menu.connect(_on_menu)
	Signals.toogleWaitForPlayer.connect(toogleWaitForPlayer)
	Signals.addArcanaCardToUi.connect(addArcanaCard)
	Signals.updateRankTrack.connect(_on_updateRankTrack)
	Signals.addLieutenantToAvailableLieutenantsBox.connect(addLieutenantToAvailableLieutenantsBox)
	Signals.fillPickArcanaCardsContainer.connect(fillPickArcanaCardsContainer)
	Signals.removeDemon.connect(removeDemon)
	Signals.changePlayerName.connect(changePlayerName)
	
	Signals.showArcanaCardsContainer.connect(_on_showArcanaCardsContainer)
	Signals.hideArcanaCardsContainer.connect(_on_hideArcanaCardsContainer)
	Signals.showRankTrackMarginContainer.connect(_on_showRankTrackMarginContainer)
	Signals.showChosenLieutenantFromAvailableLieutenantsBox.connect(showChosenLieutenantFromAvailableLieutenantsBox)

	Signals.updateTurnTrack.connect(_on_updateTurnTrack)
	
	Signals.tutorial.connect(_on_tutorial)
	Signals.tutorialRead.connect(_on_tutorialRead)
	
	Signals.removeLieutenantFromAvailableLieutenantsBox.connect(_on_removeLieutenantFromAvailableLieutenantsBox)
	
	Server.playerLeft.connect(_on_playerLeft)
	
	Signals.action.connect(_on_action)
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
			currentDemonEntries[0].set_text(3, "")
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
		%PlayerDisconnectedMarginContainer.show()
		%PlayerDisconnectedLabel.text = "Player " + Data.players[playerId].playerName + " left the Game. \nNote that this Game saves after every Phase. \n You can create a new Room in the Lobby and load the Savegame."


func _on_removeLieutenantFromAvailableLieutenantsBox(lieutenantName : String):
	Decks.availableLieutenants.erase(lieutenantName)
	removeLieutenantFromAvailableLieutenantsBox(lieutenantName)


func disableActionButtons():
	# Summoning Actions
	%RecruitLegionsButton.disabled = true
	%RecruitLegionsButton.get_material().set_shader_parameter("active", false)
	
	%BuyArcanaCardButton.disabled = true
	%BuyArcanaCardButton.get_material().set_shader_parameter("active", false)
	
	%EndPhaseButton.disabled = true
	%EndPhaseButton.get_material().set_shader_parameter("active", false)
	
	# Demon Actions
	%MarchButton.disabled = true
	%MarchButton.get_material().set_shader_parameter("active", false)
	
	%WalkTheEarthButton.disabled = true
	%WalkTheEarthButton.get_material().set_shader_parameter("active", false)
	
	%PassButton.disabled = true
	%PassButton.get_material().set_shader_parameter("active", false)
	
	%PassForGoodButton.disabled = true
	%PassForGoodButton.get_material().set_shader_parameter("active", false)
	
	%DoEvilDeedsButton.disabled = true
	%DoEvilDeedsButton.get_material().set_shader_parameter("active", false)
	
	%ConspireButton.disabled = true
	%ConspireButton.get_material().set_shader_parameter("active", false)
	
	%InfluenceUnitsButton.disabled = true
	%InfluenceUnitsButton.get_material().set_shader_parameter("active", false)
	
	%AtonementAndSuplicationButton.disabled = true
	%AtonementAndSuplicationButton.get_material().set_shader_parameter("active", false)
	
	%UseMagicButton.disabled = true
	%UseMagicButton.get_material().set_shader_parameter("active", false)


func _on_tutorial(topic, text : String):
	disableActionButtons()
	match topic:
		Tutorial.Topic.PlayersTree:
			var pos : Transform2D = %PlayersTree.get_global_transform_with_canvas()
			%PlayersTree.top_level = true
			%PlayersTree.global_position = pos.origin
		
		Tutorial.Topic.NextDemon:
			var pos : Transform2D = %NextDemonContainer.get_global_transform_with_canvas()
			%NextDemonContainer.top_level = true
			%NextDemonContainer.global_position = pos.origin
		Tutorial.Topic.Phase:
			%PhaseMarginContainer.z_index = 1
		Tutorial.Topic.CurrentPlayer:
			%RankTrackMarginContainer.z_index = 1
		Tutorial.Topic.PlayerStatus:
			%PlayersTree.z_index = 1
		Tutorial.Topic.RecruitLegion:
			%RecruitLegionsButton.disabled = false
			%RecruitLegionsButton.get_material().set_shader_parameter("active", true)
		Tutorial.Topic.PlaceLegion:
			%BuyArcanaCardButton.disabled = true
			%EndPhaseButton.disabled = true
		Tutorial.Topic.RecruitLieutenantAttempt:
			var pos : Transform2D = %ArcanaCardsMarginContainer.get_global_transform_with_canvas()
			%ArcanaCardsMarginContainer.top_level = true
			%ArcanaCardsMarginContainer.global_position = pos.origin
		Tutorial.Topic.BuyArcanaCard:
			%BuyArcanaCardButton.disabled = false
			%BuyArcanaCardButton.get_material().set_shader_parameter("active", true)
		Tutorial.Topic.PickArcanaCard:
			var pos : Transform2D = %PickArcanaCardContainer.get_global_transform_with_canvas()
			%PickArcanaCardContainer.top_level = true
			%PickArcanaCardContainer.global_position = pos.origin
		Tutorial.Topic.RecruitLieutenantCard:
			var pos : Transform2D = %ArcanaCardsMarginContainer.get_global_transform_with_canvas()
			%ArcanaCardsMarginContainer.top_level = true
			%ArcanaCardsMarginContainer.global_position = pos.origin
		Tutorial.Topic.EndSummoningPhase:
			%EndPhaseButton.disabled = false
			%EndPhaseButton.get_material().set_shader_parameter("active", true)
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
	%PhaseMarginContainer.z_index = 0
	%RankTrackMarginContainer.z_index = 0
	%PlayersTree.z_index = 0
	%BuyArcanaCardButton.disabled = false
	%EndPhaseButton.disabled = false
	
	if %PlayersTree.top_level:
		%PlayersTree.top_level = false
		%PlayersTree.visible = false
		%PlayersTree.visible = true
	
	if %BuyArcanaCardButton.top_level:
		%BuyArcanaCardButton.top_level = false
		%BuyArcanaCardButton.visible = false
		%BuyArcanaCardButton.visible = true
	if %ArcanaCardsMarginContainer.top_level:
		%ArcanaCardsMarginContainer.top_level = false
		%ArcanaCardsMarginContainer.visible = false
		%ArcanaCardsMarginContainer.visible = true
	if %EndPhaseButton.top_level:
		%EndPhaseButton.top_level = false
		%EndPhaseButton.visible = false
		%EndPhaseButton.visible = true
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
	actionsNode.currentDemonRank = demonNode.stats.rank
	Data.currentDemon = demonNode
	print(demonNode.stats.rank)
	var action = await Signals.demonDone
	
	# do this or _on_march wont come out of the loop
	Data.currentDemon.skullsUsed = Data.currentDemon.skulls 
	
	for troopName in Data.player.troops:
		Data.troops[troopName].sectiosMoved = 0
	actionsNode.toggleActionMenu(false)
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
	%PickMoveUnitControl.highlight(sectio)


func pickUnitToMove(sectio):
	%PickMoveUnitControl.highlight(sectio)


func toogleBuyLieutenant(boolean : bool):
	if boolean:
		%AvailableLieutenantsMarginContainer.show()
		%AvailableLieutenantsCheckButton.button_pressed = true
	else:
		%AvailableLieutenantsMarginContainer.hide()
		%AvailableLieutenantsCheckButton.button_pressed = false


func addLieutenantToAvailableLieutenantsBox(lieutenantName):
	var lieutenant = Decks.lieutenantsReference[lieutenantName]
	var lieutenantMarginContainerScene = load("res://ui/lieutenant_margin_container.tscn")
	var lieutenantMarginContainer = lieutenantMarginContainerScene.instantiate()
	lieutenantMarginContainer.populate(lieutenantName, lieutenant.texture, str(lieutenant["combat bonus"]), str(lieutenant.capacity))
	%AvailableLieutenantsHBoxContainer.add_child(lieutenantMarginContainer)

var startTime = Time.get_ticks_msec()
var lieutenantMarginContainers : Array = []
var activeLieutenantMarginContainer
var intervalDefault : float = 0.1
var interval : float = intervalDefault
var startSpin : bool = false
var spinCounter : int = 0
var goalLieutenantMarginContainer


func _on_spinLieutenantBox(lieutenantPicked : String):
	lieutenantMarginContainers = %AvailableLieutenantsHBoxContainer.get_children()
	for lieutenantMarginContainer in lieutenantMarginContainers:
		if lieutenantMarginContainer.lieutenantName == lieutenantPicked:
			goalLieutenantMarginContainer = lieutenantMarginContainer
	startArrowSpin()

func startArrowSpin():
	toogleBuyLieutenant(true)
	startSpin = true
	startTime = Time.get_ticks_msec()
	spinCounter = 0
	interval = intervalDefault

func stopSpin():
	startSpin = false
	await get_tree().create_timer(1.0).timeout
	Signals.spinLieutenantBoxStopped.emit()
	toogleBuyLieutenant(false)
	

func _process(elta):
	if startSpin:
		if activeLieutenantMarginContainer == null:
			activeLieutenantMarginContainer = lieutenantMarginContainers.pop_front()
			activeLieutenantMarginContainer.toggleTriumphirateIcon(true, Data.id)
			spinCounter += 1
		else:
			if Time.get_ticks_msec() > startTime + interval:
				if spinCounter > 10 and activeLieutenantMarginContainer == goalLieutenantMarginContainer:
					stopSpin()
				else:
					startTime = Time.get_ticks_msec()
					activeLieutenantMarginContainer.toggleTriumphirateIcon(false, Data.id)
					lieutenantMarginContainers.append(activeLieutenantMarginContainer)
					if lieutenantMarginContainers.size() == 0:
						stopSpin()
					else:
						activeLieutenantMarginContainer = null
						interval += pow(interval, 1.01)
			# if it takes too long, skip
			if Time.get_ticks_msec() > startTime + 5000:
					if activeLieutenantMarginContainer:
						activeLieutenantMarginContainer.toggleTriumphirateIcon(false, Data.id)
					goalLieutenantMarginContainer.toggleTriumphirateIcon(true, Data.id)
					stopSpin()


func showChosenLieutenantFromAvailableLieutenantsBox(lieutenantName):
	var marginContainer
	for child in %AvailableLieutenantsHBoxContainer.get_children():
		var unitName = child.getLieutenantName()
		if unitName == lieutenantName:
			child.highlight()
			marginContainer = child
			%AvailableLieutenantsHBoxContainer.remove_child(child)
	add_child(marginContainer)


func removeLieutenantFromAvailableLieutenantsBox(lieutenantName : String):
	for child in %AvailableLieutenantsHBoxContainer.get_children():
		var unitName = child.getLieutenantName()
		if unitName == lieutenantName:
			child.queue_free()


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


func _on_toggleBuyArcanaCardButtonEnabled(boolean : bool):
	if boolean:
		%BuyArcanaCardButton.disabled = false
	else:
		%BuyArcanaCardButton.disabled = true


func removeDemon(demonRank):
	%DemonCardsMarginContainer.removeDemon(demonRank)


func _on_host_button_pressed():
	Signals.host.emit()


func _on_join_button_pressed():
	Signals.join.emit()


func _on_start_button_pressed():
	Signals.start.emit()

func start():
	%NetworkHBoxContainer.hide()

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

func _on_buy_arcana_card_button_pressed():
	Signals.sectioClicked.emit(null)
	Signals.buyArcanaCard.emit()
	Signals.tutorialRead.emit()



func _on_save_button_pressed():
	Save.saveGame()




func _on_recruit_legions_button_pressed():
	Signals.tutorialRead.emit()
	Signals.recruitLegions.emit()


func _on_toggleRecruitLegionsButtonEnabled(boolean : bool):
	if boolean:
		%RecruitLegionsButton.disabled = false
	else:
		%RecruitLegionsButton.disabled = true


func _on_toogleSummoningMenu(boolean : bool):
	if boolean:
		%SummoningMenuContainer.show()
		%PlayerStatusMarginContainer.show()
	else:
		%SummoningMenuContainer.hide()
		%PlayerStatusMarginContainer.hide()





func _on_showArcanaCardsContainer():
	print("show arcana")
	%ArcanaCardsMarginContainer.show()


func _on_hideArcanaCardsContainer():
	print("hide arcana")
	%ArcanaCardsMarginContainer.hide()


func _on_showRankTrackMarginContainer():
	%RankTrackMarginContainer.show()


func _on_updateTurnTrack(turn : int):
	%TurnLabel.text = str(turn)


func _on_player_disconnected_button_pressed():
	%PlayerDisconnectedMarginContainer.hide()


func _on_available_lieutenants_check_button_toggled(toggled_on):
	if toggled_on:
		%AvailableLieutenantsMarginContainer.show()
		%AvailableLieutenantsCheckButton.button_pressed = true
	else:
		%AvailableLieutenantsMarginContainer.hide()
		%AvailableLieutenantsCheckButton.button_pressed = false

