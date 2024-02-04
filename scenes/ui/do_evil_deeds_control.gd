extends MarginContainer

var playerId : int = 0
var tw1

func _ready():
	Signals.showDoEvilDeedsControl.connect(_on_showEvilDeedsControl)


func _on_showEvilDeedsControl(player_id : int):
	playerId = player_id
	if playerId == Data.id or playerId < 0:
		%DoEvilDeedsControlButton.disabled = false
	else:
		%DoEvilDeedsControlButton.disabled = true
	modulate.a = 1.0
	show()
	if tw1:
		tw1.kill()
	tw1 = get_tree().create_tween()
	tw1.set_trans(Tween.TRANS_QUAD)
	tw1.set_ease(Tween.EASE_IN)
	tw1.tween_property(self, "modulate", Color(1,1,1,0), 3.0).set_delay(0.2)
	tw1.tween_callback(hideControl)


func hideControl():
	hide()
	modulate.a = 1.0


@rpc("any_peer", "call_local")
func hideEvilDeedsControl():
	%DoEvilDeedsControl.hide()


func _on_do_evil_deeds_control_button_pressed():
	if not playerId < 0:
		Signals.demonDone.emit(null)
	for peer in Connection.peers:
		hideEvilDeedsControl.rpc_id(peer)
