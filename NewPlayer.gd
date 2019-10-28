extends Node2D


const WIDTH = 10
const HIGHT = 20

const DOWN = Vector2(0,1)
const LEFT = Vector2(-1,0)
const RIGHT = Vector2(1,0)

var board 

var Score = 0
signal finish
signal cleaned


const CELL_SIZE = 32

var S =[ 0,0,0,0,
		 0,1,1,0,
		 1,1,0,0,
		 0,0,0,0]

var T = [0,0,0,0,
         0,1,1,1,
		 0,0,1,0,
		 0,0,0,0]

var J = [0,0,0,0,
		 0,0,1,0,
		 1,1,1,0,
		 0,0,0,0]

var L = [0,0,0,0,
		 1,0,0,0,
		 1,1,1,0,
		 0,0,0,0]

var I = [0,0,0,0,
		 1,1,1,1,
		 0,0,0,0,
		 0,0,0,0]

var Z = [0,0,0,0,
		 1,1,0,0,
		 0,1,1,0,
		 0,0,0,0]

var O = [0,0,0,0,
		 0,1,1,0,
		 0,1,1,0,
		 0,0,0,0]
 
		
var tetraminos_types = [S,T,J,L,I,Z,O]
var tetramino_type
var Tetra_cell = load("res://ColorRect.tscn")
var player = Vector2()
var player_cells = []


func _ready():
	var Game = get_parent()
	connect("finish",Game,"game_over")
	connect("cleaned",Game,"apdate_score")
	create_new_world()
	create_new_player()


func _input(event):
	if event.is_action("LEFT"):
		if movable(LEFT):
			move_horizontaly(LEFT)
	elif event.is_action("RIGHT"):
		if movable(RIGHT):
			move_horizontaly(RIGHT)
	elif event.is_action("UP"):
		rotational_movement()
	elif event.is_action("DOWN"):
		if movable(DOWN):
			move_horizontaly(DOWN)


func _process(delta):
	if movable(DOWN):
		move_verticaly()
	else : nail_player()


func chouse_tetramino():
	var varaible = randi() % tetraminos_types.size()
	return tetraminos_types[varaible]


func chouse_colour():
	var randR = randf() 
	var randG = randf()
	var randB = randf()
	var randA = 1
	return Color(randR,randG,randB,randA)


func apdate_tetra_cells(player_cells):
	var counter = 0
	for i in range(4):
		for j in range(4):
			if tetramino_type[4*j +i] == 1:
				player_cells[counter].rect_position = Vector2(player.x + i,player.y + j) * CELL_SIZE
				counter +=1


func create_new_player():
	randomize()
	tetramino_type = chouse_tetramino()
	var color = chouse_colour()
	player = Vector2(WIDTH/2 - 2,0)
	player_cells = []
	for i in range(4):
		var cell = Tetra_cell.instance()
		cell.color = color
		add_child(cell)
		player_cells.append(cell)
	apdate_tetra_cells(player_cells)


func create_new_world():
	for cell in get_children():
		cell.queue_free()
	board = {}

	for j in range(HIGHT):
		for i in range(WIDTH):
			board [Vector2(i,j)] = null


func get_player_cell_pos():
	var array = []
	for i in range(4):
		for j in range(4):
			if tetramino_type[i+4*j] == 1:
				array.append(Vector2(player.x + i,player.y + j))
	return array


func movable(dir):
	for block in get_player_cell_pos():
		var next_pos = block + dir
		if  border_check(next_pos.x):
			return false
		if bottom_check(next_pos.y):
			return false
		if is_cell_ocupaide(next_pos):
			return false
	return true


func is_cell_ocupaide(next):
	if board[next] != null:
		return true


func bottom_check(block_line_num):
	if block_line_num >= HIGHT:
		return true


func border_check(block_row_num):
	if block_row_num < 0 or block_row_num >= WIDTH:
		return true


func move(dir):
	player += dir
	apdate_tetra_cells(player_cells)


func move_horizontaly(dir):
	set_process_input(false)
	move(dir)
	yield(get_tree().create_timer(0.1),"timeout")
	set_process_input(true)


func move_verticaly():
	set_process(false)
	move(DOWN)
	yield(get_tree().create_timer(0.5),"timeout")
	set_process(true)


func rotate_player():
	var b = Array()
	for i in [3,2,1,0]:
		b.append(tetramino_type[i])
		b.append(tetramino_type[i+4])
		b.append(tetramino_type[i+8])
		b.append(tetramino_type[i+12])
	return b


func rotational_movement():
	var copy = tetramino_type
	set_process_input(false)
	tetramino_type = rotate_player()
	if !movable(Vector2(0,0)):
		tetramino_type = copy
	yield(get_tree().create_timer(0.2),"timeout")
	apdate_tetra_cells(player_cells)	
	set_process_input(true)


func nail_player():
	var index = 0
	for block in get_player_cell_pos():
		board[block] = player_cells[index]
		index +=1
	cheaking_for_bingo()	
	create_new_player()


func cheaking_for_bingo():
	var Yarray = []
	for block in get_player_cell_pos():
		var y = block.y
		var counter = 0
		for x in range(WIDTH):
			if board[Vector2(x,y)] == null:
				break
			counter +=1
		if counter == 10:
			Yarray.erase(y)
			Yarray.append(y)
	if Yarray.size() != 0:
		match Yarray.size():
			1: Score += 80
			2: Score += 200
			3: Score += 600
			4: Score +=2400
		emit_signal("cleaned")
		clean_lines(Yarray)
	cheaking_for_game_over()


func cheaking_for_game_over():
	if player.y == 0:
		emit_signal("finish")


func clean_lines(Yarray):
	Yarray.sort()
	for y in Yarray:
		for x in range(WIDTH):
			board[Vector2(x,y)].queue_free()
		for index in range(y,0,-1):
			for x in range(WIDTH):
				board[Vector2(x,index)] = board[Vector2(x,index-1)]
				if board[Vector2(x,index)] != null:
					board[Vector2(x,index)].rect_position = Vector2(x,index) * CELL_SIZE


	

