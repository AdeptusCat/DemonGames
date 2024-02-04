extends Node
class_name Spells

var objects : Dictionary = {}
var tooltipTexts : Dictionary = {
	Decks.MinorSpell.Pass : "The current Demon will take its action after the next Demon.",
	Decks.MinorSpell.DoublePass : "The current Demon will take its action after the next two Demons.",
	Decks.MinorSpell.TriplePass : "The current Demon will take its action after the next three Demons.",
	Decks.MinorSpell.QuadruplePass : "The current Demon will take its action after the next four Demons.",
	Decks.MinorSpell.QuinaryPass : "The current Demon will take its action after the next five Demons.",
	Decks.MinorSpell.SenaryPass : "The current Demon will take its action after the next six Demons.",
	Decks.MinorSpell.SeptenaryPass : "The current Demon will take its action after the next seven Demons.",
	Decks.MinorSpell.OctonaryPass : "The current Demon will take its action after the next eight Demons.",
	Decks.MinorSpell.NonaryPass : "The current Demon will take its action after the next nine Demons.",
	Decks.MinorSpell.WalkTheEarth : "The Demon will walk on the earth where it can collect Souls and Favors.",
	Decks.MinorSpell.WalkTheEarthSafely : "The Demon will walk on the earth, unaffected by Hell Cards, where it can collect Souls and Favors.",
	Decks.MinorSpell.RecruitLieutenants : "Recruit a Lieutenant and place it on one of your Sectios, that is not occupied by enemy units.",
}

func _init():
	objects[Decks.MinorSpell.WalkTheEarth] = WalkTheEarth.new()
	objects[Decks.MinorSpell.WalkTheEarthSafely] = WalkTheEarthSafely.new()
	objects[Decks.MinorSpell.Pass] = Pass.new()
	objects[Decks.MinorSpell.DoublePass] = DoublePass.new()
	objects[Decks.MinorSpell.TriplePass] = TriplePass.new()
	objects[Decks.MinorSpell.QuadruplePass] = QuadruplePass.new()
	objects[Decks.MinorSpell.QuinaryPass] = QuinaryPass.new()
	objects[Decks.MinorSpell.SenaryPass] = SenaryPass.new()
	objects[Decks.MinorSpell.SeptenaryPass] = SeptenaryPass.new()
	objects[Decks.MinorSpell.OctonaryPass] = OctonaryPass.new()
	objects[Decks.MinorSpell.NonaryPass] = NonaryPass.new()


class MinorSpells:
	func passTurns(demonsPassed : int, currentDemon : int):
		for peer in Connection.peers:
			RpcCalls.demonAction.rpc_id(peer, currentDemon, "Pass")
		Signals.demonDone.emit(demonsPassed)
		AudioSignals.passAction.emit()
	
	
	func walkTheEarth(currentDemon : int):
		for peer in Connection.peers:
			RpcCalls.demonAction.rpc_id(peer, currentDemon, "Walk The Earth")
		Signals.demonDone.emit(null)
		AudioSignals.walkTheEarth.emit()
		Signals.incomeChanged.emit(Data.id)
	
	func activatePassButton(button : Button):
		pass
	
	func activateWalkTheEarthButton(button : Button):
		pass
	
	func highlightPassCard(arcanaCard : ArcanaCard):
		pass
	
	func highlightWalkTheEarthCard(arcanaCard : ArcanaCard):
		pass


class Pass extends MinorSpells:
	func playCard(minorSpell : int, currentDemon : int):
		super.passTurns(Decks.PassSpells[minorSpell], currentDemon)
	func identifyCard():
		Signals.passArcanaCard.emit()
	func activatePassButton(button : Button):
		button.disabled = false
	func highlightPassCard(arcanaCard : ArcanaCard):
		arcanaCard.highlight()


