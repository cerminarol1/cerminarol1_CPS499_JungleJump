extends Node2D

var Items: Node = $TML_Items
var Player: Node = $Player 
var SpawnPoint: Position2D = $SpawnPoint 

func _ready() -> void: 
	Items.hide()
	Player.reset(SpawnPoint.position)
