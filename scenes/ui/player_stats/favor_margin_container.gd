extends MarginContainer


func _ready():
	Signals.changeFavors.connect(_on_changeFavors)


func _on_changeFavors(playerId : int, favors : int):
	if playerId == Data.id:
		%FavorLabel.text = str(favors)
