extends Node
class_name Player

@export var demons = []
@export var favors = 0:
	set(value):
		favors = clamp(value, 0, 20)
		Signals.changePlayerDisplayValue.emit(playerId, "favors", favors)
@export var disfavors = 0:
	set(value):
		disfavors = clamp(value, 0, 20)
		Signals.changePlayerDisplayValue.emit(playerId, "disfavors", disfavors)
@export var souls = 0:
	set(value):
		souls = clamp(value, 0, 100)
		Signals.changePlayerDisplayValue.emit(playerId, "souls", souls)
@export var income : String = "": 
	set(value):
		income = value
		print("changed income on player ", income)
		Signals.changePlayerDisplayValue.emit(playerId, "income", income)
@export var arcanaCards = []
@export var sectios : Array[String] = []
@export var troops = {}
var color : Color = Color8(255, 255, 255)
var colorName = ""
var playerName : String = ""
var playerId : int = 0
var sectiosWithoutEnemies : Array:
	set(_sectiosWithoutEnemies):
		sectiosWithoutEnemies = _sectiosWithoutEnemies
		sectiosWithoutEnemiesLeft = sectiosWithoutEnemies.duplicate()
var sectiosWithoutEnemiesLeft : Array


func _ready():
	print("new player ", name)
	playerId = str(name).to_int()

func saveGame():
	var demonNames = []
	for demonNode in demons:
		demonNames.append(Data.demons[demonNode].demonName)
	var save_dict = {"players" : {playerId : {
		"demons" : demonNames,
		"favors" : favors,
		"disfavors" : disfavors,
		"souls" : souls,
		"arcanaCards" : arcanaCards,
		"sectios" : sectios,
		"troops" : troops,
		"color" : color,
		"colorName" : colorName,
		"playerName" : playerName,
		"playerId" : playerId,
		"sectiosWithoutEnemies" : sectiosWithoutEnemies,
		"sectiosWithoutEnemiesLeft" : sectiosWithoutEnemiesLeft
	}}}
	return save_dict


func loadGame(savegame : Dictionary):
#	demons = savegame.demons
	favors = savegame.favors
	disfavors = savegame.disfavors
	souls = savegame.souls
#	arcanaCards = savegame.arcanaCards
#	sectios = savegame.sectios
#	sectiosWithoutEnemies = savegame.sectiosWithoutEnemies
#	sectiosWithoutEnemiesLeft = savegame.sectiosWithoutEnemiesLeft


func hasEnoughSouls(nessessarySouls):
	if souls >= nessessarySouls:
		return true
	else:
		return false


func hasFavor():
	if favors > disfavors and favors >= 0:
		return true
	else:
		return false


func addDemon(demonRank):
	demons.append(demonRank)


func removeDemon(demonRank):
	demons.erase(demonRank)


func addArcanaCard(arcanaCard):
	arcanaCards.append(arcanaCard)


func addSectio(sectio):
	if not sectios.has(sectio):
		sectios.append(str(sectio))


func canAffordRecruitLieutenants(cardNameToIgnore = ""):
	var arcanaCardsNames = arcanaCards
	for cardName in arcanaCardsNames:
		if is_instance_valid(Data.arcanaCardNodes[cardName]):
			if not cardName == cardNameToIgnore:
				var arcanaCard = Data.arcanaCardNodes[cardName]
				arcanaCard.disable()
				if not hasEnoughSouls(arcanaCard.cost):
					continue
				var MinorSpell = Decks.MinorSpell
				if arcanaCard.minorSpell == MinorSpell.RecruitLieutenants and arcanaCards.size() <= 5:
					arcanaCard.highlight()


func discardModeArcanaCard():
	for cardName in arcanaCards:
		Data.arcanaCardNodes[cardName].disable()
	for arcanaCard in arcanaCards:
		Data.arcanaCardNodes[arcanaCard].mode = "discard"


func checkPlayerSummoningCapabilities(previousCost = 0):
	print("check start ", souls, hasEnoughSouls(3), " prev ", previousCost)
	
	Signals.toggleRecruitLegionsButtonEnabled.emit(Data.player.hasEnoughSouls(3))
	Signals.toggleBuyArcanaCardButtonEnabled.emit(Data.player.hasEnoughSouls(5))
	
#	toogleBuyArcanaCard(Data.player.hasEnoughSouls(5 + previousCost))
	
	var arcanaCardsNames = arcanaCards
	for cardName in arcanaCardsNames:
		var arcanaCard = Data.arcanaCardNodes[cardName]
		if not hasEnoughSouls(arcanaCard.cost):
			RpcCalls.disableArcanaCard(cardName)
		else:
			if arcanaCard.minorSpell == Decks.MinorSpell.RecruitLieutenants and arcanaCards.size() <= 5:
				RpcCalls.hightlightArcanaCard(cardName)
