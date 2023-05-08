extends MarginContainer


func _ready():
	Signals.phaseDescription.connect(_on_phaseDescription)


func _on_phaseDescription(phase, phaseText):
	match phase:
		Data.phases.Hell:
			pass
		Data.phases.Soul:
			%PhaseSummaryLabel.text = ""
		Data.phases.Summoning:
			%PhaseSummaryLabel.text = "Click on Sectios to buy Legions for 3 Souls.\nBuy Arcana Cards for 5 Souls.\nBuy Lieutenants by using the appropiate Arcana Card."
		Data.phases.Action:
			%PhaseSummaryLabel.text = "Use your Demons to take Actions in turn."
		Data.phases.Petitions:
			%PhaseSummaryLabel.text = "Occupy Sectios with your Legions in them by paying one Favor.\nOccupy Sectios by winning a Fight in them."
	%PhaseLabel.text = phaseText
