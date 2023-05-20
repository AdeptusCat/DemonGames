extends Node


func _ready():
	Signals.minorSpell.connect(_on_MinorSpell)


func _on_MinorSpell(arcanaCard : ArcanaCard):
	Signals.sectioClicked.emit(null)
	for cardName in Data.player.arcanaCards:
		Data.arcanaCardNodes[cardName].disable()
	var MinorSpell = Decks.MinorSpell
	if arcanaCard.minorSpell == MinorSpell.Pass:
		Signals.actionThroughArcana.emit(arcanaCard.minorSpell)
		if Tutorial.currentTopic == Tutorial.Topic.Pass:
			Signals.tutorialRead.emit()
	if arcanaCard.minorSpell == MinorSpell.DoublePass:
		Signals.actionThroughArcana.emit(arcanaCard.minorSpell)
		if Tutorial.currentTopic == Tutorial.Topic.Pass:
			Signals.tutorialRead.emit()
	if arcanaCard.minorSpell == MinorSpell.TriplePass:
		Signals.actionThroughArcana.emit(arcanaCard.minorSpell)
		if Tutorial.currentTopic == Tutorial.Topic.Pass:
			Signals.tutorialRead.emit()
	if arcanaCard.minorSpell == MinorSpell.QuadruplePass:
		Signals.actionThroughArcana.emit(arcanaCard.minorSpell)
		if Tutorial.currentTopic == Tutorial.Topic.Pass:
			Signals.tutorialRead.emit()
	if arcanaCard.minorSpell == MinorSpell.QuinaryPass:
		Signals.actionThroughArcana.emit(arcanaCard.minorSpell)
		if Tutorial.currentTopic == Tutorial.Topic.Pass:
			Signals.tutorialRead.emit()
	if arcanaCard.minorSpell == MinorSpell.SenaryPass:
		Signals.actionThroughArcana.emit(arcanaCard.minorSpell)
		if Tutorial.currentTopic == Tutorial.Topic.Pass:
			Signals.tutorialRead.emit()
	if arcanaCard.minorSpell == MinorSpell.SeptenaryPass:
		Signals.actionThroughArcana.emit(arcanaCard.minorSpell)
		if Tutorial.currentTopic == Tutorial.Topic.Pass:
			Signals.tutorialRead.emit()
	if arcanaCard.minorSpell == MinorSpell.OctonaryPass:
		Signals.actionThroughArcana.emit(arcanaCard.minorSpell)
		if Tutorial.currentTopic == Tutorial.Topic.Pass:
			Signals.tutorialRead.emit()
	if arcanaCard.minorSpell == MinorSpell.NonaryPass:
		Signals.actionThroughArcana.emit(arcanaCard.minorSpell)
		if Tutorial.currentTopic == Tutorial.Topic.Pass:
			Signals.tutorialRead.emit()
	
	if arcanaCard.minorSpell == MinorSpell.WalkTheEarth or arcanaCard.minorSpell == MinorSpell.WalkTheEarthSafely:
		if Tutorial.currentTopic == Tutorial.Topic.WalkTheEarth:
			Signals.tutorialRead.emit()
		for peer in Connection.peers:
			RpcCalls.demonStatusChange.rpc_id(peer, Data.currentDemon.rank, "earth")
		Signals.actionThroughArcana.emit(arcanaCard.minorSpell)
	if arcanaCard.minorSpell == MinorSpell.RecruitLieutenants:
		if Tutorial.tutorial:
			Signals.tutorialRead.emit()
#		actionsNode._recruitLieutenant()
		var lieutenantName = Decks.availableLieutenants.pop_back()
		
		Signals.showChosenLieutenantFromAvailableLieutenantsBox.emit(lieutenantName)
		
		Signals.recruitLieutenant.emit(lieutenantName)

	for peer in Connection.peers:
		RpcCalls.discardArcanaCard.rpc_id(peer, arcanaCard.cardName, Data.id)
	AudioSignals.castArcana.emit()
