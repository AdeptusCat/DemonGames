extends Node


func sectioClickable(sectioName : String):
	Decks.sectioNodes[sectioName].changeClickable(true)


func sectioUnlickable(sectioName : String):
	Decks.sectioNodes[sectioName].changeClickable(false)


func sectiosClickable(sectioNames : Array):
	for sectioName in sectioNames:
		Decks.sectioNodes[sectioName].changeClickable(true)


func sectiosUnlickable(sectioNames : Array):
	for sectioName in sectioNames:
		Decks.sectioNodes[sectioName].changeClickable(false)


func remainingSectiosClickable(sectiosNotAvailable : Array):
	for sectioName in Data.player.sectiosWithoutEnemiesLeft:
		sectiosNotAvailable.erase(sectioName)
	sectiosClickable(Data.player.sectiosWithoutEnemiesLeft)
	sectiosUnlickable(sectiosNotAvailable)


func sectiosWithoutEnemiesClickable():
	if Data.player.sectiosWithoutEnemiesLeft.size() > 0:
		Sectios.sectiosClickable(Data.player.sectiosWithoutEnemiesLeft)
	else:
		Data.player.sectiosWithoutEnemiesLeft = Data.player.sectiosWithoutEnemies.duplicate()
		Sectios.sectiosClickable(Data.player.sectiosWithoutEnemiesLeft)


func sectiosLeftClickable(sectioName : String):
	var sectiosWithoutEnemiesLeft : Array = Data.player.sectiosWithoutEnemiesLeft
	if sectiosWithoutEnemiesLeft.size() > 1:
		sectiosWithoutEnemiesLeft.erase(sectioName)
		sectioClickable(sectioName)
	else:
		sectiosWithoutEnemiesLeft = Data.player.sectiosWithoutEnemies.duplicate()
		sectiosUnlickable(Data.player.sectiosWithoutEnemiesLeft)
	
	
