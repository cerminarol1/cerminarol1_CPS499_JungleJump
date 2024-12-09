extends Node2D

# stuff from earlier modules, idk if i need this 
# notes did not work, added @onready to the start of those things, changed position2D to Marker2D
@onready var Items: TileMapLayer = $TML_Items
@onready var Player: Node = $Player 
@onready var SpawnPoint: Marker2D = $SpawnPoint 

func _ready() -> void: 
	Items.hide()
	Player.reset(SpawnPoint.position)
