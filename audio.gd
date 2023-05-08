extends Node


func _ready():
	AudioSignals.walkTheEarth.connect(_on_walkTheEarth)
	AudioSignals.passAction.connect(_on_passAction)
	AudioSignals.passForGood.connect(_on_passForGood)
	AudioSignals.battleStart.connect(_on_battleStart)
	AudioSignals.castArcana.connect(_on_castArcana)
	


func _on_walkTheEarth():
	%WalkTheEarthAudio.play()

func _on_passAction():
	%PassAudio.play()

func _on_passForGood():
	%PassForGoodAudio.play()

func _on_battleStart():
	%BattleStartAudio.play()

func _on_castArcana():
	%CastArcanaAudio.play()
