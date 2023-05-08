extends MarginContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	%TooltipsCheckBox.button_pressed = Settings.tooltips
	%SkipScreensCheckBox.button_pressed = Settings.skipScreens
	%SkipSoulSummaryCheckBox.button_pressed = Settings.skipSoulsSummary
	%SkipWaitForPlayersCheckBox.button_pressed = Settings.skipWaitForPlayers
	%SkipPhaseReminderCheckBox.button_pressed = Settings.skipPhaseReminder
	Signals.menu.connect(_on_menu)


func _on_menu():
	queue_free()


func _on_button_pressed():
	queue_free()


func _on_tooltips_check_box_toggled(button_pressed):
	Settings.tooltips = button_pressed


func _on_skip_screens_check_box_toggled(button_pressed):
	Settings.skipScreens = button_pressed


func _on_skip_soul_summary_check_box_toggled(button_pressed):
	Settings.skipSoulsSummary = button_pressed


func _on_skip_wait_for_players_check_box_toggled(button_pressed):
	Settings.skipWaitForPlayers = button_pressed


func _on_skip_phase_reminder_check_box_toggled(button_pressed):
	Settings.skipPhaseReminder = button_pressed
