extends Node

# signals
signal update_score
signal update_lives
signal game_over_signal
signal level_finished

# player state
var score : int = 0
var lives : int = 3
# TODO adjust this based on the player and ball height
const PLAYER_Y : int = 575

# ball state
var speed_multiplier : float = 1.0

# game state
var game_over : bool = false

# preload the ball scene so that we can instantiate balls
var ball_scene = preload("res://Scenes/ball.tscn")

# handle levels
var current_scene = null
var levels = [	"res://Scenes/level_0.tscn"
				,"res://Scenes/level_1.tscn"
				,"res://Scenes/level_2.tscn"
				#,"res://Scenes/level_1.tscn"
				]
# We need an array to load the scenes into
var level_scenes = []
var max_level : int = levels.size() - 1
# set this to zero so our default scene is always level 0
var current_level : int = 0

# Called when the node enters the scene tree for the first time.
# Called when the node enters the scene tree for the first time.
func _ready():
	# let's load the scenes
	for i in range (levels.size()):
		level_scenes.append(load(levels[i]))
		
	# All this does is set up the current scene in our case that
	# will be level 0
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func reset_defaults():
	score = 0
	lives = 3
	current_level = 0
	game_over = false
	
# This is called by the FinishFlag when it's entered
func next_level():
	# Update the current level
	current_level += 1

	# DBG
	# print(current_level)
	# TODO Check for the end etc etc
	if current_level > max_level:
		do_game_over()
	else:
		# Then because the current scene may still be doing something
		# defer the call until that is all finished
		call_deferred("_deferred_goto_scene")
	
# This is called once the previous level has cleaned up
# and loads the next scene/level

func _deferred_goto_scene():
	# DBG
	# print("_deferred_goto_scene")
	
	# Remove the current scene
	current_scene.free()
	
	# Instantiate the scene from the array
	current_scene = level_scenes[current_level].instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
		
	
func do_update_score(amount):
	score += amount
	Global.update_score.emit()
	
func do_life_lost():
	lives -= 1
	if Global.lives > 0:
		spawn_ball()
	else:
		do_game_over()	
	Global.update_lives.emit()
	
func do_level_finished():
	level_finished.emit()
	
func spawn_ball():
	# the ball is created in the middle of the scene with a random downward
	# velocity, this is all handled in the ball _ready() function and so all we need
	# to do here is instantiate the ball
	var ball_instance = ball_scene.instantiate()
	# connect up the signal from the ball to manage lives
	# ball_instance.life_lost.connect(life_lost)
	# and add to the scene
	add_child(ball_instance)
	
func do_game_over():
	# DBG
	print("Game Over")
	game_over = true
	reset_defaults()
	# set current level to -1 so that when we hit next level
	# we go back to our default level
	current_level = -1
	next_level()
