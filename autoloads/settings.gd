extends Node

var menuOpen : bool = false

var debug : bool = false

var tooltips : bool = true
var skipScreens : bool = false
var skipSoulsSummary : bool = false
var skipWaitForPlayers : bool = false
var skipPhaseReminder : bool = false
var potatoPc : bool = false
var fullScreen : bool = false
var showQuickHelp : bool = true

var skipHell : bool = false
var skipSouls : bool = false
var skipSummoning : bool = false
var skipAction : bool = false
var skipCombat : bool = false
var skipPetitions : bool = false
var skipEnd : bool = false
var skipUnitPlacing : bool = false
var debugTroops : bool = false

@onready var music_volume : float = 1.0
@onready var sfx_volume : float = 1.0
@onready var voice_volume : float = 1.0

var audioOff : bool = false

func _ready():
	Signals.resetGame.connect(_on_resetGame)


func changeWindowMode(_fullscreen : bool):
	if _fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	fullScreen = _fullscreen


func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F11:
			changeWindowMode(not fullScreen)


func _on_resetGame():
	menuOpen = false


func saveSettings():
	Data.settings.tooltips = Settings.tooltips
	Data.settings.skipScreens = Settings.skipScreens
	Data.settings.skipSoulsSummary = Settings.skipSoulsSummary
	Data.settings.skipWaitForPlayers = Settings.skipWaitForPlayers
	Data.settings.skipPhaseReminder = Settings.skipPhaseReminder
	Data.settings.potatoPc = Settings.potatoPc
	Data.settings.music_volume = Settings.music_volume
	Data.settings.sfx_volume = Settings.sfx_volume
	Data.settings.voice_volume = Settings.voice_volume
	Data.settings.audioOff = Settings.audioOff
	Data.settings.fullScreen = Settings.fullScreen
	Data.settings.showQuickHelp = Settings.showQuickHelp
	Save.saveSettings(Data.settings)


func loadSettings():
	if Data.settings.has("tooltips"):
		tooltips = Data.settings.tooltips
	if Data.settings.has("skipScreens"):
		skipScreens = Data.settings.skipScreens
	if Data.settings.has("skipSoulsSummary"):
		skipSoulsSummary = Data.settings.skipSoulsSummary
	if Data.settings.has("skipWaitForPlayers"):
		skipWaitForPlayers = Data.settings.skipWaitForPlayers
	if Data.settings.has("skipPhaseReminder"):
		skipPhaseReminder = Data.settings.skipPhaseReminder
	if Data.settings.has("potatoPc"):
		potatoPc = Data.settings.potatoPc
		Signals.potatoPc.emit(potatoPc)
	if Data.settings.has("fullScreen"):
		fullScreen = Data.settings.fullScreen
		changeWindowMode(fullScreen)
	if Data.settings.has("showQuickHelp"):
		showQuickHelp = Data.settings.showQuickHelp
	if Data.settings.has("sfx_volume"):
		sfx_volume = Data.settings.sfx_volume
	if Data.settings.has("music_volume"):
		music_volume = Data.settings.music_volume
	if Data.settings.has("voice_volume"):
		voice_volume = Data.settings.voice_volume