class DoublePass extends MinorSpells:
	func playCard(minorSpell : int, currentDemon : int):
		super.passTurns(Decks.PassSpells[minorSpell], currentDemon)
	func identifyCard():
		Signals.passArcanaCard.emit()
	func activatePassButton(button : Button):
		button.disabled = false
	func highlightPassCard(arcanaCard : ArcanaCard):
		arcanaCard.highlight()


class TriplePass extends MinorSpells:
	func playCard(minorSpell : int, currentDemon : int):
		super.passTurns(Decks.PassSpells[minorSpell], currentDemon)
	func identifyCard():
		Signals.passArcanaCard.emit()
	func activatePassButton(button : Button):
		button.disabled = false
	func highlightPassCard(arcanaCard : ArcanaCard):
		arcanaCard.highlight()


class QuadruplePass extends MinorSpells:
	func playCard(minorSpell : int, currentDemon : int):
		super.passTurns(Decks.PassSpells[minorSpell], currentDemon)
	func identifyCard():
		Signals.passArcanaCard.emit()
	func activatePassButton(button : Button):
		button.disabled = false
	func highlightPassCard(arcanaCard : ArcanaCard):
		arcanaCard.highlight()


class QuinaryPass extends MinorSpells:
	func playCard(minorSpell : int, currentDemon : int):
		super.passTurns(Decks.PassSpells[minorSpell], currentDemon)
	func identifyCard():
		Signals.passArcanaCard.emit()
	func activatePassButton(button : Button):
		button.disabled = false
	func highlightPassCard(arcanaCard : ArcanaCard):
		arcanaCard.highlight()


class SenaryPass extends MinorSpells:
	func playCard(minorSpell : int, currentDemon : int):
		super.passTurns(Decks.PassSpells[minorSpell], currentDemon)
	func identifyCard():
		Signals.passArcanaCard.emit()
	func activatePassButton(button : Button):
		button.disabled = false
	func highlightPassCard(arcanaCard : ArcanaCard):
		arcanaCard.highlight()


class SeptenaryPass extends MinorSpells:
	func playCard(minorSpell : int, currentDemon : int):
		super.passTurns(Decks.PassSpells[minorSpell], currentDemon)
	func identifyCard():
		Signals.passArcanaCard.emit()
	func activatePassButton(button : Button):
		button.disabled = false
	func highlightPassCard(arcanaCard : ArcanaCard):
		arcanaCard.highlight()


class OctonaryPass extends MinorSpells:
	func playCard(minorSpell : int, currentDemon : int):
		super.passTurns(Decks.PassSpells[minorSpell], currentDemon)
	func identifyCard():
		Signals.passArcanaCard.emit()
	func activatePassButton(button : Button):
		button.disabled = false
	func highlightPassCard(arcanaCard : ArcanaCard):
		arcanaCard.highlight()


class NonaryPass extends MinorSpells:
	func playCard(minorSpell : int, currentDemon : int):
		super.passTurns(Decks.PassSpells[minorSpell], currentDemon)
	func identifyCard():
		Signals.passArcanaCard.emit()
	func activatePassButton(button : Button):
		button.disabled = false
	func highlightPassCard(arcanaCard : ArcanaCard):
		arcanaCard.highlight()


class WalkTheEarth extends MinorSpells:
	func playCard(minorSpell : int, currentDemon : int):
		super.walkTheEarth(currentDemon)
	func identifyCard():
		Signals.walkTheEarthArcanaCard.emit()
	func activateWalkTheEarthButton(button : Button):
		button.disabled = false
	func highlightWalkTheEarthCard(arcanaCard : ArcanaCard):
		arcanaCard.highlight()


class WalkTheEarthSafely extends MinorSpells:
	func playCard(minorSpell : int, currentDemon : int):
		super.walkTheEarth(currentDemon)
	func identifyCard():
		Signals.walkTheEarthArcanaCard.emit()
	func activateWalkTheEarthButton(button : Button):
		button.disabled = false
	func highlightWalkTheEarthCard(arcanaCard : ArcanaCard):
		arcanaCard.highlight()
