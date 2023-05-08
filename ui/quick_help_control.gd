extends MarginContainer

var expanded : bool = false
var helpSubjectsAlreadyDisplayed : Array = []

func _ready():
	Signals.help.connect(_on_help)

func _on_help(subject):
	var showHelp : bool = false
	match subject:
		Data.HelpSubjects.SwapDemonOnStart:
			%HelpLabel.text = "Examine the Demons. If you are unhappy with one, you can request a new one for the cost of one Favor by clicking on it."
			if not helpSubjectsAlreadyDisplayed.has(Data.HelpSubjects.SwapDemonOnStart):
				helpSubjectsAlreadyDisplayed.append(Data.HelpSubjects.SwapDemonOnStart)
				showHelp = true
		Data.HelpSubjects.PlaceFirstLegion:
			%HelpLabel.text = "Click on a Sectio to place your first Legion. \nMove around the Map with the Arrow Keys or hold Middle Mouse Button."
			if not helpSubjectsAlreadyDisplayed.has(Data.HelpSubjects.PlaceFirstLegion):
				helpSubjectsAlreadyDisplayed.append(Data.HelpSubjects.PlaceFirstLegion)
				showHelp = true
		Data.HelpSubjects.StartScreen:
			%HelpLabel.text = "The Game is about to start. Click on the image in the center of the screen to proceed."
			if not helpSubjectsAlreadyDisplayed.has(Data.HelpSubjects.StartScreen):
				helpSubjectsAlreadyDisplayed.append(Data.HelpSubjects.StartScreen)
				showHelp = true
		Data.HelpSubjects.SummoningPhase:
			%HelpLabel.text = "This is the Summoning Phase: You can recruit Legions, recruit Lieutenants (if you have the right Arcana Card) and buy new Arcana Cards."
			if not helpSubjectsAlreadyDisplayed.has(Data.HelpSubjects.SummoningPhase):
				helpSubjectsAlreadyDisplayed.append(Data.HelpSubjects.SummoningPhase)
				showHelp = true
		Data.HelpSubjects.ActionPhase:
			%HelpLabel.text = "This is the Action Phase: The Demons now take turns performing Actions. \nActions might be: Moving Legions, traveling to the surface of the Earth, or cast Magic (not implemented). \nEach Demon has only one Action per turn."
			if not helpSubjectsAlreadyDisplayed.has(Data.HelpSubjects.ActionPhase):
				helpSubjectsAlreadyDisplayed.append(Data.HelpSubjects.ActionPhase)
				showHelp = true
		Data.HelpSubjects.PickDemonForCombat:
			%HelpLabel.text = "Pick a Demon to help your Units win the Fight. Each Demon can only fight once per Combat Phase."
			if not helpSubjectsAlreadyDisplayed.has(Data.HelpSubjects.PickDemonForCombat):
				helpSubjectsAlreadyDisplayed.append(Data.HelpSubjects.PickDemonForCombat)
				showHelp = true
		Data.HelpSubjects.PetitionPhase:
			%HelpLabel.text = "This is the Petition Phase: Take control on unclaimed Sectios or take over another Players Sectio by paying a Favor."
			if not helpSubjectsAlreadyDisplayed.has(Data.HelpSubjects.PetitionPhase):
				helpSubjectsAlreadyDisplayed.append(Data.HelpSubjects.PetitionPhase)
				showHelp = true
		
		Data.HelpSubjects.March:
			%HelpLabel.text = "To move a Unit from one Sectio to another, click on the sectio containing a Unit and then click on the Sectio adjacent to the Unit. \nMoving a Unit costs a Skull of the current Demon, Legions can move up to two Sectios with one Skull, Lieutenants can move up to three Sectios. \nLieutenants a special, in that they can carry as many other Legions with them as the number indicated on the right of the Lieutenant Card."
			if not helpSubjectsAlreadyDisplayed.has(Data.HelpSubjects.PetitionPhase):
				helpSubjectsAlreadyDisplayed.append(Data.HelpSubjects.PetitionPhase)
				showHelp = true
	if %HelpCheckBox.button_pressed or not Settings.tooltips:
		return
	if showHelp:
		await get_tree().create_timer(0.5).timeout
		expand()


func _on_button_pressed():
	collapse()


func expand():
	var tw1 = create_tween()
	tw1.set_trans(Tween.TRANS_BACK)
	tw1.set_ease(Tween.EASE_OUT)
	tw1.tween_property(self, "position", Vector2(0 - %HelpLabel.size.x - 50, 0), 0.6)


func collapse():
	var tw1 = create_tween()
	tw1.set_trans(Tween.TRANS_BACK)
	tw1.set_ease(Tween.EASE_IN)
	tw1.tween_property(self, "position", Vector2.ZERO, 0.6)


func _on_help_button_pressed():
	if expanded:
		expanded = false
		collapse()
	else:
		expanded = true
		expand()


func _on_sequence_of_play_button_pressed():
	Signals.showSequenceOfPlayHelp.emit()


func _on_help_popup_menu_index_pressed(index):
	Signals.showSequenceOfPlayHelp.emit()
