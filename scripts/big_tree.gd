extends StaticBody3D

var triggered := false

func take_damage(_amount: int) -> void:
	if triggered:
		return
	triggered = true
	if $ChopSound.stream:
		$ChopSound.play()
		get_tree().create_timer(1.0).timeout.connect(GameState.show_ending)
	else:
		GameState.show_ending()
