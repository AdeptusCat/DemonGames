extends Control


#func _ready():
#	for player in Data.players:
#		Data.players[player].changeSoulsSignal.connect(_on_soulsChangedSignal)
#
#
#var soulsArray: Array:
#	set(array):
#		soulsArray = array
#		%SoulsLabel.clear()
#		for souls in soulsArray:
#			%SoulsLabel.add_text(str(souls) + "\n")
#
#func _on_soulsChangedSignal(value):
#	soulsArray = [value]
