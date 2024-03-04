extends Control

# I need to preload the texture to blank out a life in the UI
var blank_life = preload("res://Assets/Sprites/TransparentBatSmall.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# set up default values
	ui_set_default_values()
	
	# Connect our signals
	Global.update_score.connect(ui_update_score)
	Global.update_lives.connect(ui_update_lives)
	#Global.game_over.connect(ui_game_over)
	
	# We need to adjust for any lives lost in a previous level
	if Global.lives == 2:
		# Set the texture for Life1 to be blank
		get_node("PanelContainer/MarginContainer/GridContainer/Life1").texture = blank_life
	if Global.lives == 1:
		# Set the texture for Life1 to be blank
		get_node("PanelContainer/MarginContainer/GridContainer/Life1").texture = blank_life
		# Set the texture for Life2 to be blank
		get_node("PanelContainer/MarginContainer/GridContainer/Life2").texture = blank_life

func ui_set_default_values():
	get_node("PanelContainer/MarginContainer/GridContainer/ScoreLabel").text = str(Global.score)
	
func ui_update_score():
	var score_label = get_node("PanelContainer/MarginContainer/GridContainer/ScoreLabel")
	# initially the text for the score is invisible so check that first
	if score_label.visible == false:
		score_label.visible = true
	# and then update the score
	score_label.text = str(Global.score)
	
func ui_update_lives():
	# remove the relevant life from the UI
	if Global.lives == 2:
		# Set the texture for Life1 to be blank
		get_node("PanelContainer/MarginContainer/GridContainer/Life1").texture = blank_life
	elif Global.lives == 1:
		# Set the texture for Life2 to be blank
		get_node("PanelContainer/MarginContainer/GridContainer/Life2").texture = blank_life
	elif Global.lives == 0:
		# Set the texture for Life3 to be blank
		get_node("PanelContainer/MarginContainer/GridContainer/Life3").texture = blank_life
	
func ui_game_over():
	get_node("PanelContainer2").visible = true
