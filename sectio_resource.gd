extends Resource

@export var name : String = "Spies"
enum Circles {Treachery, Fraud, TheViolent}
@export var circles : Circles = Circles.Treachery
@export_enum("One", "Two", "Three", "Four", "Five") var quarters: int
@export var souls : int = 2
@export var player : int = 0
