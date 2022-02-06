extends "res://Scripts/Mirrored.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("body_entered", self, "_on_collision")
	pass # Replace with function body.

func _on_collision(contact):
	if is_primary:
		for c in self.clones:
			c.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
