extends Node


func _ready():
	AudioSignals.walkTheEarth.connect(_on_walkTheEarth)
	AudioSignals.passAction.connect(_on_passAction)
	AudioSignals.passForGood.connect(_on_passForGood)
	AudioSignals.battleStart.connect(_on_battleStart)
	AudioSignals.castArcana.connect(_on_castArcana)
	
	AudioSignals.playerTurn.connect(_on_playerTurn)
	AudioSignals.phaseChange.connect(_on_phaseChange)
	AudioSignals.enemyEnteringSectio.connect(_on_enemyEnteringSectio)
	AudioSignals.enemyEnteringSectioResult.connect(_on_enemyEnteringSectioResult)
	AudioSignals.combatWon.connect(_on_combatWon)

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

func _on_playerTurn():
	%playerTurnAudio.play()

func _on_phaseChange(phase : int):
	match phase:
		Data.phases.Hell:
			%HellPhaseAudio.play()
		Data.phases.Soul:
			%SoulPhaseAudio.play()
		Data.phases.Summoning:
			%SummoningPhaseAudio.play()
		Data.phases.Action:
			%ActionPhaseAudio.play()
		Data.phases.Combat:
			%CombatPhaseAudio.play()
		Data.phases.Petitions:
			%PetitionPhaseAudio.play()

func _on_enemyEnteringSectio():
	%EnemyEnteringSectioAudio.play()

func _on_enemyEnteringSectioResult(fleeingConfirmed : bool):
	if fleeingConfirmed:
		%EnemyFleeingAudio.play()
	else:
		%EnemyStayingAudio.play()

func _on_combatWon():
	%CombatWonAudio.play()
