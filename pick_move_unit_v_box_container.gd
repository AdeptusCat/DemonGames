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
	marginContainer = troopNode.marginContainer.duplicate(4) # duplicate scripts
	add_child(marginContainer)
	modulateBefore = marginContainer.modulate
	marginContainer.setScale()
	startPosition = marginContainer.position
#	await get_tree().process_frame
#	marginContainer.scale = Vector2(0.3, 0.3)


func _on_gui_input(event):
	if Input.is_action_just_pressed("click"):
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
