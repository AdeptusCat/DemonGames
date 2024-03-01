extends MarginContainer

var lieutenantMarginContainers : Array = []
var startTime = Time.get_ticks_msec()
var activeLieutenantMarginContainer
var intervalDefault : float = 0.1
var interval : float = intervalDefault
var startSpin : bool = false
var spinCounter : int = 0
var goalLieutenantMarginContainer
var costLabels : Dictionary = {}


func _ready():
	Signals.addLieutenantToAvailableLieutenantsBox.connect(_on_addLieutenantToAvailableLieutenantsBox)
	Signals.removeChosenLieutenantFromAvailableLieutenantsBox.connect(_on_removeChosenLieutenantFromAvailableLieutenantsBox)


func _on_addLieutenantToAvailableLieutenantsBox(lieutenantName):
	var lieutenant = Decks.lieutenantsReference[lieutenantName]
	var lieutenantMarginContainerScene = load("res://scenes/ui/lieutenant_margin_container.tscn")
	var lieutenantMarginContainer = lieutenantMarginContainerScene.instantiate()
	lieutenantMarginContainer.populate(lieutenantName, lieutenant.texture, str(lieutenant["combat bonus"]), str(lieutenant.capacity))
	lieutenantMarginContainer.availableToBuy = true
	%AvailableLieutenantsHBoxContainer.add_child(lieutenantMarginContainer)
	
	
	var costLabel : Label = Label.new()
	costLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	costLabel.size_flags_horizontal = SIZE_EXPAND_FILL
	costLabel.text = str(lieutenantMarginContainer.cost)
	%AvailableLieutenantsCostHBoxContainer.add_child(costLabel)
	costLabels[lieutenantName] = costLabel
	
	canPlayerAffordLieutenants()


func canPlayerAffordLieutenants():
	for lieutenantMarginContainer in %AvailableLieutenantsHBoxContainer.get_children():
		if Data.player.hasEnoughSouls(lieutenantMarginContainer.cost):
			lieutenantMarginContainer.activate()
		else:
			lieutenantMarginContainer.deactivate()


func _on_removeChosenLieutenantFromAvailableLieutenantsBox(lieutenantName):
	var marginContainer
	for child in %AvailableLieutenantsHBoxContainer.get_children():
		var unitName = child.getLieutenantName()
		if unitName == lieutenantName:
			child.highlight()
			marginContainer = child
			%AvailableLieutenantsHBoxContainer.remove_child(child)
			await get_tree().create_timer(0.1).timeout
			Signals.showChosenLieutenantFromAvailableLieutenantsBox.emit(child)
	if costLabels.has(lieutenantName):
		costLabels[lieutenantName].queue_free()
		costLabels.erase(lieutenantName)


func toogleBuyLieutenant(boolean : bool):
	if boolean:
		show()
		Signals.toggleAvailableLieutenantsCheckButtonPressed.emit(true)
	else:
		hide()
		Signals.toggleAvailableLieutenantsCheckButtonPressed.emit(false)


func _on_button_pressed():
	hide()
