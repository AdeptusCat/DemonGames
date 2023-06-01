extends Node


func getSectiosWithoutEnemies(sectios : Array, playerId : int) -> Array[String]:
	var sectiosWithoutEnemies : Array[String] = []
	for sectioName in sectios:
		var sectio : Sectio = Decks.sectioNodes[sectioName]
		var enemyInSectio = false
		for unitName in sectio.troops:
			if not Data.troops[unitName].triumphirate == playerId:
				enemyInSectio = true
				break
		if not enemyInSectio:
			sectiosWithoutEnemies.append(sectio.sectioName)
	return sectiosWithoutEnemies


func sectioClickable(sectioName : String):
	Decks.sectioNodes[sectioName].changeClickable(true)


func sectioUnclickable(sectioName : String):
	Decks.sectioNodes[sectioName].changeClickable(false)


func sectiosClickable(sectioNames : Array):
	for sectioName in sectioNames:
		Decks.sectioNodes[sectioName].changeClickable(true)


func sectiosUnclickable(sectioNames : Array):
	for sectioName in sectioNames:
		Decks.sectioNodes[sectioName].changeClickable(false)


func remainingSectiosClickable(sectiosNotAvailable : Array):
	for sectioName in Data.player.sectiosWithoutEnemiesLeft:
		sectiosNotAvailable.erase(sectioName)
	sectiosClickable(Data.player.sectiosWithoutEnemiesLeft)
	sectiosUnclickable(sectiosNotAvailable)


func sectiosWithoutEnemiesClickable():
	if Data.player.sectiosWithoutEnemiesLeft.size() > 0:
		Sectios.sectiosClickable(Data.player.sectiosWithoutEnemiesLeft)
	else:
		Data.player.sectiosWithoutEnemiesLeft = Data.player.sectiosWithoutEnemies.duplicate()
		Sectios.sectiosClickable(Data.player.sectiosWithoutEnemiesLeft)


func sectiosLeftClickable(sectioName : String):
	if Data.player.sectiosWithoutEnemiesLeft.size() > 1:
		Data.player.sectiosWithoutEnemiesLeft.erase(sectioName)
		sectioUnclickable(sectioName)
	else:
		Data.player.sectiosWithoutEnemiesLeft = Data.player.sectiosWithoutEnemies.duplicate()
		sectiosClickable(Data.player.sectiosWithoutEnemiesLeft)
	
	
