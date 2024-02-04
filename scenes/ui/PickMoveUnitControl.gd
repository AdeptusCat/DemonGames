extends Control

const PickMoveUnitVBoxContainerScene = preload("res://scenes/ui/pick_move_unit_v_box_container.tscn")

func highlight(sectio):
	for troopName in sectio.troops:
		var troop = Data.troops[troopName]
		var scene = PickMoveUnitVBoxContainerScene.instantiate()
		scene.populate(troop)
		scene.clicked.connect(_on_troopClicked)
		%PickMoveUnitHBoxContainer.add_child(scene)
	show()


func _on_exit_button_pressed():
	Signals.unitClicked.emit(null)
	for child in %PickMoveUnitHBoxContainer.get_children():
		child.queue_free()
	hide()

func _on_troopClicked(node):
	Signals.unitClicked.emit(node)
	for child in %PickMoveUnitHBoxContainer.get_children():
		child.queue_free()
	hide()


