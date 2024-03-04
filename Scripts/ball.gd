extends CharacterBody2D

const MAX_MOVE_SPEED : float = 450.0
const MIN_MOVE_SPEED : float = 250.0

# Multiplier to change ball speed when it collides with the player
@export var SPEED_MULTIPLIER : float = 0.1

# TODO calculate this from the scene or something
const BALL_WIDTH : int = 32

# Padding to stop the player actually hitting the edge of the screen
const PADDING : int = 10

# Variables to capture the maximum size of the screen so that we can
# position the ball and player properly
var max_x : float = 0.0
var min_x : float = 0.0
var max_y : float = 0.0
var min_y : float = 0.0

# initial speed of ball and it's velocity
@export var move_speed : float = 250.0
var my_velocity = Vector2(0,0)

# I need to manage when the player misses the ball
var player_missed : bool = false

func _ready():

	# Calculate the size of the view and update the max and min y positions
	# so that we can see if the ball is out of bounds
	# I used code from https://ask.godotengine.org/13740/get-camera-extents-rect-2d
	var ctrans = get_canvas_transform()
	var min_pos = -ctrans.get_origin() / ctrans.get_scale()
	var view_size = get_viewport_rect().size / ctrans.get_scale()
	var max_pos = min_pos + view_size
	
	# to save a lot of calculating during every frame we can adjust the min and max positions
	# based on the size of the ball and a bit of padding as this will be static
	var ball_size = PADDING + (BALL_WIDTH / 2)
	max_x = max_pos.x - ball_size
	min_x = min_pos.x + ball_size
	max_y = max_pos.y - ball_size
	min_y = min_pos.y + ball_size
		
	# set the position of the ball to be in the centre of the screen
	position.y = (max_pos.y - min_pos.y) / 2
	position.x = (max_pos.x - min_pos.x) / 2
	
	# initially the ball should have a random velocity down towards the player
	# We want the ball to drop within a 90 degree angle
	# So first calculate a random speed for the ball
	var rng = RandomNumberGenerator.new()
	var speed_multiplier = rng.randf_range(MIN_MOVE_SPEED, MAX_MOVE_SPEED)
	
	# Now we need to determine x and y
	# x can be anywhere from -1 to 1
	# y must always be positive so the ball falls
	# Calculate the x direction
	var x_direction = rng.randf_range(-1.0, 1.0)
	
	# y direction is more complicated because we want it to be 45 degrees either
	# side of x = 0 (I need to draw a diagram in comments)
	# For the direction to be 45 degrees the y direction component cannot be more
	# than the x direction
	# If x is negative we need to make it positive before determining y
	# If x is positive it's fine
	var y_direction = 0
	if x_direction < 0 :
		y_direction = rng.randf_range(-(x_direction), 1.0)
	else :
		y_direction = rng.randf_range(x_direction, 1.0)
	# DBG
	# print(x_direction, " ", y_direction)
	
	# Now factor in the speed to get the values for the velocity vector
	my_velocity.x = x_direction * speed_multiplier
	my_velocity.y = y_direction * speed_multiplier
	
	# connect our signals
	Global.level_finished.connect(ball_level_finished)
	

func _physics_process(_delta):
	
	# Let's see if the ball has collided with anything
	#for i in get_slide_collision_count():
		#var collision = get_slide_collision(i)
		## DBG
		#print("I collided with ", collision.get_collider().name)
		#if collision.get_collider().name == "Player":
			## We need to work out the velocity and bounce it back
			## x can continue but y needs to be inverted
			## TODO add some spin from the speed of the bat
			#my_velocity.y = -(my_velocity.y)
			
	# Before we move the ball let's see if they'll be outside the camera
	if position.x < min_x:
		my_velocity.x = -(my_velocity.x)
	else:
		my_velocity.x -= 1

	if position.x > max_x:
		my_velocity.x = -(my_velocity.x)
	else:
		my_velocity.x += 1
		
	if position.y < min_y:
		my_velocity.y = -(my_velocity.y)
	else:
		my_velocity.y -= 1

	# for the max of y if we got further than y = PLAYER_Y we passed the bat and so
	# we lose a life
	if position.y > Global.PLAYER_Y:
		missed_player()
	else:
		my_velocity.y += 1
	
	if player_missed == false:
		# normalize the velocity to prevent fast diagonal movement	
		my_velocity = my_velocity.normalized() * (move_speed * Global.speed_multiplier)
		velocity = my_velocity
	
		# Move the ball and see if we collided with the player
		var collision = move_and_collide(my_velocity * _delta)
		# TODO if this a collision with the player I need to alter the velocity of the ball
		# based on the velocity of the player
		if collision:
			if (collision.get_collider().name == "Player"):
				# OK we collided with the player
				var player_velocity = collision.get_collider_velocity()
				# DBG
				print("Ball Velocity before change ", my_velocity.x, " ", my_velocity.y)
				# There are four different scenarios we need to handle
				# Speed the ball up if player and ball are going in the same direction
				if (player_velocity.x > 0 and my_velocity.x > 0) or (player_velocity.x < 0 and my_velocity.x < 0) :
					my_velocity.x = my_velocity.x * SPEED_MULTIPLIER
				# Slow the ball down if player and ball are going in opposite directions
				elif (player_velocity.x < 0 and my_velocity.x > 0) or (player_velocity.x > 0 and my_velocity.x < 0):
					my_velocity.x = my_velocity.x * (1 / SPEED_MULTIPLIER)
			# Always adjust the y component to "bounce" the ball
			my_velocity.y = -(my_velocity.y)
			# DBG
			print("Ball Velocity after change ", my_velocity.x, " ",my_velocity.y)
	
func hit_block():
	# DBG
	print("hit block")
	# When we hit a block we want to bounce off the block in the opposite direction
	# TODO there are some edge cases that mean we bounce off the side of a block
	# which are not handled here
	my_velocity.y = -(my_velocity.y)
	my_velocity = my_velocity.normalized() * move_speed
	velocity = my_velocity
	
func missed_player():
	# DBG
	print("missed player")
	
	# OK this may be an architecture issue of my design but the ball continues to
	# move while the audio is playing and of course it's always below the player
	# so we repeatedly come into this function
	
	# So to hack around it I will hide the ball, stop it moving and set y to
	# PLAYER_Y
	get_node("Sprite").visible = false
	player_missed = true
	velocity = Vector2(0,0)
	position.y = Global.PLAYER_Y - 10
		
	# Play Audio and then clear up
	get_node("Died").play()

func _on_died_finished():
		# when a life is lost we need to tell the main scene that it happened
	# and then remove this instance of the ball
	Global.do_life_lost()
	queue_free()

	
func ball_level_finished():
	#DBG
	print("ball_level_finished")
	queue_free()
