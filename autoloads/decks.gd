extends Node



var sectioCards : Array = []
var sectioNodes : Dictionary = {}
enum Circles {Treachery, Fraud, TheViolent, Heretics, TheWrathful, TheGreedy, TheGluttonous, TheLustful, Limbo, Anthell}
var sectios = {Circles.Treachery : {}, Circles.Fraud : {}, Circles.TheViolent : {}, Circles.Heretics : {}, Circles.TheWrathful : {}, Circles.TheGreedy : {}, Circles.TheGluttonous : {}, Circles.TheLustful : {}, Circles.Limbo : {}, Circles.Anthell : {}}
var arcanaCards = []
var arcanaCardsReference = {}
var hellCards = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
var demonCards = []
var lieutenants = []
var lieutenantsReference = {}
var availableLieutenants = []
# Called when the node enters the scene tree for the first time.

var cardsNotToLoad : Array = []

enum MinorSpell {WalkTheEarth, RecruitLieutenants, NonaryPass, Pass, DoublePass, TriplePass, QuadruplePass, QuinaryPass, SenaryPass, SeptenaryPass, OctonaryPass, PlayRightAway, WalkTheEarthSafely}

func _ready():
	Signals.resetGame.connect(_on_resetGame)
#	for nr in range(2,9):
#		demonCards.append(nr)
#	for nr in range(1,14):
#		arcanaCards.append(nr)
	loadCards()


func loadCards():
	demonCards = readFilenames("demons")
	demonCards.shuffle()
	
	arcanaCardsReference = loadArcanaCardReferences()
	arcanaCards = loadArcanaCardNames()
	arcanaCards.shuffle()

	sectioCards.shuffle()
	
	hellCards.shuffle()
	
	lieutenants = loadLieutenantNames()
	lieutenantsReference = loadLieutenantReferences()


func _on_resetGame():
	demonCards.clear()
	arcanaCardsReference.clear()
	arcanaCards.clear()
	sectioCards.clear()
	hellCards.clear()
	lieutenants.clear()
	lieutenantsReference.clear()
	loadCards()

func loadLieutenantNames():
	var file = FileAccess.open("res://lieutenants.json", FileAccess.READ)
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	var data = json.data
	var cardNames = []
	
	for sheet in data["sheets"]:
		if sheet["name"] == "Lieutenants":
			for entry in sheet["lines"]:
				cardNames.append(entry["Name"])
	cardNames.shuffle()
	return cardNames

func loadLieutenantReferences():
	var file = FileAccess.open("res://lieutenants.json", FileAccess.READ)
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	var data = json.data
	var cardsDict = {}
	
	for sheet in data["sheets"]:
		if sheet["name"] == "Lieutenants":
			for entry in sheet["lines"]:
				var cardName = entry["Name"]
				var newEntry = {}
				newEntry["combat bonus"] = entry["Combat Bonus"]
				newEntry["capacity"] = entry["Capacity"]
				newEntry["texture"] = str("res://" + entry["Texture"]["file"])
				cardsDict[cardName] = newEntry
	return cardsDict



func loadArcanaCardNames():
	var file = FileAccess.open("res://arcana_cards/arcana_cards.json", FileAccess.READ)
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	var data = json.data
	var cardNames = []
	
	for sheet in data["sheets"]:
		if sheet["name"] == "ArcanaCards":
			for entry in sheet["lines"]:
				for card in entry["inPlay"]:
					if not cardsNotToLoad.has(entry["name"]):
						# cards exist twice
						# add a space to the second name to make it unique
						if cardNames.has(entry["name"]):
							cardNames.append(entry["name"] + " ")
						else:
							cardNames.append(entry["name"])
	return cardNames

func loadArcanaCardReferences():
	var file = FileAccess.open("res://arcana_cards/arcana_cards.json", FileAccess.READ)
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	var data = json.data
	var cardNames = []
	var cardsDict = {}
	
	for sheet in data["sheets"]:
		if sheet["name"] == "ArcanaCards":
			for entry in sheet["lines"]:
				cardNames.append(entry["name"])
				var cardName = entry["name"]
				if entry.minorSpell == MinorSpell.PlayRightAway:
					cardsNotToLoad.append(cardName)
				var newEntry = entry
				newEntry.erase("name")
				cardsDict[cardName] = newEntry
	return cardsDict

func readFilenames(dirName):
	var fileNames = []
	var dir = DirAccess.open("res://" + dirName)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
#				print("Found directory: " + file_name)
				pass
			else:
#				print("Found file: " + file_name)
				file_name = file_name.trim_suffix('.remap')
				fileNames.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return fileNames

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

@rpc("any_peer", "call_local")
func addCard(cardName, deckName : String):
	match deckName:
		"sectio" : 
			sectioCards.push_front(cardName)
		"arcana" : 
			arcanaCards.push_front(cardName)
		"hell" : 
			hellCards.push_front(cardName)
		"demon" : 
			demonCards.push_front(cardName)
		"lieutenant" :
			lieutenants.push_front(cardName)
			lieutenants.shuffle()
			print("resurrect ",cardName)


func getSpecificCard(deckName : String, cardName : String):
	match deckName:
		"sectio" : 
			return sectioCards.pop_at(sectioCards.find(cardName))
		"arcana" : 
			return arcanaCards.pop_at(arcanaCards.find(cardName))
		"hell" : 
			return hellCards.pop_at(hellCards.find(cardName))
		"demon" :
			if not cardName.contains(".tres"):
				cardName += ".tres"
			return demonCards.pop_at(demonCards.find(cardName))
		"lieutenant" :
			return lieutenants.pop_at(lieutenants.find(cardName))


func getRandomCard(deckName : String):
	match deckName:
		"sectio" : 
			return sectioCards.pop_back()
		"arcana" : 
			return arcanaCards.pop_back()
		"hell" : 
			return hellCards.pop_back()
		"demon" : 
			return demonCards.pop_back()
		"lieutenant" :
			return lieutenants.pop_back()

