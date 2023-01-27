extends TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var deckSize = INF
# Called when the node enters the scene tree for the first time.
func _ready():
	rect_scale *= $'../../'.CardSize/rect_size


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _gui_input(event):
	if Input.is_action_just_released("leftclick"):
		if deckSize > 0:
			deckSize = $'../../'.drawCard()
			disabled = true
			yield(get_tree().create_timer(0.2), "timeout")
			disabled = false
			if deckSize == 0:
				disabled = true
