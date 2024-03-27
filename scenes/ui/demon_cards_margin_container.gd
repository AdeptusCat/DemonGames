extends MarginContainer

var hovering = false
var expand = false
@onready var button : Button = %Button
@onready var button_collapse : Button = %CollapseButton
var startPosition 
var mouseEnteredPositiony : int = 0

var buttonTextCombat = "Pick Demons to fight in Battle or"
var buttonTextNormal = "Demons of your Triumphirate"
var buttonTextStart = "Examine your Triumphirate"

var tw1


func _ready():
	Signals.expandDemonCards.connect(expandDemonCards)
	Signals.collapseDemonCards.connect(collapseDemonCards)
	Signals.addDemonToUi.connect(_on_addDemon)
	startPosition = position
	%DemonHeaderLabel.text = buttonTextNormal
	if not Data.chooseDemon:
		collapse()
	reset_size()


func _on_addDemon(demon):
	%DemonHBoxContainer.add_child(demon)
	reset_size()

func _process(delta):
	return
	if hovering and not expand:
		if get_global_mouse_position().y > mouseEnteredPositiony + 10:
			#return
#			position -= Vector2(0, 650)
			hovering = false
			tw1 = create_tween()
			tw1.set_trans(Tween.TRANS_QUAD)
			tw1.set_ease(Tween.EASE_IN_OUT)
			tw1.parallel().tween_property(self, "position", startPosition - Vector2(0, 770), 0.2)


func collapse():
	return
	tw1 = create_tween()
	tw1.set_trans(Tween.TRANS_QUAD)
	tw1.set_ease(Tween.EASE_IN_OUT)
	tw1.parallel().tween_property(self, "position", startPosition - Vector2(0, 550), 0.2)
	reset_size()


func removeDemon(rank : int):
	for child in %DemonHBoxContainer.get_children():
		if not child is Label:
			if child.rank == rank:
				child.queue_free()
	reset_size()


func _on_mouse_entered():
	return
	mouseEnteredPositiony = get_global_mouse_position().y
	hovering = true
#	position = startPosition
	tw1 = create_tween()
	tw1.set_trans(Tween.TRANS_QUAD)
	tw1.set_ease(Tween.EASE_IN_OUT)
	tw1.parallel().tween_property(self, "position", startPosition, 0.2)


func expandDemonCards(battle : bool = true):
	#button = Button.new()
	show()
	if battle:
		expand = true
		_on_mouse_entered()
		%DemonHeaderLabel.text = buttonTextCombat
		button.text = "Click me to go to Battle without Demon."
		if not button.pressed.is_connected(_on_noDemonClicked):
			button.pressed.connect(_on_noDemonClicked)
		if button.pressed.is_connected(_on_proceedClicked):
			button.pressed.disconnect(_on_proceedClicked)
		button.show()
		button_collapse.text = "Collapse"
		button_collapse.show()
	else:
		expand = true
		_on_mouse_entered()
		%DemonHeaderLabel.text = buttonTextStart
		button.text = "Proceed."
		if not button.pressed.is_connected(_on_proceedClicked):
			button.pressed.connect(_on_proceedClicked)
		if button.pressed.is_connected(_on_noDemonClicked):
			button.pressed.disconnect(_on_noDemonClicked)
		button.show()
	reset_size()
	#%DemonVBoxContainer.add_child(button)


func collapseDemonCards():
	hide()
	%DemonHeaderLabel.text = buttonTextNormal
	expand = false
	collapse()
	button.hide()
	button_collapse.hide()
	reset_size()
	#if is_instance_valid(button):
		#button.queue_free()
	#if is_instance_valid(button_collapse):
		#button_collapse.queue_free()


func _on_proceedClicked():
	Signals.proceed.emit()
	%DemonHeaderLabel.text = buttonTextNormal
	collapseDemonCards()


func _on_noDemonClicked():
	%DemonHeaderLabel.text = buttonTextNormal
	expand = false
	#button.queue_free()
	button.hide()
	reset_size()
	Data.pickDemon = false
	RpcCalls.pickedDemonForCombat.rpc_id(Connection.host, 0)


func _on_mouse_exited():
	#return
	return
	if hovering and not expand:
		hovering = false
		tw1 = create_tween()
		tw1.set_trans(Tween.TRANS_QUAD)
		tw1.set_ease(Tween.EASE_IN_OUT)
		tw1.parallel().tween_property(self, "position", startPosition - Vector2(0, 550), 0.2)
	reset_size()
	set_anchors_preset(PRESET_CENTER)


func _on_collapse_button_pressed():
	if expand:
		expand = false
		collapse()
		button_collapse.text = "Expand"
	else:
		expand = true
		button_collapse.text = "Collapse"


func _on_button_pressed():
	Signals.collapseDemonCards.emit()
