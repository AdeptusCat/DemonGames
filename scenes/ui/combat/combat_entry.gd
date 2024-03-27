extends MarginContainer
class_name CombatEntry

@export var playerColorScene : PackedScene


var smallSize : Vector2 = Vector2(128, 128)
var bigSize : Vector2 = Vector2(192, 192)


func addColors(colors : Array):
	var children = %ColorsHBoxContainer.get_children()
	for child in children:
		child.queue_free()
	for color : Color in colors:
		var playerColor : ColorRect = playerColorScene.instantiate()
		playerColor.color = color
		%ColorsHBoxContainer.add_child(playerColor)


func setSectio(sectioName : String):
	%SectioLabel.text = sectioName
