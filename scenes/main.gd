extends Node

@export var snakeScene : PackedScene

#game var
var score : int
var gameStarted : bool = false

#grid var
var cellsNumber : int = 20
var cellSize : int = 50

#snake var
var oldData : Array
var snakeData : Array
var snake : Array

#movement var
var startingPosition = Vector2(9,9)

#food var
var foodPosition : Vector2
var recoverFood : bool = true

#var directions
var up = Vector2(0,-1)
var down = Vector2(0,1)
var left = Vector2(-1,0)
var right = Vector2(1,0)
var moveDirection : Vector2
var moveAvailable : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()
	
func new_game():
	get_tree().paused = false
	get_tree().call_group("segments", "queue_free")
	$GameOver.hide()
	score = 0
	$HUD.get_node("ScoreLabel").text = "Score: " + str(score)
	moveDirection = up
	moveAvailable = true
	generate_snake()
	move_food()
	
func generate_snake():
	oldData.clear()
	snakeData.clear()
	snake.clear()
	
	for i in range(3):
		add_segment(startingPosition + Vector2(0, i))
		
func add_segment(pos):
	snakeData.append(pos)
	var snakeSegment = snakeScene.instantiate()
	snakeSegment.position = (pos * cellSize) + Vector2(0, cellSize)
	add_child(snakeSegment)
	snake.append(snakeSegment)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_snake()
	
func move_snake():
	if moveAvailable:
		if Input.is_action_just_pressed("move_down") and moveDirection != up:
			moveDirection = down
			moveAvailable = false
			if not gameStarted:
				start_game()
		if Input.is_action_just_pressed("move_up") and moveDirection != down:
			moveDirection = up
			moveAvailable = false
			if not gameStarted:
				start_game()
		if Input.is_action_just_pressed("move_left") and moveDirection != right:
			moveDirection = left
			moveAvailable = false
			if not gameStarted:
				start_game()
		if Input.is_action_just_pressed("move_right") and moveDirection != left:
			moveDirection = right
			moveAvailable = false
			if not gameStarted:
				start_game()
	

func start_game():
	gameStarted = true
	$Timer.start()


func _on_timer_timeout():
	moveAvailable = true
	oldData = [] + snakeData
	snakeData[0] += moveDirection
	for i in range(len(snakeData)):
		if i > 0:
			snakeData[i] = oldData[i - 1]
		snake[i].position = (snakeData[i] * cellSize) + Vector2(0, cellSize)
	outOfBoundsCheck()
	selfEatenCheck()
	foodEatenCheck()
	
func outOfBoundsCheck():
	if snakeData[0].x < 0 or snakeData[0].x > cellsNumber -1 or snakeData[0].y < 0 or snakeData[0].y > cellsNumber -1:
		end_game()
		
func selfEatenCheck():
	for i in range(1, len(snakeData)):
		if snakeData[0] == snakeData[i]:
			end_game()
			
func foodEatenCheck():
	if snakeData[0] == foodPosition:
		score += 1
		$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score)
		add_segment(oldData[-1])
		move_food()
	
func move_food():
	while recoverFood:
		recoverFood = false
		foodPosition = Vector2(randi_range(0, cellsNumber - 1), randi_range(0, cellsNumber - 1))
		for i in snakeData:
			if foodPosition == i:
				recoverFood = true
	$Food.position = (foodPosition * cellSize)+ Vector2(0, cellSize)
	recoverFood = true
			
func end_game():
	$GameOver.show()
	$Timer.stop()
	gameStarted = false
	get_tree().paused = true


func _on_game_over_restart():
	new_game()
