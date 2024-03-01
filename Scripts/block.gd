extends Area2D

# define our signals
signal block_destroyed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_body_entered(body):
	# DBG
	print(body.name)
	# Tell the ball it hit a block
	body.hit_block()
	
	# Hide the block and play it's explosion sfx
	get_node("Sprite").visible = false
	get_node("Explosion").play()

# This is connected to the finish signal from the Audio Stream Player
func _on_explosion_finished():
	# Tell the main script that we were destroyed
	block_destroyed.emit()
	# Then destroy the object
	queue_free()
