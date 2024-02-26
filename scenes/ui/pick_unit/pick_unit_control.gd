extends Control

@export var PickMoveUnitVBoxContainerScene : PackedScene

func highlight(sectio):
	for troopName in sectio.troops:
		var troop = Data.troops[troopName]
		var scene = PickMoveUnitVBoxContainerScene.instantiate()
		scene.populate(troop)
		scene.clicked.connect(_on_troopClicked)
		%PickMoveUnitHBoxContainer.add_child(scene)


func _on_exit_button_pressed():
	Signals.unitClicked.emit(null)
	for child in %PickMoveUnitHBoxContainer.get_children():
		child.queue_free()
	queue_free()


func _on_troopClicked(node):
	Signals.unitClicked.emit(node)
	for child in %PickMoveUnitHBoxContainer.get_children():
		child.queue_free()
	queue_free()


