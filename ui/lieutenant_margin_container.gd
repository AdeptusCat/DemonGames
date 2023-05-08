extends MarginContainer

#@onready var textureRect = $VBoxContainer/MarginContainer/TextureRect
#@onready var prefixLabel = $VBoxContainer/MarginContainer2/HBoxContainer/HBoxContainer/PrefixLabel
#@onready var bonusLabel = $VBoxContainer/MarginContainer2/HBoxContainer/HBoxContainer/CombatBonusLabel
#@onready var nameLabel = $VBoxContainer/MarginContainer2/HBoxContainer/HBoxContainer/CombatBonusLabel
#@onready var capacityLabel = $VBoxContainer/MarginContainer2/HBoxContainer/CapactiyLabel


#@onready var textureRect = %TextureRect
#@onready var colorRect = %ColorRect
#@onready var lieutenantTextureRect = %LieutenantTextureRect

#@onready var textureRectMaterial = textureRect.get_material()
#@onready var colorRectMaterial = colorRect.get_material()
#@onready var lieutenantTextureRectMaterial = lieutenantTextureRect.get_material()


var followMouse : bool = false
var lieutenantName : String = ""
@onready var startposition : Vector2 = position


func _ready():
	Signals.removeLieutenantFromAvailableLieutenantsBox.connect(_on_removeLieutenantFromAvailableLieutenantsBox)
	lieutenantName = get_node("VBoxContainer/MarginContainer2/HBoxContainer/MarginContainer/NameLabel").text


func _input(event):
	if event is InputEventMouseMotion:
		if followMouse:
			global_position = event.global_position + Vector2(10, 10)


func _on_removeLieutenantFromAvailableLieutenantsBox(_lieutenantName : String):
	if _lieutenantName == lieutenantName:
		queue_free()


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
	print("lieut gets killed")
	var tw1 = create_tween()
	tw1.set_trans(Tween.TRANS_QUAD)
	tw1.set_ease(Tween.EASE_IN)
	tw1.parallel().tween_property(%TextureRect.get_material(), "shader_parameter/dissolveState", 1.0, 2.0)
#	tw1.parallel().tween_property(%LieutenantTextureRect, "shader_parameter/dissolveState", 1.0, 2.0)
	tw1.parallel().tween_property(%ColorRect.get_material(), "shader_parameter/dissolveState", 1.0, 2.0)
	tw1.tween_callback(queue_free)

func highlight():
	followMouse = true
	var texture = Data.icons[Data.player.colorName]
	%TextureRect.texture = texture
	
