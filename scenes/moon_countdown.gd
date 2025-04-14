extends Control

@onready var label = $Label

var days_remaining = 30
var time_since_last_decrease = 0.0
const DECREASE_INTERVAL = 5.0  # 5 seconds between decreases

func _ready():
	update_label()

func _process(delta):
	time_since_last_decrease += delta
	
	if time_since_last_decrease >= DECREASE_INTERVAL:
		time_since_last_decrease = 0
		if days_remaining > 0:
			days_remaining -= 1
			update_label()
		else:
			# Full moon has arrived!
			label.text = "FULL MOON TONIGHT!"
			# Here you could trigger werewolf spawning events

func update_label():
	label.text = "%d days until full moon" % days_remaining 
