extends MarginContainer
class_name RankTrackEntry

@onready var textureRect = $MarginContainer/TextureRect
@onready var colorRect = $ColorRect


var rank : int = 0
var playerId : int = 0

func _on_mouse_entered():
	Signals.rankTrackEntryMouseEntered.emit(rank)


func _on_mouse_exited():
	Signals.rankTrackEntryMouseExited.emit()


func flash():
	%TextureRect.get_material().set_shader_parameter("active", true)
