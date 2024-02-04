extends VBoxContainer

signal clicked(node)
var troopNode
var modulateBefore
var unitNr : int = 0
var marginContainer
var startPosition : Vector2

func populate(_troopNode):
	troopNode = _troopNode
#	%NameLabel.text = troopNode.unitName
	unitNr = troopNode.unitNr
#	$TextureRect.texture = troopNode.texture
#	$TextureRect.modulate = Data.players[troopNode.triumphirate].color
	marginContainer = troopNode.marginContainer.duplicate(5) # duplicate scripts and signals
	add_child(marginContainer)
	modulateBefore = marginContainer.modulate
	marginContainer.setScale()
	startPosition = marginContainer.position
#	await get_tree().process_frame
#	marginContainer.scale = Vector2(0.3, 0.3)
	Signals.showUnitAttackChance.connect(_on_showUnitAttackChance)
	Signals.hideUnitAttackChance.connect(_on_hideUnitAttackChance)
	
	Signals.showUnitDefendChance.connect(_on_showUnitDefendChance)
	Signals.hideUnitDefendChance.connect(_on_hideUnitDefendChance)
	
	Signals.showAttackResult.connect(_on_showAttackResult)
	Signals.showDefendResult.connect(_on_showDefendResult)

func _on_showUnitAttackChance(_unitNr : int, chance : int = 0):
	if _unitNr == unitNr:
		marginContainer.showHitChance(chance)

func _on_hideUnitAttackChance(chance : int = 0):
	if marginContainer.has_method("hideHitChance"):
		marginContainer.hideHitChance()


func _on_showUnitDefendChance(_unitNr : int, chance : int = 0):
	if _unitNr == unitNr:
		marginContainer.showDefendChance(chance)

func _on_hideUnitDefendChance(chance : int = 0):
	if marginContainer.has_method("hideDefendChance"):
		marginContainer.hideDefendChance()


func _on_showAttackResult(_unitNr : int, attackResult : int, success : bool):
	if _unitNr == unitNr:
		if marginContainer.has_method("showAttackResult"):
			marginContainer.showAttackResult(attackResult, success)


func _on_showDefendResult(_unitNr : int, defendResult : int, success : bool):
	if _unitNr == unitNr:
		if marginContainer.has_method("showDefendResult"):
			marginContainer.showDefendResult(defendResult, success)


func _on_gui_input(event):
	if Input.is_action_just_pressed("click"):
		get_viewport().set_input_as_handled()
		clicked.emit(troopNode)


func attack(playerOwnsUnit : bool):
	marginContainer.attack(playerOwnsUnit)


func hit():
#	marginContainer.modulate = Color8(155, 155, 155)
	marginContainer.hit()


func unHit():
	pass
#	marginContainer.modulate = modulateBefore


func kill():
	# its a duplicate so it behaves like the original node
	# killing it on the map, kills it here as well
#	marginContainer.kill()
	pass
#	await get_tree().create_timer(1.1).timeout
#	queue_free()
