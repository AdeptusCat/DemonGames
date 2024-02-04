extends Node

var playerIds : Array = []
var worldStates : Dictionary = {}


func _ready():
	Signals.resetGame.connect(_on_resetGame)


func _on_resetGame():
	playerIds.clear()
	worldStates.clear()


func addWorldState(id : int):
	var worldState = WorldState.duplicate(4)
	worldStates[id] = worldState


func addAiPlayer():
	var id = randi()
	playerIds.append(id)
	return id

#func getBestStartSectio(id):
#	var bestSectio
#	var pathLength = 100
#	var bestScore = 0
#	for sectioName in Data.players[id].sectios:
#
#		for otherSectioName in Data.players[id].sectios:
#			var sectio = Decks.sectioNodes[sectioName]
#			var otherSectio = Decks.sectioNodes[otherSectioName]
#			if sectio == otherSectio:
#				continue
#			var path = Astar.astar.get_id_path(sectio.id, otherSectio.id)
#			var score = 0
#			for sectioId in path:
#				score += Astar.sectioIdsNodeDict[sectioId].souls
#
#			score /= pow(path.size(), path.size())
#			print("score ", sectio.sectioName, " to ", otherSectio.sectioName, " ", score, " pathsize ", path.size())
#			if score > bestScore:
#				pathLength = path.size()
#				bestSectio = sectio
#				bestScore = score
##			if path.size() < pathLength:
##				pathLength = path.size()
##				bestSectio = sectio
##				bestScore = score
##			elif path.size() == pathLength and score > bestScore:
##				pathLength = path.size()
##				bestSectio = sectio
##				bestScore = score
#
#	print("best sectio ", bestSectio.sectioName)
#	return bestSectio


func getBestStartSectio(id):
	var bestSectio : Sectio
	var pathLength = 100
	var bestScore = -100000
	for sectioName in Data.players[id].sectios:
		var sectio = Decks.sectioNodes[sectioName]
		var scoreTotal = 0
		for otherSectioName in Data.players[id].sectios:
			var otherSectio = Decks.sectioNodes[otherSectioName]
			if sectio == otherSectio:
				continue
			var path = Astar.astar.get_id_path(sectio.id, otherSectio.id)
			
			var score = 0
			for sectioId in path:
				score += Astar.sectioIdsNodeDict[sectioId].souls
			
			score /= pow(path.size(), path.size())
			scoreTotal += score
#			print("score ", sectio.sectioName, " to ", otherSectio.sectioName, " ", score, " pathsize ", path.size())
		if scoreTotal > bestScore:
			bestSectio = sectio
			bestScore = scoreTotal
#			if path.size() < pathLength:
#				pathLength = path.size()
#				bestSectio = sectio
#				bestScore = score
#			elif path.size() == pathLength and score > bestScore:
#				pathLength = path.size()
#				bestSectio = sectio
#				bestScore = score
				
	print("best sectio ", bestSectio.sectioName)
	return bestSectio

func getBestCircle(id):
	var bestCircle
	var bestScore : float = -10000
	var bestSectio
	for sectioName in Data.players[id].sectios:
		var sectio = Decks.sectioNodes[sectioName]
		var circle = sectio.circle
		var scoreTotal : float = 0
		for otherSectioInCircleName in Decks.sectioNodes:
			var otherSectioInCircle = Decks.sectioNodes[otherSectioInCircleName]
			if not circle == otherSectioInCircle.circle:
				continue
			
			var score : float = 0
			for otherfriendlySectioName in Data.players[id].sectios:
				var otherfriendlySectio = Decks.sectioNodes[otherfriendlySectioName]
				if sectio == otherfriendlySectio:
					continue
				var path = Astar.astar.get_id_path(sectio.id, otherfriendlySectio.id)
				
				var pathScore : float = 0
				for sectioId in path:
					pathScore += Astar.sectioIdsNodeDict[sectioId].souls
				
				pathScore /= pow(path.size(), path.size())
				score += pathScore
			
			
			if sectio == otherSectioInCircle:
				continue
				
			
#			print("score enemy ", sectio.player, " ", sectio.sectioName, " ", otherSectioInCircle.player, " ", otherSectioInCircle.sectioName)
			# no score change for neutral sectio
			if not otherSectioInCircle.player == 0:
				# friendly sectio gets bonus
				if otherSectioInCircle.player == sectio.player:
					score += 1
				# enemy sectio gets penalty
				else:
					score -= 1
			scoreTotal += score
		if scoreTotal > bestScore:
			bestScore = scoreTotal
			bestCircle = circle
			bestSectio = sectio
	print("best circle ", bestCircle, " ", bestSectio.sectioName)
	return bestCircle


#func getBestCircle(id):
#	var bestCircle
#	var bestScore : int = -10000
#	var bestSectio
#	for sectioName in Data.players[id].sectios:
#		var sectio = Decks.sectioNodes[sectioName]
#		var circle = sectio.circle
#		var score : int = 0
#		for otherSectioInCircleName in Decks.sectioNodes:
#			var otherSectioInCircle = Decks.sectioNodes[otherSectioInCircleName]
#			if not circle == otherSectioInCircle.circle:
#				continue
#
#			for otherfriendlySectioName in Data.players[id].sectios:
#				var otherfriendlySectio = Decks.sectioNodes[otherfriendlySectioName]
#				if sectio == otherfriendlySectio:
#					continue
#				var path = Astar.astar.get_id_path(sectio.id, otherfriendlySectio.id)
#				score -= 0.1 * pow(path.size(), path.size())
#
#				for sectioId in path:
#					score += Astar.sectioIdsNodeDict[sectioId].souls
#
#
#
#			if sectio == otherSectioInCircle:
#				continue
#
#
#			# no score change for neutral sectio
#			if not otherSectioInCircle.player == 0:
#				# friendly sectio gets bonus
#				if otherSectioInCircle.player == sectio.player:
#					score += 1
#				# enemy sectio gets penalty
#				else:
#					score -= 1
#		print("score ",score)
#		if score > bestScore:
#			bestScore = score
#			bestCircle = circle
#			bestSectio = sectio
#	print("best circle ", bestCircle, " ", bestSectio.sectioName)
