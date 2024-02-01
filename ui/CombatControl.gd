extends Control

#signal pickedDemon(demonNode)

func toggleActionMenu(boolean):
	if boolean:
		for demonRank in Data.player.demons:
			var demonNode = Data.demons[demonRank].duplicate()
#			demonNode.demonName = str(demonName)
			if demonNode.incapacitated:
				continue
			if demonNode.onEarth:
				continue
			%PickDemonHBoxContainer.add_child(demonNode)
			demonNode.demonClicked.connect(_on_demonPicked)
#		for demonName in Data.player.demons:
#			var demon = Data.demons[demonName].duplicate()
#			demon.demonName = str(demonName)
#			if demon.incapacitated:
#				continue
#			if demon.onEarth:
#				continue
#			%PickDemonHBoxContainer.add_child(demon)
#			demon.scale = Vector2(0.6, 0.6)
#			demon.demonClicked.connect(_on_demonPicked)
		%PickDemonControl.show()
	else:
		%PickDemonControl.hide()


func _on_demonPicked(demonNode):
	print("picked demon ", demonNode.demonName)
	Signals.pickedDemon.emit(demonNode)
	%PickDemonControl.hide()

#fleeingConfirmed = await fleeConfirmation
#%EventDialog.dialog_hide_on_ok = true
