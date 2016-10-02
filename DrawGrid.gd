extends Node2D
var hexes = []
var color = Color("222222")

func _draw():
	for h in hexes:
		for l in h:
			draw_line(l[0],l[1],color,2,true)
	
func drawGridInstant():
	hexes.clear()
	for h in get_parent().hexGrid.get_map():
		hexes.push_back(get_parent().hexGrid.hex_edges(h))
	update()