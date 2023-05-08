extends Node

var menuOpen : bool = false

var debug : bool = false
#var debug : bool = true

var tooltips = true
var skipScreens = false
var skipSoulsSummary = false
var skipWaitForPlayers = false
var skipPhaseReminder = false

var skipHell = false
var skipSouls = false
var skipSummoning = false
var skipAction = false
var skipCombat = false
var skipPetitions = false
var skipEnd = false
var skipUnitPlacing = false
var debugTroops = false

func _ready():
	Signals.resetGame.connect(_on_resetGame)
#	tooltips = false
#	skipScreens = true
#	skipSoulsSummary = true
#	skipWaitForPlayers = true
#	skipPhaseReminder = true


func _on_resetGame():
	menuOpen = false
