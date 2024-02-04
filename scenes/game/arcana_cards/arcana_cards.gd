extends Node

#func _ready():
#	var r = 500
#	var angle = 72
#	var x = r*sin(angle) 
#	var y = r*cos(angle)
#	print("coordinates")
#	print(x)
#	print(y)

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
#				print(entry)
				if names.has(entry["Name"]):
					print("has already ", entry["Name"])
					continue
				names.append(entry["Name"])
				var cardName = entry["Name"]
				var newEntry = entry
				newEntry.erase("Name")
				cardsDict[cardName] = newEntry
	names.sort()
#	print(names)
	for cardName in names:
#		print(cardName)
		var entry = {"Name" : cardName}
		entry.merge(cardsDict[cardName])
		cardsArray.append(entry)
#	print(cardsArray)
	
	var json_string = JSON.stringify(cardsArray)
#	print(json_string)
	
	var fileToSave = FileAccess.open("res://assets/arcana_cards/arcana_cards_sorted.json", FileAccess.WRITE)
	fileToSave.store_string(json_string)


#				var new_entry = entry.duplicate()
#				new_entry.erase("name")
#				cards[entry["Name"]] = new_entry
