extends Control


var recruitLegionsButtonActivated : bool = true


func _ready():
	Signals.disableActionMenuButtons.connect(_on_disableActionButtons)
	Signals.toggleRecruitLegionsButton.connect(_on_toggleRecruitLegionsButton)
	Signals.toggleBuyArcanaCardButton.connect(_on_toggleBuyArcanaCardButton)
	Signals.toggleEndPhaseButton.connect(_on_toggleEndPhaseButton)
	Signals.tutorial.connect(_on_tutorial)
	Signals.tutorialRead.connect(_on_tutorialRead)
	Signals.toggleAvailableLieutenantsCheckButtonPressed.connect(_on_toggleAvailableLieutenantsCheckButtonPressed)


func _on_disableActionButtons():
	%RecruitLegionsButton.disabled = true
	%RecruitLegionsButton.get_material().set_shader_parameter("active", false)
	
	%BuyArcanaCardButton.disabled = true
	%BuyArcanaCardButton.get_material().set_shader_parameter("active", false)
	
	%EndPhaseButton.disabled = true
	%EndPhaseButton.get_material().set_shader_parameter("active", false)


func _on_toggleRecruitLegionsButton(boolean : bool):
	%RecruitLegionsButton.disabled != boolean
	recruitLegionsButtonActivated = boolean
	print("recruiting ", recruitLegionsButtonActivated)


func _on_toggleBuyArcanaCardButton(boolean : bool):
	%BuyArcanaCardButton.disabled != boolean


func _on_toggleEndPhaseButton(boolean : bool):
	%EndPhaseButton.disabled != boolean


func _on_toggleAvailableLieutenantsCheckButtonPressed(boolean : bool):
	%AvailableLieutenantsCheckButton.button_pressed = boolean


func _on_tutorial(topic, text : String):
	_on_disableActionButtons()
	match topic:
		Tutorial.Topic.RecruitLegion:
			_on_toggleRecruitLegionsButton(true)
			%RecruitLegionsButton.get_material().set_shader_parameter("active", true)
		Tutorial.Topic.PlaceLegion:
			_on_toggleBuyArcanaCardButton(false)
			_on_toggleEndPhaseButton(false)
		Tutorial.Topic.BuyArcanaCard:
			_on_toggleBuyArcanaCardButton(true)
			%BuyArcanaCardButton.get_material().set_shader_parameter("active", true)
		Tutorial.Topic.EndSummoningPhase:
			_on_toggleEndPhaseButton(true)
			%EndPhaseButton.get_material().set_shader_parameter("active", true)


func _on_tutorialRead():
	%BuyArcanaCardButton.disabled = false
	%EndPhaseButton.disabled = false
	if %BuyArcanaCardButton.top_level:
		%BuyArcanaCardButton.top_level = false
		%BuyArcanaCardButton.visible = false
		%BuyArcanaCardButton.visible = true
	if %EndPhaseButton.top_level:
		%EndPhaseButton.top_level = false
		%EndPhaseButton.visible = false
		%EndPhaseButton.visible = true


func _on_recruit_legions_button_pressed():
	Signals.tutorialRead.emit()
	Signals.recruitLegions.emit()


func _on_buy_arcana_card_button_pressed():
	Signals.sectioClicked.emit(null)
	Signals.buyArcanaCard.emit()
	Signals.tutorialRead.emit()


func _on_end_phase_button_pressed():
	Signals.summoningDone.emit()
	Signals.playerDoneWithPhase.emit()
	AudioSignals.playerTurnDone.emit()


func _on_recruit_legions_h_box_container_gui_input(event):
	if recruitLegionsButtonActivated:
		if Input.is_action_just_pressed("click"):
			print("recruti clo11")
			Signals.tutorialRead.emit()
			Signals.recruitLegions.emit()


func _on_buy_arcana_card_h_box_container_gui_input(event):
	if Input.is_action_just_pressed("click"):
		Signals.sectioClicked.emit(null)
		Signals.buyArcanaCard.emit()
		Signals.tutorialRead.emit()


func _on_show_lieutenants_h_box_container_gui_input(event):
	if Input.is_action_just_pressed("click"):
		Signals.toggleAvailableLieutenants.emit(true)


func _on_end_phase_margin_container_gui_input(event):
	if Input.is_action_just_pressed("click"):
		Signals.summoningDone.emit()
		Signals.playerDoneWithPhase.emit()
		AudioSignals.playerTurnDone.emit()
