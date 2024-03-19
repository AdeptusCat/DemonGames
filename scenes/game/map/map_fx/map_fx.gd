extends Node2D


func _ready():
	Signals.potatoPc.connect(_on_potatoPc)


func _on_potatoPc(boolean : bool):
	$Sprite2D9.visible = !boolean
	$CircleFog.use_parent_material = boolean
	$TextureRect5.visible = !boolean
	$ColorRect.visible = boolean
