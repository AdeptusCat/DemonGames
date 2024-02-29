extends MarginContainer


var followMouse : bool = false
var lieutenantName : String = ""
@onready var startposition : Vector2 = position
var availableToBuy : bool = false
var cost : int = 0


func _ready():
	lieutenantName = get_node("VBoxContainer/MarginContainer2/HBoxContainer/MarginContainer/NameLabel").text
	Signals.removeChosenLieutenantFromMouse.connect(_on_removeChosenLieutenantFromMouse)


func _on_removeChosenLieutenantFromMouse(_lieutenantName):
	if _lieutenantName == lieutenantName:
		queue_free()


func activate():
	availableToBuy = true
	%DeactivateColorRect.hide()


func deactivate():
	availableToBuy = false
	%DeactivateColorRect.show()


func _input(event):
	if event is InputEventMouseMotion:
		var x = remap(event.global_position.x, 0, DisplayServer.window_get_size().x, 0, 1920)
		var y = remap(event.global_position.y, 0, DisplayServer.window_get_size().y, 0, 1080)
		if followMouse:
			global_position = Vector2(x, y) + Vector2(10, 10)


func setScale():
	var marginContainer : MarginContainer = get_node("VBoxContainer/MarginContainer/MarginContainer")
	marginContainer.add_theme_constant_override("margin_left", 10)
	marginContainer.add_theme_constant_override("margin_top", 10)
	marginContainer.add_theme_constant_override("margin_right", 10)
	marginContainer.add_theme_constant_override("margin_bottom", 10)
	var textureRect = get_node("VBoxContainer/MarginContainer/TextureRect")
	textureRect.custom_minimum_size = Vector2(60, 60)
	var prefixLabel = get_node("VBoxContainer/MarginContainer2/HBoxContainer/HBoxContainer/PrefixLabel")
	prefixLabel.add_theme_font_size_override("small", 7)
	var bonusLabel = get_node("VBoxContainer/MarginContainer2/HBoxContainer/HBoxContainer/CombatBonusLabel")
	bonusLabel.add_theme_font_size_override("small", 7)
	var nameLabel = get_node("VBoxContainer/MarginContainer2/HBoxContainer/HBoxContainer/CombatBonusLabel")
	nameLabel.add_theme_font_size_override("small", 7)
	var capacityLabel = get_node("VBoxContainer/MarginContainer2/HBoxContainer/CapactiyLabel")
	capacityLabel.add_theme_font_size_override("small", 7)
	

func populate(unitName, lieutenantTextureDir, combatBonus, capacity, triumphirate = null):
	%LieutenantTextureRect.texture = load(lieutenantTextureDir)
	%CombatBonusLabel.text = combatBonus
	%CapactiyLabel.text = capacity
	%NameLabel.text = unitName
	if triumphirate:
		var texture = Data.icons[Data.players[triumphirate].colorName]
		%TextureRect.texture = texture
	cost = (combatBonus.to_int() + capacity.to_int())*2
	lieutenantName = unitName


func toggleTriumphirateIcon(boolean : bool, triumphirate : int):
	if boolean:
		var texture = Data.icons[Data.players[triumphirate].colorName]
		%TextureRect.texture = texture
	else:
		%TextureRect.texture = null


func getLieutenantName():
	return lieutenantName


func attack(playerOwnsUnit : bool):
	var startPosition : Vector2 = position
	var tw1 = create_tween()
	tw1.set_trans(Tween.TRANS_QUAD)
	tw1.set_ease(Tween.EASE_IN)
	if playerOwnsUnit:
		tw1.tween_property(self, "position", startPosition - Vector2(0 ,10), 0.2)
		tw1.tween_property(self, "position", startPosition, 0.2)
	else:
		tw1.tween_property(self, "position", startPosition + Vector2(0 ,10), 0.2)
		tw1.tween_property(self, "position", startPosition, 0.2)


func hit():
	var node = get_node("VBoxContainer/MarginContainer/TextureRect")
	if node:
		var tw1 = create_tween()
		tw1.set_trans(Tween.TRANS_QUAD)
		tw1.set_ease(Tween.EASE_IN)
		tw1.tween_property(node.get_material(), "shader_parameter/flashState", 5.0, 0.2)
		tw1.tween_property(node.get_material(), "shader_parameter/flashState", 1.0, 0.1)


func kill():
	var tw1 = create_tween()
	tw1.set_trans(Tween.TRANS_QUAD)
	tw1.set_ease(Tween.EASE_IN)
	tw1.parallel().tween_property(%TextureRect.get_material(), "shader_parameter/dissolveState", 1.0, 2.0)
	tw1.parallel().tween_property(%ColorRect.get_material(), "shader_parameter/dissolveState", 1.0, 2.0)
	tw1.tween_callback(queue_free)


func highlight():
	followMouse = true
	var texture = Data.icons[Data.player.colorName]
	%TextureRect.texture = texture


func _on_gui_input(event):
	if Input.is_action_just_pressed("click"):
		if availableToBuy:
			availableToBuy = false
			Signals.removeChosenLieutenantFromAvailableLieutenantsBox.emit(lieutenantName)
			Signals.toggleAvailableLieutenants.emit(false)
			var souls = Data.player.souls - cost
			Signals.changeSouls.emit(Data.id, souls)
			Signals.emitSoulsFromTreasury.emit(event.global_position, cost) 
			Signals.recruitLieutenant.emit(lieutenantName)
