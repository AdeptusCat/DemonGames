extends MarginContainer


func _ready():
	Signals.changeSouls.connect(_on_changeSouls)


func _on_changeSouls(playerId : int, souls : int):
	if playerId == Data.id:
		%SoulsLabel.text = str(souls)
