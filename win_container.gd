extends MarginContainer

@export var winTexture : Texture
@export var looseTexture : Texture

func _ready():
	Signals.win.connect(win)

func win(boolean, playerId):
	var player = Data.players[playerId]
	if boolean:
		%WinLabel.text = "Satan congratualtes you to your vicious and evil achievements. Smiling he welcomes you as his right hand to rule in hell."
		%WinTextureRect.texture = winTexture
	else:
		%WinLabel.text = "You look envious as your opponent " + player.playerName + " is taking his place next to Satan. His time down there will be short and you already make plans to usurp once more."
		%WinTextureRect.texture = looseTexture
	%WinMarginContainer.show()
