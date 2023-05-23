extends Node

enum Chapter {Introduction, Soul, Summoning, Actions, Combat, Petitions}
var chapterNames : Dictionary = {
	Chapter.Introduction : "Introduction",
	Chapter.Soul : "Collecting Souls",
	Chapter.Summoning : "Summoning Units",
	Chapter.Actions : "Demon Actions",
	Chapter.Combat : "Combat and Petitions",
	Chapter.Petitions : "Petition for Sectios"
}
var chapter : Chapter
var tutorial : bool = false
var currentTopic : Topic = Topic.Phase

enum Topic {
	Introduction, PlayersTree,
	Phase, 
	Soul,
	NextDemon,
	CurrentPlayer, PlayerStatus, RecruitLegion, PlaceLegion, PlaceLegionTwice, RecruitLieutenantAttempt, RecruitLieutenantCard, PlaceLieutenant, SummonHellhound, BuyArcanaCard, PickArcanaCard, TooManyArcanaCards, EndSummoningPhase,
	RankTrack, ClickDemonOnRankTrack, DemonDetails, PassAction, Pass, WalkTheEarth, WalkTheEarthAttempt, DoEvilDeeds, DoEvilDeedsResult,
	MarchEnemy, FleePromt, PickLegionsToFleeWith, FleeWithLieutenant, FleeWithLegion, FailToFlee,
	MarchAction, March, 
	Combat,
	Petition,
}

func _ready():
	Signals.tutorial.connect(_on_tutorial)


func _on_tutorial(topic, text : String):
	currentTopic = topic


