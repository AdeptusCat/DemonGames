extends MarginContainer

#@onready var textureRect = $VBoxContainer/MarginContainer/TextureRect
#@onready var nameLabel = $VBoxContainer/Label


#func _ready():
#	Signals.unitsHit.connect(_on_unitsHit)


#func _on_unitsHit(unitsDict : Dictionary):
#	if unitsDict.has(Data.id):
#		if unitsDict[Data.id].has(Data.id)
#		for troopName in _unitsDict[triumphirate]:
#

var successColor : Color = Color(0, 0.61353474855423, 0.26302886009216)
var failureColor : Color = Color(0.93796443939209, 0.11590015143156, 0.00830447953194)



func showHitChance(chance : int = 0):
	var formatString = "%s+"
	if has_node("VBoxContainer/HBoxContainer/HitChanceLabel"):
		get_node("VBoxContainer/HBoxContainer/HitChanceLabel").text = formatString % str(6 - chance)
		get_node("VBoxContainer/HBoxContainer/HitChanceLabel").show()


func hideHitChance():
	if has_node("VBoxContainer/HBoxContainer/HitChanceLabel"):
		get_node("VBoxContainer/HBoxContainer/HitChanceLabel").hide()


func showDefendChance(chance : int = 1):
	var formatString = "%s-"
	if has_node("VBoxContainer/HBoxContainer/DefendChanceLabel"):
		get_node("VBoxContainer/HBoxContainer/DefendChanceLabel").text = formatString % str(chance)
		get_node("VBoxContainer/HBoxContainer/DefendChanceLabel").show()


func hideDefendChance():
	if has_node("VBoxContainer/HBoxContainer/DefendChanceLabel"):
		get_node("VBoxContainer/HBoxContainer/DefendChanceLabel").hide()


func showAttackResult(attackResult : int, success : bool = false):
	var label : Label = Label.new()
	label.text = str(attackResult)
	if success:
		label.modulate = successColor
	add_child(label)
	var tw1 = create_tween()
	tw1.set_trans(Tween.TRANS_QUAD)
	tw1.set_ease(Tween.EASE_IN)
	tw1.tween_property(label, "position", label.position - Vector2(0 ,20), 1.0)
	tw1.tween_callback(label.queue_free)


func showDefendResult(defendResult : int, success : bool = false):
	var label : Label = Label.new()
	label.text = str(defendResult)
	if success:
		label.modulate = successColor
	else:
		label.modulate = failureColor
	add_child(label)
	label.position.x = size.x / 2
	var tw1 = create_tween()
	tw1.set_trans(Tween.TRANS_QUAD)
	tw1.set_ease(Tween.EASE_IN)
	tw1.tween_property(label, "position", label.position - Vector2(0 ,20), 1.0)
	tw1.tween_callback(label.queue_free)


func setScale():
	var textureRect = get_node("VBoxContainer/MarginContainer/TextureRect")
	textureRect.custom_minimum_size = Vector2(40, 40)
	var nameLabel = get_node("VBoxContainer/HBoxContainer/NameLabel")
	nameLabel.add_theme_font_size_override("small", 2)
	var hitChanceLabel = get_node("VBoxContainer/HBoxContainer/HitChanceLabel")
	hitChanceLabel.add_theme_font_size_override("small", 2)
	var DefendChanceLabel = get_node("VBoxContainer/HBoxContainer/DefendChanceLabel")
	DefendChanceLabel.add_theme_font_size_override("small", 2)


func attack(playerOwnsUnit : bool):
	await get_tree().create_timer(0.1).timeout # otherwise the position is ffd
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
	print("legion gets killed")
	var tw1 = create_tween()
	tw1.set_trans(Tween.TRANS_QUAD)
	tw1.set_ease(Tween.EASE_IN)
	print(Data.id," killed ",self)
	tw1.parallel().tween_property(%TextureRect.get_material(), "shader_parameter/dissolveState", 1.0, 2.0)
	tw1.parallel().tween_property(%ColorRect.get_material(), "shader_parameter/dissolveState", 1.0, 2.0)
	tw1.tween_callback(queue_free)
#	queue_free()
