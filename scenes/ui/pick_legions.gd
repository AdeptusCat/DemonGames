extends Control

var possibelLegions = []
var pickedLegions = []
var unitsAlreadyMovingWithLieutenant : Array = []
@export var labelScene : PackedScene
var capacity = 0

signal done(legions)

func _ready():
	print("pick units 1 ",possibelLegions, unitsAlreadyMovingWithLieutenant)
	var _possibleLegions = possibelLegions.duplicate()
	for legion in _possibleLegions:
		var label = labelScene.instantiate()
#		label.text = legion.unitName + " " + str(legion.unitNr)
		label.unitNr = legion.unitNr
		label.clicked.connect(_on_labelClicked)
		var marginContainer = legion.marginContainer.duplicate(4)
		label.add_child(marginContainer)
		marginContainer.setScale()
		if unitsAlreadyMovingWithLieutenant.has(legion):
			print("pickd units 2 ", legion)
			possibelLegions.erase(legion)
			pickedLegions.append(legion)
			%PickedLegionVBoxContainer.add_child(label)
		else:
			print("pickd units 3 ", legion)
			%PossibleLegionVBoxContainer.add_child(label)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_labelClicked(node):
	print("parent ", node.get_parent().name)
	if node.get_parent().name == "PossibleLegionVBoxContainer":
		print("pick ",%PickedLegionVBoxContainer.get_child_count(), " ",capacity)
		if %PickedLegionVBoxContainer.get_child_count() < capacity:
			%PossibleLegionVBoxContainer.remove_child(node)
			%PickedLegionVBoxContainer.add_child(node)
			possibelLegions.erase(Data.troops[node.unitNr])
			pickedLegions.append(Data.troops[node.unitNr])
			print("picked ",pickedLegions)
	else:
		%PickedLegionVBoxContainer.remove_child(node)
		%PossibleLegionVBoxContainer.add_child(node)
		pickedLegions.erase(Data.troops[node.unitNr])
		possibelLegions.append(Data.troops[node.unitNr])


func _on_done_button_pressed():
	done.emit(pickedLegions)
	queue_free()
