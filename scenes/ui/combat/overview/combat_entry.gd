extends HBoxContainer

const PickMoveUnitVBoxContainerScene = preload("res://scenes/ui/pick_move_unit_v_box_container.tscn")
var sectioName : String = ""

func populate(_sectioName : String, combatRankNr : int):
	sectioName = _sectioName
	$CombatRankNrLabel.text = str(combatRankNr)
	$Label.text = sectioName
	
	for child in %YourUnitsPreviewHBoxContainer.get_children():
		child.queue_free()
	for child in %EnemyPreviewUnitsHBoxContainer.get_children():
		child.queue_free()
		
	var troopsDict = {}
	var sectio : Sectio = Decks.sectioNodes[sectioName]
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
#				%YourUnitsPreviewLabel.show()
				var scene = PickMoveUnitVBoxContainerScene.instantiate()
				%YourUnitsPreviewHBoxContainer.add_child(scene)
				scene.populate(unit)
			else:
#				%EnemyUnitsPreviewLabel.show()
				var scene = PickMoveUnitVBoxContainerScene.instantiate()
				%EnemyPreviewUnitsHBoxContainer.add_child(scene)
				scene.populate(unit)

func _on_mouse_entered():
	Signals.showSectioPreview.emit(Decks.sectioNodes[sectioName])
	Signals.moveCamera.emit(Decks.sectioNodes[sectioName].global_position)
	Decks.sectioNodes[sectioName].highlight(true)


func _on_mouse_exited():
	Signals.hideSectioPreview.emit(sectioName)
	Decks.sectioNodes[sectioName].highlight(false)
