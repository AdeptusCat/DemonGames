extends MarginContainer


var playerName : String = "PlayerName"


func _ready():
	%PlayerDisconnectedLabel.text = "Player " + playerName + " left the Game. \nNote that this Game saves after every Phase. \n You can create a new Room in the Lobby and load the Savegame."


func _on_player_disconnected_button_pressed():
	queue_free()
