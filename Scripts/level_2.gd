extends Node2D

# Blocks will be generated in a grid using the following information
const BLOCK_ROWS : int = 2 # 1 rows
const BLOCK_COLS : int = 6 # 5 columns
const BLOCK_PADDING : int = 10
# TODO get these from the sprite
const BLOCK_HEIGHT : int = 32
const BLOCK_WIDTH : int = 96

const POINTS : int = 10

# Total number of blocks spawned in so that we can keep track
var block_count : int = (BLOCK_ROWS - 1) * (BLOCK_COLS - 1)

# preload the ball scene so that we can instantiate balls
# var ball_scene = preload("res://ball.tscn")
# preload the block scene so that we can easily instantiate multiple blocks
var block_scene = preload("res://Scenes/block.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
		
	# spawn blocks
	spawn_blocks()
	
	# Drop the ball into the scene
	Global.spawn_ball()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass	
	
func spawn_blocks():
	# I want to programatically create my blocks rather than just manually adding them to the scene
	# Create a loop, I need to start at 1 not zero so using a range, for both x and y
	for x in range (1, BLOCK_COLS):
		for y in range (1, BLOCK_ROWS):
			# Create a new instance of the block scene which is preloaded
			var block_instance = block_scene.instantiate()
			# Work out the position of the block based on a grid design
			var block_x = (BLOCK_PADDING + (BLOCK_WIDTH)) * x
			var block_y = (BLOCK_PADDING + (BLOCK_HEIGHT)) * y
			# Then set the position
			block_instance.position = Vector2(block_x, block_y)
			# Connect up the destroy signal so we can keep track
			block_instance.block_destroyed.connect(update_block_count)
			# Add the new scene to the main scene
			add_child(block_instance)
			
	
func update_block_count():
	
	# update the block count
	block_count -= 1
	
	# the game ends if all the blocks are destroyed
	if block_count <= 0:
		# TODO We need to kill the ball
		# TODO Check if we increase the score
		Global.do_level_finished()
		Global.next_level()
	else:
		Global.do_update_score(POINTS)
	
	# DBG
	print (block_count, Global.score)
