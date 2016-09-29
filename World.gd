extends Spatial
var gridCols = 10
var gridRows = 10

var tileWidth = 1
var tileHeight = 1

var pathType = 'cardnial'
var grid = {}
var astar = AStar.new()

var obstacles = []
###no diagonal connections
func makeGrid():
	grid = {}
	var r = 0
	var c = 0
	var id = 0
	while r < gridRows:
		c = 0
		while c < gridCols:
			grid[id] = {
				"neighbors":{
					"u":Vector3(c,0,r-1),
					"ru":Vector3(c+1,0,r-1),
					"r":Vector3(c+1,0,r),
					"rd":Vector3(c+1,0,r+1),
					"d":Vector3(c,0,r+1),
					"ld":Vector3(c-1,0,r+1),
					"l":Vector3(c-1,0,r),
					"lu":Vector3(c-1,0,r-1)
				},
				#gridpoint is the top right corner
				"gridPoint":Vector3(c,0,r),
				"center":Vector3(float(c)+float(tileWidth)/2,0,float(r)+float(tileHeight)/2)
			}
			astar.add_point(id,Vector3(c,0,r))
			c += 1
			id += 1
		r += 1

func drawGrid():
	var d = get_node("Grid")
	d.clear()
	for tile in grid:
		d.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
		d.add_vertex(Vector3(grid[tile].gridPoint.x*tileWidth,0,grid[tile].gridPoint.z*tileHeight))
		d.add_vertex(Vector3(grid[tile].gridPoint.x*tileWidth+tileWidth,0,grid[tile].gridPoint.z*tileHeight))
		d.add_vertex(Vector3(grid[tile].gridPoint.x*tileWidth+tileWidth,0,grid[tile].gridPoint.z*tileHeight+tileHeight))
		d.add_vertex(Vector3(grid[tile].gridPoint.x*tileWidth,0,grid[tile].gridPoint.z*tileHeight+tileHeight))
		d.add_vertex(Vector3(grid[tile].gridPoint.x*tileWidth,0,grid[tile].gridPoint.z*tileHeight))
		d.end()

func drawObstacles():
	var d = get_node("obstacles")
	d.clear()
	for tile in obstacles:
		d.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
		d.add_vertex(Vector3(grid[tile].gridPoint.x*tileWidth,0,grid[tile].gridPoint.z*tileHeight))
		d.add_vertex(Vector3(grid[tile].gridPoint.x*tileWidth+tileWidth,0,grid[tile].gridPoint.z*tileHeight))
		d.add_vertex(Vector3(grid[tile].gridPoint.x*tileWidth+tileWidth,0,grid[tile].gridPoint.z*tileHeight+tileHeight))
		d.add_vertex(Vector3(grid[tile].gridPoint.x*tileWidth,0,grid[tile].gridPoint.z*tileHeight+tileHeight))
		d.add_vertex(Vector3(grid[tile].gridPoint.x*tileWidth,0,grid[tile].gridPoint.z*tileHeight))
		d.end()

##directions are clockwise starting up 0 - 7
func getDirectionIds(id,dirs):
	var ids = []
	for d in dirs:
		for i in grid:
			if grid[i].gridPoint == grid[id].neighbors[d]:
				ids.push_back(i)
				continue
	return ids

func connectCardinal():
	for tile in grid:
		var ids = getDirectionIds(tile,["u","r","d","l"])
		for i in ids:
			if not astar.are_points_connected(tile,i):
				astar.connect_points(tile,i)
			

func connectAll():
	for tile in grid:
		var ids = getDirectionIds(tile,["u","ru","r","rd","d","ld","l","lu"])
		for i in ids:
			if not astar.are_points_connected(tile,i):
				astar.connect_points(tile,i)

func drawPath(path):
	var d = get_node("drawPath")
	d.clear()
	d.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	for p in path:
		d.add_vertex(Vector3(grid[p].center.x*tileWidth,0,grid[p].center.z*tileHeight))
	d.end()

func disconnectPoints():
	for tile in grid:
		disconectPoint(tile)
		

func disconectPoint(tile):
	var ids = getDirectionIds(tile,["u","ru","r","rd","d","ld","l","lu"])
	for i in ids:
		if astar.are_points_connected(tile,i):
			astar.disconnect_points(tile,i)

func addObstacle():
	var v = Vector3(get_node("AddObstacle/cols").get_value(),0,get_node("AddObstacle/rows").get_value())
	var tile
	for t in grid:
		if grid[t].gridPoint == v:
			tile = t
			continue
	disconectPoint(tile)
	obstacles.push_back(tile)
	drawObstacles()

func setObstacles():
	for tile in obstacles:
		disconectPoint(tile)
	drawObstacles()
	makePath()

func setType(type):

	if pathType != type:
		disconnectPoints()
		pathType = type
		if type == 'cardnial':
			connectCardinal()
			setObstacles()
		else:
			connectAll()
			setObstacles()
	
	makePath()

func makePath():
	var startVector = Vector3(get_node("Start/cols").get_value(),0,get_node("Start/rows").get_value())
	var endVector = Vector3(get_node("End/cols").get_value(),0,get_node("End/rows").get_value())
	var startId = 0
	var endId = 0
	for i in grid:
		if grid[i].gridPoint == startVector:
			startId = i
		
		if grid[i].gridPoint == endVector:
			endId = i
	
	var path = astar.get_id_path(startId,endId)
	drawPath(path)
		
func _ready():
	#default setup
	makeGrid()
	drawGrid()
	connectCardinal()
	
	get_node("DrawCardialPath").connect("pressed",self,"setType",["cardnial"])
	get_node("DrawAllPath").connect("pressed",self,"setType",["all"])
	
	get_node("Start").connect("valueChanged",self,'makePath')
	get_node("End").connect("valueChanged",self,'makePath')
	get_node("AddObstacle/AddObstacleButton").connect("pressed",self,'addObstacle')
	
	