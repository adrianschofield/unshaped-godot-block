extends Control

# This is not really a level but a UI and buttons page for
# controlling the flow of the game

# Called when the node enters the scene tree for the first time.
func _ready():
	# Check if we came into the level because of Game Over and if so
	# Show the Game Over message
	if Global.game_over:
		get_node("CanvasLayer/GameOverTextPanelContainer").visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_button_down():
	Global.next_level()
	Global.game_over = false
