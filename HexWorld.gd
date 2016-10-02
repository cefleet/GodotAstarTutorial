extends Node2D

var gridCols = 10
var gridRows = 10
var hexSizeX = 30
var hexSizeY = 30
var layout = 'pointy'

var hexMap = {}

var astar = AStar.new()
var hexGrid = HexGrid.new()

var obstacles = []
var path = []
var start = Vector3(0,0,0)
var end = Vector3(0, 0, 0)
var travelCost = 0


###no diagonal connections
func makeGrid():
	disconnectPoints()
	obstacles.clear()
	var m = hexGrid.get_map()
	hexMap = {}
	var id = 0
	for h in m:
		hexMap[h] = {
			"isObstacle":false,
			"travelWeight":1,
			"astarId":id,
			"hex":h
		}
		id += 1
		addAstarPoint(hexMap[h])
	connectPoints()

func addAstarPoint(h):
	astar.add_point(h.astarId,h.hex,h.travelWeight)

func makePath(from,too):
	var temPath = astar.get_point_path(hexMap[from].astarId,hexMap[too].astarId)
	var _path = hexPathToPointPath(temPath)
	path = _path
	drawPath()

func drawPath():
	get_node("DrawPath").drawPath(path)

func hexPathToPointPath(path):
	travelCost = 0
	var _path = []
	for p in path:
		travelCost += hexMap[p].travelWeight
		_path.push_back(hexGrid.hex_to_point(p))
		get_node("travelCost").set_text(str(travelCost))
	return _path

func setWeight(hex):
	var w = 1.0+float(get_node("WeightPoints").get_value()-1)*0.25
	print(w)

	hexMap[hex].travelWeight = w
	disconectPoint(hex)
	astar.remove_point(hexMap[hex].astarId)
	astar.add_point(hexMap[hex].astarId,hex,hexMap[hex].travelWeight)
	connectPoint(hex)
	get_node("DrawWeights").drawWeights()


func removeObstacle(hex):
	if obstacles.find(hex) > -1:
		connectPoint(hex)
		obstacles.erase(hex)
		drawObstacles()
		hexMap[hex].isObstacle = false

func addObstacle(hex):
	if hex in hexMap:
		if obstacles.find(hex) < 0:
			disconectPoint(hex)
			obstacles.push_back(hex)
			drawObstacles()
			hexMap[hex].isObstacle = true
		else:
			removeObstacle(hex)

		makePath(start,end)

func drawObstacles():
	var obs = []
	for o in obstacles:
		obs.push_back(hexGrid.hex_corners(o))
	get_node("DrawObstacle").drawObstacles(obs)

func setEndPoint(hex):
	end = hex
	makePath(start,end)

func setStartPoint(hex):
	start = hex
	get_node("DrawStart").drawStart(hexGrid.hex_corners(start))


func connectPoints():
	for hex in hexMap:
		connectPoint(hex)

func connectPoint(hex):
	var nieghs = hexGrid.hex_neighbors(hex)
	for n in nieghs:
		if n in hexMap:

			if not astar.are_points_connected(hexMap[hex].astarId,hexMap[n].astarId):
				if not hexMap[n].isObstacle:##make sure the connection is not an obstacle
					astar.connect_points(hexMap[hex].astarId,hexMap[n].astarId)

func disconnectPoints():
	for hex in hexMap:
		disconectPoint(hex)

func disconectPoint(hex):
	var nieghs = hexGrid.hex_neighbors(hex)
	for n in nieghs:
		if n in hexMap:
			if astar.are_points_connected(hexMap[hex].astarId,hexMap[n].astarId):
				astar.disconnect_points(hexMap[hex].astarId,hexMap[n].astarId)

func changeTo(type="flat"):
	if type == 1:
		type = 'flat'
	else:
		type = 'pointy'

	if type != layout:
		hexGrid.set_layout(type)
		layout = type
		makeGrid()
		setStartPoint(Vector3(0,0,0))
		end = Vector3(0,0,0)
		get_node("DrawGrid").drawGridInstant()
		get_node("DrawWeights").drawWeights()
		drawObstacles()


func _input(event):
	if (event.type==InputEvent.MOUSE_BUTTON and event.pressed and (event.button_index == 1)):
		##the offset is how much the "drawGrid" is off of 0,0
		var offset = get_node("DrawGrid").get_pos()

		var pos = Vector2(event.pos.x-offset.x,event.pos.y-offset.y)
		var hex = hexGrid.point_to_hex(pos)
		if hex in hexMap:
			addObstacle(hex)

	elif (event.type==InputEvent.MOUSE_BUTTON and event.pressed and (event.button_index == 2)):
		var offset = get_node("DrawGrid").get_pos()

		var pos = Vector2(event.pos.x-offset.x,event.pos.y-offset.y)
		var hex = hexGrid.point_to_hex(pos)
		if hex in hexMap:
			setStartPoint(hex)

	elif (event.type==InputEvent.MOUSE_BUTTON and event.pressed and (event.button_index == 3)):
		var offset = get_node("DrawGrid").get_pos()

		var pos = Vector2(event.pos.x-offset.x,event.pos.y-offset.y)
		var hex = hexGrid.point_to_hex(pos)
		if hex in hexMap:
			setWeight(hex)


	elif(event.type==InputEvent.MOUSE_MOTION):
		var offset = get_node("DrawGrid").get_pos()
		var pos = Vector2(event.pos.x-offset.x,event.pos.y-offset.y)
		var hex = hexGrid.point_to_hex(pos)
		if hex in hexMap:
			setEndPoint(hex)


func _ready():
	set_process_input(true)
	hexGrid.set_hex_size(Vector2(hexSizeX,hexSizeY))
	hexGrid.set_rows(gridRows)
	hexGrid.set_cols(gridCols)
	hexGrid.set_layout(layout)

	makeGrid()

	get_node("DrawGrid").drawGridInstant()

	setStartPoint(start)
	makePath(start,end)

	get_node("GridType").connect("value_changed",self,"changeTo")
