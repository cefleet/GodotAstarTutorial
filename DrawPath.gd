extends Node2D
var path = []
var color = Color("00FF00")

func _draw():
	for p in path:
		draw_line(p[0],p[1],color,3,true)
	
func drawPath(points):
	path.clear()
	var p = 0
	while p < points.size()-1:
		path.push_back([points[p],points[p+1]])
		p += 1
	
	update()