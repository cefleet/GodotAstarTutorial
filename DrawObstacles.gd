extends Node2D
var hexes = []#hexes is an array of corners
var color = Color("000000")

func _draw():
	for h in hexes:
		draw_colored_polygon(h,color)
	
func drawObstacles(h):
	hexes.clear()
	hexes = h
	update()