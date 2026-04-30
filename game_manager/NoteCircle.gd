extends Node2D

# Draws the note as a filled circle with a bright border
var color: Color = Color(0.65, 0.3, 1.0, 0.95)

func _draw():
	# Outer glow ring
	draw_circle(Vector2.ZERO, 36.0, Color(color.r, color.g, color.b, 0.3))
	# Main filled circle
	draw_circle(Vector2.ZERO, 32.0, color)
	# Inner highlight
	draw_circle(Vector2.ZERO, 18.0, Color(1, 1, 1, 0.15))

func _process(_delta):
	queue_redraw()

# Called by Note.gd to change color on hit
func set_color(c: Color):
	color = c
