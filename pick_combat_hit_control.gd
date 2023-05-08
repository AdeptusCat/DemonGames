extends Control

const PickMoveUnitVBoxContainerScene = preload("res://pick_move_unit_v_box_container.tscn")
signal legionsHit(unitNames)

var unitsHit = []
var hits = 0
var unitNrs = []

func highlight(_unitNrs : Array, _hits : int):
	print("highlight")
	unitsHit = []
	unitNrs = _unitNrs
	hits = _hits
	print("distribute ", str(hits), " hits")
	for unitNr in unitNrs:
		var troop = Data.troops[unitNr]
		var scene = PickMoveUnitVBoxContainerScene.instantiate()
		scene.populate(troop)
		scene.clicked.connect(_on_troopClicked)
		%PickMoveUnitHBoxContainer.add_child(scene)
	show()


func _on_exit_button_pressed():
	legionsHit.emit(unitsHit)
	for node in %PickMoveUnitHBoxContainer.get_children():
		node.queue_free()
	hide()

func _on_troopClicked(node):
	unitsHit.append(node.unitNr)
	print("unit hit ", node)
	if unitsHit.size() >= hits:
		legionsHit.emit(unitsHit)
		print("units hit total: ", unitsHit)
		for child in %PickMoveUnitHBoxContainer.get_children():
			child.queue_free()
		hide()
	else:
		if %PickMoveUnitHBoxContainer.get_child_count() <= 0:
			for unitNr in unitNrs:
				var troop = Data.troops[unitNr]
				var scene = PickMoveUnitVBoxContainerScene.instantiate()
				scene.populate(troop)
				scene.clicked.connect(_on_troopClicked)
				%PickMoveUnitHBoxContainer.add_child(scene)
