extends HBoxContainer

signal reply(boolean)
var sectioName = ""

func populate(_sectioName : String, souls : String):
	sectioName = _sectioName
	%SoulsLabel.text = souls
	$Label.text = sectioName

func highlight(boolean):
	if boolean:
		$ApprovetButton.disabled = false
		$DenyButton.disabled = false
	else:
		$ApprovetButton.disabled = true
		$DenyButton.disabled = true

func _on_deny_button_pressed():
	reply.emit(sectioName, false)


func _on_approvet_button_pressed():
	reply.emit(sectioName, true)


func _on_mouse_entered():
	Signals.showSectioPreview.emit(Decks.sectioNodes[sectioName])
	Signals.moveCamera.emit(Decks.sectioNodes[sectioName].global_position)
#	if ui:
#		ui.highlightSectioPreview(Decks.sectioNodes[sectioName])
#		camera.moveTo(Decks.sectioNodes[sectioName].global_position)
	Decks.sectioNodes[sectioName].highlight(true)


func _on_mouse_exited():
	Signals.hideSectioPreview.emit(sectioName)
#	if ui:
#		ui.hideSectioPreview(sectioName)
	Decks.sectioNodes[sectioName].highlight(false)
