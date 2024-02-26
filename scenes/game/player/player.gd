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
		Signals.changePlayerDisplayValue.emit(playerId, "income", income)
@export var arcanaCards : Array = []
@export var sectios : Array[String] = []
@export var troops : Dictionary = {}
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
	Signals.deactivateArcanaCards.connect(_on_deactivateArcanaCards)
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



func changeIncome():
	var income : int = 0
	var enemyInSectio : bool = false
	var demonsOnEarth : int = 0
	var demonHearts : int = 0
	for demonRank in demons:
		demonRank = demonRank as int
		var demon : Demon = Data.demons[demonRank]
		if not demon.incapacitated:
			if demon.onEarth:
				demonsOnEarth += 1
				demonHearts += demon.hearts
	
	for sectioName in sectios:
		for unitName in Decks.sectioNodes[sectioName].troops:
			if not Data.troops[unitName].triumphirate == playerId:
				enemyInSectio = true
				break
		if not enemyInSectio:
			var sectio = Decks.sectioNodes[sectioName]
			var isIsolated = sectio.isolated()
			var soulsGathered = sectio.souls
			# check for hellhounds in sectio as well!! hellhounds  hellhounds  hellhounds  hellhounds  hellhounds  hellhounds 
			if isIsolated:
				soulsGathered -= 2
			soulsGathered = clamp(soulsGathered, 0, 100)
			income += soulsGathered

	for unitName in troops:
		var unit = Data.troops[unitName]
		if not unit.unitType == Data.UnitType.Hellhound:
			income -= 1
	
	income += demonHearts
	var incomeString = str(income + demonsOnEarth)
	if demonsOnEarth > 0:
		incomeString += " - " + str(demonsOnEarth * 6 + income)
	Signals.changeIncome.emit(playerId, incomeString)


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


func _on_deactivateArcanaCards():
	for cardName in arcanaCards:
		if Data.arcanaCardNodes.has(cardName):
			var arcanaCard = Data.arcanaCardNodes[cardName]
			arcanaCard.disable()


func checkPlayerSummoningCapabilities(previousCost = 0):
	print("check start ", souls, hasEnoughSouls(3), " prev ", previousCost)
	
	Signals.toggleRecruitLegionsButton.emit(Data.player.hasEnoughSouls(3))
	Signals.toggleBuyArcanaCardButton.emit(Data.player.hasEnoughSouls(5))
	
#	toogleBuyArcanaCard(Data.player.hasEnoughSouls(5 + previousCost))
	
	var arcanaCardsNames = arcanaCards
	for cardName in arcanaCardsNames:
		var arcanaCard = Data.arcanaCardNodes[cardName]
		if not hasEnoughSouls(arcanaCard.cost):
			RpcCalls.disableArcanaCard(cardName)
		else:
			if arcanaCard.minorSpell == Decks.MinorSpell.RecruitLieutenants and arcanaCards.size() <= 5:
				RpcCalls.hightlightArcanaCard(cardName)
