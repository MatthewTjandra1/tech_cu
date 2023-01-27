extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var scene_path_to_load

# Called when the node enters the scene tree for the first time.
func _ready():
	for TextureButton in $Menu/CenterRow/Buttons.get_children():
		TextureButton.connect('pressed', self, "_on_Button_pressed", [TextureButton.scene_to_load])
		
func _on_Button_pressed(scene_to_load):
	scene_path_to_load = scene_to_load
	$Transition.show()
	$Transition.transition()


func _on_Transition_transition_done():
	get_tree().change_scene(scene_path_to_load)
