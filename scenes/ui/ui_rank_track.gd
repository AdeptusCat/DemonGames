extends MarginContainer

@export var playerIcon : Texture

var tw1 : Tween

var root
var currentDemonRoot
var currentDemonEntries : Dictionary = {}
var entries : Dictionary = {}
var mouseEntered : bool = false
var demonActions : Dictionary = {}

var iconColorVisible : Color = Color8(200,200,200,255)
var iconColorInvisible : Color = Color8(200,200,200,0)


var rankTrack: Array:
	set(array):
		print(Data.id, " updating rank track")
		rankTrack = array
		var firstEntry : bool = entries.is_empty()
		for entry in entries:
			entries[entry].free()
		for rank in rankTrack:
			_on_addLine(rank)
		if firstEntry:
			%Label.text = "Demon Rank Track"
			expand()
			await get_tree().create_timer(5).timeout
			if not mouseEntered:
				collapse()
		
func _ready():
	Signals.demonClicked.connect(_on_demonClicked)
	Signals.action.connect(_on_action)
	
	currentDemonRoot = %CurrentDemonTree.create_item()
	%CurrentDemonTree.set_column_title(0, "")
	%CurrentDemonTree.set_column_title(1, "Demon")
	%CurrentDemonTree.set_column_title(2, "Status")
	%CurrentDemonTree.set_column_title(3, "Action")
	%CurrentDemonTree.set_column_expand_ratio(0, 1)
	%CurrentDemonTree.set_column_expand_ratio(1, 3)
	%CurrentDemonTree.set_column_expand_ratio(2, 1)
	%CurrentDemonTree.set_column_expand_ratio(3, 2)
	
	root = %DemonTree.create_item()
	%DemonTree.set_column_title(0, "")
	%DemonTree.set_column_title(1, "Demon")
	%DemonTree.set_column_title(2, "Status")
	%DemonTree.set_column_title(3, "Action")
	%DemonTree.set_column_expand_ratio(0, 1)
	%DemonTree.set_column_expand_ratio(1, 3)
	%DemonTree.set_column_expand_ratio(2, 1)
	%DemonTree.set_column_expand_ratio(3, 2)


func _on_action(demonRank : int, action : String):
	if demonRank == 0:
		if currentDemonEntries.size() > 0:
			for rank in demonActions:
				demonActions[rank] = ""
			for entry in currentDemonEntries:
				currentDemonEntries[entry].set_text(3, "")
			for entry in entries:
				if entries[entry]:
					entries[entry].set_text(3, "")
	else:
		demonActions[demonRank] = action
		if currentDemonEntries.has(demonRank):
				if is_instance_valid(currentDemonEntries[demonRank]):
					currentDemonEntries[demonRank].set_text(3, action)
		entries[demonRank].set_text(3, action)


func highlightCurrentPlayer(player : Player = null):
	Signals.showRankTrackMarginContainer.emit()
	for entryD in currentDemonEntries:
		if currentDemonEntries.has(entryD):
			if is_instance_valid(currentDemonEntries[entryD]):
				currentDemonEntries[entryD].free()
				currentDemonEntries.erase(entryD)
	if not player:
		%CurrentDemonTree.hide()
		%CurrentActionLabel.hide()
		return
	%CurrentDemonTree.show()
	%CurrentActionLabel.show()
	%CurrentDemonTree.set_column_title(0, "")
	%CurrentDemonTree.set_column_title(1, "Player")
	%CurrentDemonTree.set_column_title(2, "Phase")
	%CurrentDemonTree.set_column_title(3, "")
	%CurrentActionLabel.text = "Current Player"
	var line = %CurrentDemonTree.create_item(currentDemonRoot)
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
	%CurrentDemonTree.show()
	%CurrentActionLabel.show()
	%CurrentDemonTree.set_column_title(0, "")
	%CurrentDemonTree.set_column_title(1, "Demon")
	%CurrentDemonTree.set_column_title(2, "Status")
	%CurrentDemonTree.set_column_title(3, "Action")
	%CurrentActionLabel.text = "Current Demon"
	for entry in entries:
		if entry == rank:
			entries[entry].set_icon_modulate(0, iconColorVisible)
			for entryD in currentDemonEntries:
				if currentDemonEntries.has(entryD):
					if is_instance_valid(currentDemonEntries[entryD]):
						currentDemonEntries[entryD].free()
						currentDemonEntries.erase(entryD)
			_on_addCurrentDemonLine(rank)
		else:
			entries[entry].set_icon_modulate(0, iconColorInvisible)


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
	var line = %CurrentDemonTree.create_item(currentDemonRoot)
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


