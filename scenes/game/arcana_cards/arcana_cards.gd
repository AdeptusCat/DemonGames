extends Node


func sortArcanaCardsByName():
	var file = FileAccess.open("res://assets/arcana_cards/arcana_cards.json", FileAccess.READ)
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	var data = json.data
	var cardsDict = {}
	var cardsArray = []
	var names = []
	
	
	for sheet in data["sheets"]:
		if sheet["name"] == "ArcanaCards":
			for entry in sheet["lines"]:
				if names.has(entry["Name"]):
					print("has already ", entry["Name"])
					continue
				names.append(entry["Name"])
				var cardName = entry["Name"]
				var newEntry = entry
				newEntry.erase("Name")
				cardsDict[cardName] = newEntry
	names.sort()
	for cardName in names:
		var entry = {"Name" : cardName}
		entry.merge(cardsDict[cardName])
		cardsArray.append(entry)
	
	var json_string = JSON.stringify(cardsArray)
	
	var fileToSave = FileAccess.open("res://assets/arcana_cards/arcana_cards_sorted.json", FileAccess.WRITE)
	fileToSave.store_string(json_string)

