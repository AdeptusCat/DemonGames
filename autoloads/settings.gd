extends Node

var menuOpen : bool = false

var debug : bool = false
#var debug : bool = true

var tooltips : bool = true
var skipScreens : bool = false
var skipSoulsSummary : bool = false
var skipWaitForPlayers : bool = false
var skipPhaseReminder : bool = false

var skipHell : bool = false
var skipSouls : bool = false
var skipSummoning : bool = false
var skipAction : bool = false
var skipCombat : bool = false
var skipPetitions : bool = false
var skipEnd : bool = false
var skipUnitPlacing : bool = false
var debugTroops : bool = false

var potatoPc : bool = false

func _ready():
	Signals.resetGame.connect(_on_resetGame)
#	tooltips = false
#	skipScreens = true
#	skipSoulsSummary = true
#	skipWaitForPlayers = true
#	skipPhaseReminder = true


func _on_resetGame():
	menuOpen = false
