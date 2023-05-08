extends Control


func _ready():
	Signals.showSoulsSummary.connect(showSummary)


func showSummary(soulSummary : Dictionary):
	for child in %SoulSummaryVBoxContainer.get_children():
		child.queue_free()
	var labels = []
	var totalFavors = 0
	var totalSouls = 0
	for demonName in soulSummary[Data.id]["earth"]:
		var favors = soulSummary[Data.id]["earth"][demonName]["favors"]
		var souls = soulSummary[Data.id]["earth"][demonName]["souls"]
		totalFavors += favors
		totalSouls += souls
		var label = Label.new()
		label.text = "The Demon " + demonName + " gathered " + str(favors) + " Favor and " + str(souls) + " souls while on Earth."
		%SoulSummaryVBoxContainer.add_child(label)
		labels.append(label)
	
	for sectioName in soulSummary[Data.id]["hell"]:
		var souls = soulSummary[Data.id]["hell"][sectioName]["souls"]
		var isIsolated = soulSummary[Data.id]["hell"][sectioName]["isolated"]
		var enemyInSectio = soulSummary[Data.id]["hell"][sectioName]["enemyInSectio"]
		totalSouls += souls
		var label = Label.new()
		if enemyInSectio:
			label.text = "The Sectio " + sectioName + " gathered no Souls because there is an Enemy present."
		else:
			if isIsolated:
				label.text = "The Sectio " + sectioName + " gathered only " + str(souls) + " Souls because it is isolated."
				if souls <= 0:
					label.text = "The Sectio " + sectioName + " gathered no Souls because it is isolated."
			else:
				label.text = "The Sectio " + sectioName + " gathered " + str(souls) + " Souls."
				if souls <= 0:
					label.text = "The Sectio " + sectioName + " gathered no Souls."
		labels.append(label)
	
	var labelPlayerEarnings = Label.new()
	labelPlayerEarnings.text = "Your triumphirate gathered a total of " + str(totalFavors) + " Favors and " + str(totalSouls) + " Souls this Round."
	labels.push_front(labelPlayerEarnings)
	
	var labelFill = Label.new()
	labels.append(labelFill)
	
	var labelEnemy = Label.new()
	labelEnemy.text = "The Enemys earnings this Round."
	labels.append(labelEnemy)
	
	for label in labels:
		if not label.get_parent():
			%SoulSummaryVBoxContainer.add_child(label)
	
	for playerId in soulSummary:
		labels = []
		totalFavors = 0
		totalSouls = 0
		
		if playerId == Data.id:
			continue
		
		for demonName in soulSummary[playerId]["earth"]:
			var favors = soulSummary[playerId]["earth"][demonName]["favors"]
			var souls = soulSummary[playerId]["earth"][demonName]["souls"]
			totalFavors += favors
			totalSouls += souls
			var label = Label.new()
			label.text = "The Demon " + demonName + " gathered " + str(favors) + " Favor and " + str(souls) + " souls while on Earth."
			%SoulSummaryVBoxContainer.add_child(label)
			labels.append(label)
		
		for sectioName in soulSummary[playerId]["hell"]:
			var souls = soulSummary[playerId]["hell"][sectioName]["souls"]
			var isIsolated = soulSummary[playerId]["hell"][sectioName]["isolated"]
			totalSouls += souls
			var label = Label.new()
			if isIsolated:
				label.text = "The Sectio " + sectioName + " gathered only " + str(souls) + " Souls because it is isolated."
				if souls <= 0:
					label.text = "The Sectio " + sectioName + " gathered no Souls because it is isolated."
			else:
				label.text = "The Sectio " + sectioName + " gathered " + str(souls) + " Souls."
				if souls <= 0:
					label.text = "The Sectio " + sectioName + " gathered no Souls."
			labels.append(label)
		
		var labelEarnings = Label.new()
		labelEarnings.text = "The triumphirate " + str(playerId) + " gathered a total of " + str(totalFavors) + " Favors and " + str(totalSouls) + " Souls this Round."
		labels.push_front(labelEarnings)
		
		labelFill = Label.new()
		labels.append(labelFill)
		
		for label in labels:
			if not label.get_parent():
				%SoulSummaryVBoxContainer.add_child(label)


func _on_button_pressed():
	%SoulSummaryContainer.hide()


func _on_show_souls_summary_button_pressed():
	%SoulSummaryContainer.show()
