extends Node

enum Chapter {Introduction, Soul, Summoning, Actions, Combat}
var chapterNames : Dictionary = {
	Chapter.Introduction : "Introduction",
	Chapter.Soul : "Collecting Souls",
	Chapter.Summoning : "Summoning Units",
	Chapter.Actions : "Demon Actions",
	Chapter.Combat : "Combat and Petitions",
}
var chapter : Chapter
var tutorial : bool = false
var currentTopic : Topic = Topic.Phase

enum Topic {
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
