extends CharacterBody2D

const MOVE_SPEED = 350.0
# TODO calculate this from the scene or something
const PLAYER_WIDTH = 136
# Padding to stop the player actually hitting the edge of the screen
const PADDING = 10
# the y position of the player is static
# const PLAYER_Y = 575

var max_x : float = 0.0
var min_x : float = 0.0

func _ready():

	# Calculate the size of the view and update the max and min y positions
	# so that we can see if the player is out of bounds
	# I used code from https://ask.godotengine.org/13740/get-camera-extents-rect-2d
	var ctrans = get_canvas_transform()
	var min_pos = -ctrans.get_origin() / ctrans.get_scale()
	var view_size = get_viewport_rect().size / ctrans.get_scale()
	var max_pos = min_pos + view_size
	
	# to save a lot of calculating during every frame we can adjust the min and max positions
	# based on the size of the player and a bit of padding as this will be static
	var player_size = PADDING + (PLAYER_WIDTH / 2)
	max_x = max_pos.x - player_size
	min_x = min_pos.x + player_size
	
	# set the position of the bat to be in the centre of the screen
	position.y = Global.PLAYER_Y
	position.x = (max_pos.x - min_pos.x) / 2
	

func _physics_process(_delta):
	# subtle change from 3.x, I think that the velocity is obtained from the object
	# so no need to create a variable and apply it to the node, just apply it to the node
	velocity = Vector2()
		
	# inputs
	if Input.is_action_pressed("move_left"):
		# before we move the player let's see if they'll be outside the camera
		if position.x < min_x:
			velocity.x = 0
		else:
			velocity.x -= 1

	if Input.is_action_pressed("move_right"):
		# before we move the player let's see if they'll be outside the camera
		if position.x > max_x:
			velocity.x = 0
		else:
			velocity.x += 1
			
	# normalize the velocity to prevent fast diagonal movement	
	velocity = velocity.normalized() * MOVE_SPEED
	
	# Move the player
	# TODO do I need to check for collisions here?
	# I don't think so as the ball handles that
	move_and_collide(velocity * _delta)
