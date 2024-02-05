extends Node


var audioQueue : Array[AudioStreamPlayer] = []
var currentAudio : AudioStreamPlayer = AudioStreamPlayer.new()
var playerTurn : bool = false


func _ready():
	AudioSignals.walkTheEarth.connect(_on_walkTheEarth)
	AudioSignals.passAction.connect(_on_passAction)
	AudioSignals.passForGood.connect(_on_passForGood)
	AudioSignals.battleStart.connect(_on_battleStart)
	AudioSignals.castArcana.connect(_on_castArcana)
	
	AudioSignals.playerTurn.connect(_on_playerTurn)
	AudioSignals.playerTurnDone.connect(_on_PlayerTurnDone)
	AudioSignals.phaseChange.connect(_on_phaseChange)
	AudioSignals.enemyEnteringSectio.connect(_on_enemyEnteringSectio)
	AudioSignals.enemyEnteringSectioResult.connect(_on_enemyEnteringSectioResult)
	AudioSignals.combatWon.connect(_on_combatWon)


func _process(delta):
	if not audioQueue.is_empty():
		if not currentAudio.playing:
			currentAudio = audioQueue.pop_front()
			currentAudio.play()


func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if not %RemindPlayerTimer.is_stopped():
				%RemindPlayerTimer.start()
	if event is InputEventMouseButton:
		if event.pressed:
			if not %RemindPlayerTimer.is_stopped():
				%RemindPlayerTimer.start()


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
	playerTurn = true
	%RemindPlayerTimer.start()
	audioQueue.append(%playerTurnAudio)
	#%playerTurnAudio.play()

func _on_PlayerTurnDone():
	playerTurn = false

func _on_phaseChange(phase : int):
	match phase:
		Data.phases.Hell:
			return
			audioQueue.append(%HellPhaseAudio)
			#%HellPhaseAudio.play()
		Data.phases.Soul:
			audioQueue.append(%SoulPhaseAudio)
			#%SoulPhaseAudio.play()
		Data.phases.Summoning:
			audioQueue.append(%SummoningPhaseAudio)
			#%SummoningPhaseAudio.play()
		Data.phases.Action:
			audioQueue.append(%ActionPhaseAudio)
			#%ActionPhaseAudio.play()
		Data.phases.Combat:
			audioQueue.append(%CombatPhaseAudio)
			#%CombatPhaseAudio.play()
		Data.phases.Petitions:
			audioQueue.append(%PetitionPhaseAudio)
			#%PetitionPhaseAudio.play()

func _on_enemyEnteringSectio():
	%EnemyEnteringSectioAudio.play()

func _on_enemyEnteringSectioResult(fleeingConfirmed : bool):
	if fleeingConfirmed:
		%EnemyFleeingAudio.play()
	else:
		%EnemyStayingAudio.play()

func _on_combatWon():
	audioQueue.append(%CombatWonAudio)


func _on_remind_player_timer_timeout():
	if playerTurn:
		audioQueue.append(%playerTurnAudio)
		%RemindPlayerTimer.start()