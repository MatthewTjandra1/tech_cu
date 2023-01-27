extends "pawn.gd"

onready var Grid = get_parent()

func _ready():
	update_look_direction(Vector2(1, 0))

func _process(delta):
	var input_direction = get_input_direction()
	if not input_direction:
		return
	update_look_direction(input_direction)

	var target_position = Grid.request_move(self, input_direction)
	if target_position:
		move_to(target_position)
	else:
		bump()

func get_input_direction():
	return Vector2(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	)

func update_look_direction(direction):
	$Sprite.rotation = direction.angle()

func move_to(target_position):
	set_process(false)

	# Move the node to the target cell instantly,
	# and animate the sprite moving from the start to the target cell
	var move_direction = (target_position - position).normalized()
		
	$Tween.interpolate_property(
		self,"position",
		position,target_position,
		Tween.TRANS_LINEAR, Tween.EASE_IN)

	$Tween.start()
	set_process(true)


func bump():
	set_process(false)
	set_process(true)
