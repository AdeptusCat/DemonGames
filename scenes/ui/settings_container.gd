extends MarginContainer

@onready var _bus := AudioServer.get_bus_index("Master")

func _ready():
	%FullscreenCheckBox.button_pressed = Settings.fullScreen
	%PotatoPcCheckBox.button_pressed = Settings.potatoPc
	%TooltipsCheckBox.button_pressed = Settings.tooltips
	%SkipScreensCheckBox.button_pressed = Settings.skipScreens
	%SkipSoulSummaryCheckBox.button_pressed = Settings.skipSoulsSummary
	%SkipWaitForPlayersCheckBox.button_pressed = Settings.skipWaitForPlayers
	%SkipPhaseReminderCheckBox.button_pressed = Settings.skipPhaseReminder
	
	%HSlider.value = Settings.volume
	%AudioOffCheckBox.button_pressed = Settings.audioOff
	
	Signals.menu.connect(_on_menu)


func _on_menu():
	Settings.saveSettings()
	queue_free()


func _on_button_pressed():
	Settings.saveSettings()
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


func _on_potato_pc_check_box_toggled(toggled_on):
	Signals.potatoPc.emit(toggled_on)
	Settings.potatoPc = toggled_on


func _on_h_slider_value_changed(value):
	AudioServer.set_bus_volume_db(_bus, linear_to_db(value))
	Settings.volume = value


func _on_check_box_toggled(toggled_on):
	Settings.audioOff = toggled_on
	if toggled_on:
		AudioServer.set_bus_volume_db(_bus, linear_to_db(0.0))
	else:
		AudioServer.set_bus_volume_db(_bus, linear_to_db(Settings.volume))


func _on_fullscreen_check_box_toggled(toggled_on):
	Settings.changeWindowMode(toggled_on)
