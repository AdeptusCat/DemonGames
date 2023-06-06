extends Control


func _ready():
	Signals.tutorial.connect(_on_tutorial)
	Signals.tutorialRead.connect(_on_tutorialRead)


func _on_tutorial(topic, text : String):
#	if pos == Vector2.ZERO:
#		set_anchors_preset(PRESET_CENTER)
#	else:
#		position = pos
	match topic:
		Tutorial.Topic.Introduction:
			%ColorRect.hide()
		
		Tutorial.Topic.Soul:
			%ColorRect.hide()
		
		Tutorial.Topic.RecruitLegion:
			%Button.hide()
			%ColorRect.hide()
		Tutorial.Topic.PlaceLegion:
			%Button.hide()
			%ColorRect.hide()
		Tutorial.Topic.PlaceLegionTwice:
			%ColorRect.hide()
		Tutorial.Topic.BuyArcanaCard:
			%ColorRect.hide()
			%Button.hide()
		Tutorial.Topic.PickArcanaCard:
			%Button.hide()
			%ColorRect.hide()
			top_level = true
		Tutorial.Topic.TooManyArcanaCards:
			%Button.hide()
			%ColorRect.hide()
		Tutorial.Topic.RecruitLieutenantCard:
			%Button.hide()
		Tutorial.Topic.PlaceLieutenant:
			%Button.hide()
			%ColorRect.hide()
		Tutorial.Topic.EndSummoningPhase:
			%Button.hide()
			%ColorRect.hide()
		
#		Tutorial.Topic.RankTrack:
#			%Button.hide()
		Tutorial.Topic.ClickDemonOnRankTrack:
			%Button.hide()
		Tutorial.Topic.DemonDetails:
			%Button.hide()
		Tutorial.Topic.PassAction:
			%ColorRect.hide()
			%Button.hide()
		Tutorial.Topic.Pass:
			%Button.hide()
		Tutorial.Topic.FleePromt:
			%Button.hide()
			%ColorRect.hide()
		Tutorial.Topic.FleeWithLieutenant:
			%Button.hide()
			%ColorRect.hide()
		Tutorial.Topic.FleeWithLegion:
			%ColorRect.hide()
		Tutorial.Topic.PickLegionsToFleeWith:
			%Button.hide()
			%ColorRect.hide()
			top_level = true
		Tutorial.Topic.FailToFlee:
			%Button.hide()
			%ColorRect.hide()
		Tutorial.Topic.WalkTheEarthAttempt:
			%ColorRect.hide()
			%Button.hide()
		Tutorial.Topic.WalkTheEarth:
			%Button.hide()
		Tutorial.Topic.DoEvilDeeds:
			%ColorRect.hide()
			%Button.hide()
		Tutorial.Topic.MarchAction:
			%ColorRect.hide()
			%Button.hide()
		Tutorial.Topic.March:
			%ColorRect.hide()
			%Button.hide()
#		Tutorial.Topic.DoEvilDeeds:
#			%ColorRect.hide()
		Tutorial.Topic.Combat:
			%ColorRect.hide()
		Tutorial.Topic.Petition:
			%ColorRect.hide()
	%Label.text = text
	show()


func _on_button_pressed():
	Signals.tutorialRead.emit()


func _on_tutorialRead():
	hide()
	top_level = false
	%Button.show()
	%ColorRect.show()