func introduction():
	Signals.tutorial.emit(Tutorial.Topic.Introduction, 
		"Demon Games is a game of power-struggle and intrigue among the Demons 
		of Hell. The players each assume the role of a group of Demons thirsty for 
		power and influence and the winner is the first player to claim control of one 
		of Hell's Circles.")
	await Signals.tutorialRead
	
	Signals.tutorial.emit(Tutorial.Topic.Introduction, 
		"The map shows Hell and its vicinity. \n
		Hell itself is divided in nine concentric Circles and is surrounded by the AnteHell. \n
		Each Circle is named after the predominant kind of sinners it cares for and is in
		turn divided into five Sectio, each named after the special kind of sinners the
		Sectio contains.")
	await Signals.tutorialRead
	
	var sectio : Sectio = Decks.sectioNodes["Megalomaniacs"]
	for peer in Connection.peers:
		RpcCalls.occupySectio.rpc_id(peer, Data.id, sectio.sectioName)
	
	for peer in Connection.peers:
		RpcCalls.moveCamera.rpc_id(peer, sectio.global_position)
	await Signals.doneMoving
	
	Signals.tutorial.emit(Tutorial.Topic.Introduction, 
		"Sectio are the sections into which each of Hell’s Circles are divided, and
		since control of these in turn leads to control of Hell’s Circles, \nthey are the
		battleground upon which the struggle for control of Hell is waged. \nEach
		Sectio has the follow ing information printed in it")
	await Signals.tutorialRead
	
	Signals.tutorial.emit(Tutorial.Topic.Introduction, 
		"The number in the circle indicates the amount of souls that the Sectio produces each Soul Phase. \n
		The color of the Sectio shows the owner.")
	await Signals.tutorialRead
	
	for peer in Connection.peers:
		RpcCalls.moveCamera.rpc_id(peer, Vector2(-1500,-1500))
	await Signals.doneMoving
	
	Signals.tutorial.emit(Tutorial.Topic.Introduction, 
		"AnteHell (“Ante” as in “before”) is the name of the wastelands surrounding
		Hell. \nLost Souls, odd incorporeal beings and a few stray Daemons populate
		it. \nOne of the few reasons to visit AnteHell is that you can find and tame the
		fearsome Hellhounds there.")
	await Signals.tutorialRead
	
	for peer in Connection.peers:
		RpcCalls.resetCamera.rpc_id(peer)
	await Signals.doneMoving
	
	Signals.tutorial.emit(Tutorial.Topic.Introduction, 
		"The five-pointed star, the Pentagram, in the centre of Hell marks the location
		of the Infernal Court. It may not be entered.")
	await Signals.tutorialRead
	
	Signals.tutorial.emit(Tutorial.Topic.PlayersTree, 
		"On the left you can observe your and other players stats. \n
		Next to the name of the players are the amount of Souls the player has. \n
		Souls are the 'currency' of the game and are used to pay for raising Legions, empowering magic and so on. \n
		The Income of souls per turn depend on Demons on Earth, occupied Sectios and the upkeep you have to pay for your Units. \n
		Players receive Favors/Disfavors when they do things that are regarded by Lucifer as particularly good/amusing or bad/tasteless.")
	await Signals.tutorialRead
	
	await get_tree().create_timer(0.1).timeout
	Signals.returnToMainMenu.emit()
	await Signals.tutorialRead


func combat(rankTrackNode):
	for playerId in Data.players:
		if playerId == Data.id:
			Signals.spawnUnit.emit("Megalomaniacs", playerId, Data.UnitType.Lieutenant, "Dabriel")
			Signals.spawnUnit.emit("Megalomaniacs", playerId, Data.UnitType.Legion)
			Signals.spawnUnit.emit("Megalomaniacs", playerId, Data.UnitType.Legion)
			Signals.spawnUnit.emit("Megalomaniacs", playerId, Data.UnitType.Legion)
			
			Signals.spawnUnit.emit("Bad People", playerId, Data.UnitType.Legion)
			Signals.spawnUnit.emit("Bad People", playerId, Data.UnitType.Legion)
			Signals.spawnUnit.emit("Bad People", playerId, Data.UnitType.Legion)
			Signals.spawnUnit.emit("Bad People", playerId, Data.UnitType.Legion)
			
		else:
			Signals.spawnUnit.emit("Megalomaniacs", playerId, Data.UnitType.Legion)
			Signals.spawnUnit.emit("Megalomaniacs", playerId, Data.UnitType.Legion)
			Signals.spawnUnit.emit("Megalomaniacs", playerId, Data.UnitType.Legion)
			Signals.spawnUnit.emit("Megalomaniacs", playerId, Data.UnitType.Legion)
			Signals.spawnUnit.emit("Megalomaniacs", playerId, Data.UnitType.Legion)
			
			Signals.spawnUnit.emit("Bad People", playerId, Data.UnitType.Lieutenant, "Shalmaneser")
			Signals.spawnUnit.emit("Bad People", playerId, Data.UnitType.Legion)
			Signals.spawnUnit.emit("Bad People", playerId, Data.UnitType.Legion)

	var nr : String
	for playerId in Data.players:
		if playerId == Data.id:
			nr = Decks.getSpecificCard("demon", "Caim") #29
			for peer in Connection.peers:
				RpcCalls.addDemon.rpc_id(peer, playerId, nr)
			nr = Decks.getSpecificCard("demon", "Beelzebub") #8
			for peer in Connection.peers:
				RpcCalls.addDemon.rpc_id(peer, playerId, nr)
			nr = Decks.getSpecificCard("demon", "Gomory") #38
			for peer in Connection.peers:
				RpcCalls.addDemon.rpc_id(peer, playerId, nr)
			for peer in Connection.peers:
				RpcCalls.demonStatusChange.rpc_id(peer, 38, "earth")
		else:
			nr = Decks.getSpecificCard("demon", "Ashtaroth") #11
			for peer in Connection.peers:
				RpcCalls.addDemon.rpc_id(peer, playerId, nr)
	for peer in Connection.peers:
		RpcCalls.updateRankTrack.rpc_id(peer, rankTrackNode.rankTrack)
	var rankTrack : Array = rankTrackNode.rankTrack.duplicate()
	Signals.collapseDemonCards.emit()

	Signals.tutorial.emit(Tutorial.Topic.Phase, "This is the Combat Phase. \nEach Sectio with Units that belong to more than two Players will fight for the ownership of the Sectio.")
	await Signals.tutorialRead
	return rankTrack
