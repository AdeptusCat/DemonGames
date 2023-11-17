extends Node

var profileNames : Array = ["Abaddon", "Botis", "Kimaris", "Dantalion", "Eligos", "Focalor", "Gaap", "Haagenti", "Ipes", "Krampus", "Leraie", "Malphas", "Naberius", "Orobas", "Phenex", "Ronove", "Saleos", "Unclean Spirit", "Vassago", "Ziminiar"]
var profile : Dictionary = {}
var players : Dictionary = {}
var demons : Dictionary = {}
var arcanaCards : Dictionary = {}
var arcanaCardNodes : Dictionary = {}
var currentDemon : Demon = null
var id : int = 0
var player : Player
var troops : Dictionary = {}
var currentAiPlayer : Player
var aiPlayers : int = 0
var pickDemon : bool = false
var colorsNames : Array = ["Random", "Red", "Green", "Blue", "Violet", "Yellow" ,"Grey"]
var colors : Dictionary = {
	"Red" : Color8(140, 31, 31),
	"Green": Color8(86, 120, 48),
	"Blue": Color8(24, 46, 120),
	"Violet": Color8(62, 0, 70),
	"Yellow": Color8(210, 142, 8),
	"Grey": Color8(128,128,128),
}
var chooseDemon : bool = false

@onready var normalMaps = {
	colorsNames[0] : preload("res://assets/triumphirates/00080-1662389051_n.png"),
	colorsNames[1] : preload("res://assets/triumphirates/00839-2766685014-symbol of an tribal rune with red background_n.png"),
	colorsNames[2] : preload("res://assets/triumphirates/00892-3176970373-symbol of an tribal rune with green background_n.png"),
	colorsNames[3] : preload("res://assets/triumphirates/00785-1487385261-symbol of an tribal rune with blue background_n.png"),
	colorsNames[4] : preload("res://assets/triumphirates/00053-710634660_n.png"),
	colorsNames[5] : preload("res://assets/triumphirates/00061-2959265132_n.png"),
	colorsNames[6] : preload("res://assets/triumphirates/00000-1487385261_n.png"),
}

@onready var icons = {
	colorsNames[0] : preload("res://assets/triumphirates/00080-1662389051.png"),
	colorsNames[1] : preload("res://assets/triumphirates/00839-2766685014-symbol of an tribal rune with red background.png"),
	colorsNames[2] : preload("res://assets/triumphirates/00892-3176970373-symbol of an tribal rune with green background.png"),
	colorsNames[3] : preload("res://assets/triumphirates/00785-1487385261-symbol of an tribal rune with blue background.png"),
	colorsNames[4] : preload("res://assets/triumphirates/00053-710634660.png"),
	colorsNames[5] : preload("res://assets/triumphirates/00061-2959265132.png"),
	colorsNames[6] : preload("res://assets/triumphirates/00000-1487385261.png"),
}

@onready var icons_small = {
	colorsNames[0] : preload("res://assets/icons/00080-1662389051.png"),
	colorsNames[1] : preload("res://assets/icons/00839-2766685014-symbol of an tribal rune with red background.png"),
	colorsNames[2] : preload("res://assets/icons/00892-3176970373-symbol of an tribal rune with green background.png"),
	colorsNames[3] : preload("res://assets/icons/00785-1487385261-symbol of an tribal rune with blue background.png"),
	colorsNames[4] : preload("res://assets/icons/00053-710634660.png"),
	colorsNames[5] : preload("res://assets/icons/00061-2959265132.png"),
	colorsNames[6] : preload("res://assets/icons/00000-1487385261.png"),
}

enum UnitType {Legion, Lieutenant, Hellhound}
enum HelpSubjects {
	SwapDemonOnStart, 
	PlaceFirstLegion, 
	StartScreen, 
	SummoningPhase, 
	ActionPhase, 
	PickDemonForCombat, 
	PetitionPhase,
	
	March,
	}




#enum phases {Hell, Soul, Summoning, Action, Random, Combat, Petition, End}

enum States {IDLE, MARCHING, RECRUITING}
var state : States = States.IDLE

enum phases {Hell, Soul, Summoning, Action, Combat, Petitions, End}
var phase = null
var phasesSize : int = phases.size()


func _ready():
	Signals.resetGame.connect(_on_resetGame)


func _on_resetGame():
	players.clear()
	demons.clear()
	arcanaCards.clear()
	arcanaCardNodes.clear()
	currentDemon = null
	id = 0
	player = null
	troops.clear()
	currentAiPlayer = null
	aiPlayers = 0
	pickDemon = false


func startPhase():
	phase = 0
	return phase


func changeState(newState):
	state = newState


func nextPhase():
	phase += 1
	if phase >= phasesSize:
		phase = 0
	return phase

@rpc("any_peer", "call_local")
func returnArcanaCard(cardName, playerName):
	Decks.addCard(cardName, "arcana")
	Data.players[playerName].arcanaCards.erase(cardName)
	Data.arcanaCardNodes.erase(cardName)
	Data.arcanaCards.erase(cardName)
