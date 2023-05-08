extends MarginContainer

var hovering = false
var expand = false
var button
var startPosition 


var buttonTextCombat = "Pick Demons to fight in Battle or"
var buttonTextNormal = "Demons of your Triumphirate"
var buttonTextStart = "Examine your Triumphirate"

var tw1

# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.expandDemonCards.connect(expandDemonCards)
	Signals.collapseDemonCards.connect(collapseDemonCards)
	Signals.addDemonToUi.connect(_on_addDemon)
	startPosition = position
	%DemonHeaderLabel.text = buttonTextNormal

func _on_addDemon(demon):
	%DemonHBoxContainer.add_child(demon)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hovering and not expand:
		if get_global_mouse_position().y > 200:
#			position -= Vector2(0, 650)
			hovering = false
			tw1 = get_tree().create_tween()
			tw1.set_trans(Tween.TRANS_QUAD)
			tw1.set_ease(Tween.EASE_IN_OUT)
			tw1.parallel().tween_property(self, "position", startPosition - Vector2(0, 550), 0.2)


func collapse():
	tw1 = get_tree().create_tween()
	tw1.set_trans(Tween.TRANS_QUAD)
	tw1.set_ease(Tween.EASE_IN_OUT)
	tw1.parallel().tween_property(self, "position", startPosition - Vector2(0, 550), 0.2)


func removeDemon(rank : int):
	for child in %DemonHBoxContainer.get_children():
		if not child is Label:
			if child.rank == rank:
				child.queue_free()


func _on_mouse_entered():
	hovering = true
#	position = startPosition
	tw1 = get_tree().create_tween()
	tw1.set_trans(Tween.TRANS_QUAD)
	tw1.set_ease(Tween.EASE_IN_OUT)
	tw1.parallel().tween_property(self, "position", startPosition, 0.2)


func expandDemonCards(battle : bool = true):
	button = Button.new()
	if battle:
		expand = true
		_on_mouse_entered()
		%DemonHeaderLabel.text = buttonTextCombat
		button.text = "Click me to go to Battle without Demon."
		button.pressed.connect(_on_noDemonClicked)
	else:
		expand = true
		_on_mouse_entered()
		%DemonHeaderLabel.text = buttonTextStart
		button.text = "Proceed."
		button.pressed.connect(_on_proceedClicked)
	%DemonVBoxContainer.add_child(button)


func collapseDemonCards():
	%DemonHeaderLabel.text = buttonTextNormal
	expand = false
	collapse()
	if is_instance_valid(button):
		button.queue_free()


func _on_proceedClicked():
	Signals.proceed.emit()
	%DemonHeaderLabel.text = buttonTextNormal
	collapseDemonCards()

func _on_noDemonClicked():
	%DemonHeaderLabel.text = buttonTextNormal
	expand = false
	button.queue_free()
	Signals.noDemonPicked.emit()
