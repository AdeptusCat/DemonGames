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


func setScale():
	var textureRect = get_node("VBoxContainer/MarginContainer/TextureRect")
	textureRect.custom_minimum_size = Vector2(40, 40)
	var nameLabel = get_node("VBoxContainer/Label")
	nameLabel.add_theme_font_size_override("small", 2)


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
