extends Node2D

var Player = load("res://NewPlayer.tscn")
var player

func new_game():
	$HUD.apdate_score(0)
	$HUD/StartButton.hide()
	$HUD/Message.hide()
	player = Player.instance()
	add_child(player)


func game_over():
	$HUD.game_over()
	get_child(1).queue_free()


func apdate_score():
	var score = player.Score
	$HUD.apdate_score(score)


