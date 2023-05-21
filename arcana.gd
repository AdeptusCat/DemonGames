extends MarginContainer
class_name ArcanaCard

@export var stats : Resource
var mode = "":
	set(_mode):
		mode = _mode
		match mode:
			"":
				%TextureRect.get_material().set_shader_parameter("active", false)
				
			_:
				%TextureRect.get_material().set_shader_parameter("active", true)
				

#signal minorSpellSignal(node)
#signal arcanaClicked(node)

@export var cardName : String = "Sacred Music"
@export var minorSpell : int = 0
@export var cost : int = 1
@export var player : int = 1

var tw1
var tw2

func _ready():
	%MinorSpellButton.pivot_offset = %MinorSpellButton.size / 2


@rpc("any_peer", "call_local")
func highlight():
	%TextureRect.get_material().set_shader_parameter("active", true)
	%MinorSpellButton.mouse_filter = MOUSE_FILTER_PASS
	%MinorSpellButton.disabled = false
	if tw2:
		tw2.kill()
	if tw1:
		tw1.kill()
#	tw1 = create_tween()
#	tw1.set_loops(10)
#	tw1.set_trans(Tween.TRANS_CUBIC)
#	tw1.set_ease(Tween.EASE_IN)
#	tw1.tween_property(%MinorSpellButton, "modulate", Color8(255,200,200), 1.0)
#	tw1.tween_interval(0.01)
#	tw1.set_trans(Tween.TRANS_SINE)
#	tw1.set_ease(Tween.EASE_OUT)
#	tw1.tween_property(%MinorSpellButton, "modulate", Color8(255,255,255), 1.5)

	tw2 = create_tween()
	tw2.set_loops(10)
	tw2.set_trans(Tween.TRANS_CUBIC)
	tw2.set_ease(Tween.EASE_IN)
	tw2.tween_property(%MinorSpellButton, "scale", Vector2(1.0, 1.1), 1.0)
	tw2.tween_interval(0.01)
	tw2.set_trans(Tween.TRANS_SINE)
	tw2.set_ease(Tween.EASE_OUT)
	tw2.tween_property(%MinorSpellButton, "scale", Vector2(1.0, 1.0), 1.5)

func disable():
	if mode == "":
		%TextureRect.get_material().set_shader_parameter("active", false)
	# so you can still press the button to discard the card
	# otherwise the disabled button blocks the mouse signal which is confusing
	%MinorSpellButton.mouse_filter = MOUSE_FILTER_IGNORE
	%MinorSpellButton.disabled = true
	if tw1:
		tw1.kill()
	if tw2:
		tw2.kill()
		var tween1 = get_tree().create_tween()
		tween1.set_trans(Tween.TRANS_CUBIC)
		tween1.set_ease(Tween.EASE_IN)
#			tween1.tween_property(playerPolygon, "scale", Vector2(1.0, 1.0), 1.0)
		tween1.tween_property(%MinorSpellButton, "modulate", Color8(255,255,255), 1.5)
#		tween1.play()




func loadStats(_cardName):
	var card = Decks.arcanaCardsReference[_cardName.strip_edges(false, true)]
	cardName = _cardName
	minorSpell = card["minorSpell"]
	cost = card["cost"]
#	print(cardName)
	$MarginContainer/VBoxContainer/Label.text = cardName
	%MinorSpellButton.text = Decks.MinorSpell.keys()[minorSpell]
	$MarginContainer/VBoxContainer/HBoxContainer/CostLabel.text = str(cost)
	var text : String = ""
	match minorSpell:
		Decks.MinorSpell.Pass:
			text = "The current Demon will take its action after the next Demon."
		Decks.MinorSpell.DoublePass:
			text = "The current Demon will take its action after the next two Demons."
		Decks.MinorSpell.TriplePass:
			text = "The current Demon will take its action after the next three Demons."
		Decks.MinorSpell.QuadruplePass:
			text = "The current Demon will take its action after the next four Demons."
		Decks.MinorSpell.QuinaryPass:
			text = "The current Demon will take its action after the next five Demons."
		Decks.MinorSpell.SenaryPass:
			text = "The current Demon will take its action after the next six Demons."
		Decks.MinorSpell.SeptenaryPass:
			text = "The current Demon will take its action after the next seven Demons."
		Decks.MinorSpell.OctonaryPass:
			text = "The current Demon will take its action after the next eight Demons."
		Decks.MinorSpell.NonaryPass:
			text = "The current Demon will take its action after the next nine Demons."
		Decks.MinorSpell.WalkTheEarth:
			text = "The Demon will walk on the earth where it can collect Souls and Favors."
		Decks.MinorSpell.WalkTheEarthSafely:
			text = "The Demon will walk on the earth, unaffected by Hell Cards, where it can collect Souls and Favors."
		Decks.MinorSpell.RecruitLieutenants:
			text = "Recruit a Lieutenant and place it on one of your Sectios, that is not occupied by enemy units."
	%MinorSpellButton.tooltip_text = text
	

func _on_minor_spell_button_pressed():
	var souls = Data.players[player].souls - cost
	Signals.changeSouls.emit(player, souls)
	Data.returnArcanaCard.rpc_id(Connection.host, cardName, player)
	Decks.addCard(cardName, "arcana")
	Data.players[player].arcanaCards.erase(cardName)
	Data.arcanaCards.erase(cardName)
	Data.arcanaCardNodes.erase(cardName)
	Signals.minorSpell.emit(self)
	queue_free()


func _on_gui_input(event):
	if Input.is_action_just_pressed("click"):
		print("clicked arcana ",cardName)
		Signals.arcanaClicked.emit(self, mode)
