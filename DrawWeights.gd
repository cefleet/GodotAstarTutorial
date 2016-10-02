extends Node2D

func _draw():
	var hexMap = get_parent().hexMap
	var hexGrid = get_parent().hexGrid
	for hex in hexMap:
		var h = hexGrid.hex_corners(hex)
		#draw_colored_polygon(h,Color(float(hexMap[hex].travelWeight)/2,float(hexMap[hex].travelWeight)/2,float(hexMap[hex].travelWeight)/2))
		draw_colored_polygon(h,Color(float(hexMap[hex].travelWeight)/10,float(hexMap[hex].travelWeight)/10,float(hexMap[hex].travelWeight)/10))
		if hexMap[hex].travelWeight == 1:
			draw_colored_polygon(h,Color("428a1a"))
		elif hexMap[hex].travelWeight == 1.25:
			draw_colored_polygon(h,Color("623916"))
		elif hexMap[hex].travelWeight == 1.50:
			draw_colored_polygon(h,Color("62c0ff"))
		elif hexMap[hex].travelWeight == 1.75:
			draw_colored_polygon(h,Color("001b93"))
			
func drawWeights():
	update()