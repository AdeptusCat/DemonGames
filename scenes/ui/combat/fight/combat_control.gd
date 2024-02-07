extends Control


func _ready():
	Signals.showCombat.connect(_on_showCombat)
	Signals.hideCombat.connect(_on_hideCombat)


func _on_showCombat():
	if %CombatParticipantsControl.playerIsFighting:
		%FleeButton.show()
		%FleeButton.disabled = false
	%CombatParticipantsControl.show()
	show()


func _on_hideCombat():
	%CombatParticipantsControl.hide()
	hide()


func toggleActionMenu(boolean):
	if boolean:
		for demonRank in Data.player.demons:
			var demonNode = Data.demons[demonRank].duplicate()
			if demonNode.incapacitated:
				continue
			if demonNode.onEarth:
				continue
			%PickDemonHBoxContainer.add_child(demonNode)
			demonNode.demonClicked.connect(_on_demonPicked)
		%PickDemonControl.show()
		show()
	else:
		%PickDemonControl.hide()
		hide()


func _on_demonPicked(demonNode):
	Signals.pickedDemon.emit(demonNode)
	%PickDemonControl.hide()
