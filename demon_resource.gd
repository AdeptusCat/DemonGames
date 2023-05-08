extends Resource
class_name DemonResource

@export var name : String = ""
@export var rank : int = 2
@export var skulls : int = 6
@export var stars : int = 6
@export var hearts : int = 6
enum Sex {Male, Female, Hermaphrodite, Undefined}
@export var sex : Sex = Sex.Male
@export var player : int = 0
@export var incapacitated : bool = false
@export var onEarth : bool = false
@export var image : Texture
@export var description : String = ""
