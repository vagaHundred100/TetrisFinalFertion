extends Button


var Game

func _ready():
   Game = get_parent().get_parent()
   connect("pressed",Game,"new_game")
