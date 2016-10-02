extends Node2D
var color = Color("00FFFF")
var startHex = []
func _draw():
	if startHex.size() > 2:##its not a polygon if it is less than that size
		draw_colored_polygon(startHex,color)
	
func drawStart(h):
	startHex.clear()
	startHex = h
	update()