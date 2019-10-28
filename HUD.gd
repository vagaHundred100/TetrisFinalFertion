extends CanvasLayer

func _ready():
	var game = get_parent()
	show_message("Welcome to The Exsatinng Tetris Game ")
	
	
func show_message(text):
	$Timer.start()
	$Message.text = text
	$Message.show()



func _on_Timer_timeout():
	$Message.text = "New Game "
	$StartButton.show()


func game_over():
	show_message("Game Over")
	

func apdate_score(num):
	$Score.text = "Score " + str(num)
	$Score.show()