func _on_demonLabel_mouseEntered(demonName):
	pass
#	var demonRank = demonRanksByName[demonName]
#	var demonNode = Data.demons[demonRank].duplicate()
#	%DemonDetailsMarginContainer.add_child(demonNode)


func _on_demonLabel_mouseExited():
	%DemonDetailsControl.hide()
	for child in %DemonDetailsMarginContainer.get_children():
		child.queue_free()


func _on_addLine(demonRank):
	if not Data.demons.has(demonRank):
		return
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
	var line = %DemonTree.create_item(root)
	line.set_icon(0, playerIcon)
	line.set_icon_modulate(0, iconColorInvisible)
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
	entries[demonRank] = line


func _on_changeValue(demonRank, column, value):
	var line = entries[demonRank]
	match column:
		"name":
			line.set_text(0, str(value))
		"status":
			line.set_text(1, str(value))


func _on_demon_tree_item_selected():
	var item : TreeItem = %DemonTree.get_next_selected(root)
	for column in %DemonTree.columns:
		if item.is_selected(column):
			match column:
				1:
					for node in %DemonDetailsMarginContainer.get_children():
						node.queue_free()
					
					var demonRank : int = item.get_metadata(1)
					var demonNode : Demon = Data.demons[demonRank].duplicate()
					
					%DemonDetailsMarginContainer.add_child(demonNode)
					%DemonDetailsControl.show()
					
					if Tutorial.tutorial:
						Signals.tutorialRead.emit()


func _on_demonClicked(demon : Demon):
	%DemonDetailsControl.hide()
	for node in %DemonDetailsMarginContainer.get_children():
		node.queue_free()


func expand():
	var y : int = clamp(rankTrack.size() * 48 + 48, 0, 12 * 48 + 48)
	var tw1 = create_tween()
	tw1.set_trans(Tween.TRANS_QUAD)
	tw1.set_ease(Tween.EASE_IN)
	tw1.tween_property(%DemonTree, "custom_minimum_size", Vector2(350, y), 0.3)


func _on_mouse_entered():
	mouseEntered = true
	expand()

func collapse():
	var tw1 = create_tween()
	tw1.set_trans(Tween.TRANS_QUAD)
	tw1.set_ease(Tween.EASE_IN)
	tw1.tween_property(%DemonTree, "custom_minimum_size", Vector2(350, 0), 0.3)


func _process(delta):
	if mouseEntered:
		if get_global_mouse_position().x < global_position.x or get_global_mouse_position().y < global_position.y:
			mouseEntered = false
			collapse()
	#if get_global_mouse_position().y > mouseEnteredPositiony + 10:
		##return
##			position -= Vector2(0, 650)
		#hovering = false
		#tw1 = create_tween()
		#tw1.set_trans(Tween.TRANS_QUAD)
		#tw1.set_ease(Tween.EASE_IN_OUT)
		#tw1.parallel().tween_property(self, "position", startPosition - Vector2(0, 550), 0.2)
	#print("exited rank track")
	#mouseEntered = false
	#collapse()


func _on_mouse_exited():
	return
	#print(get_global_mouse_position(), global_position)
	#if get_global_mouse_position().x < global_position.x or get_global_mouse_position().y < global_position.y:
		#print("exited rank track")
		#mouseEntered = false
		#collapse()

func _on_current_demon_tree_item_selected():
	var item : TreeItem = %CurrentDemonTree.get_next_selected(root)
	if not item:
		return
	for column in %CurrentDemonTree.columns:
		if item.is_selected(column):
			match column:
				1:
					var demonRank : int = item.get_metadata(1)
					if Data.demons.has(demonRank):
						for node in %DemonDetailsMarginContainer.get_children():
							node.queue_free()
						var demonNode : Demon = Data.demons[demonRank].duplicate()
						%DemonDetailsMarginContainer.add_child(demonNode)
						%DemonDetailsControl.show()
