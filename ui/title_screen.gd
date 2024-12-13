extends Control

func _ready() -> void:
	$TitleMusic.play()
	$TitleMusic.stream.loop = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"):
		$TitleMusic.stop()
		GameState.next_level()
