extends RefCounted
class_name Cell
var x
var y
var visited=false
static var unvisited_cells=[]
var neighbours={}
static var right=Vector2.RIGHT
static var left=Vector2.LEFT
static var up=Vector2.UP
static var down=Vector2.DOWN
var edges={}
var id
static var id_count=0
func _init(x,y,visited,toappend=true) -> void:
	id_count+=1;
	self.id=id_count
	self.x=x
	self.y=y;
	if toappend:unvisited_cells.append(self)
	self.visited=visited
func connect_neighbours(maze):
	neighbours=get_direct_neighbors_dict(maze)
	for i in range(neighbours.size()):
		connect_with(neighbours.values()[i],neighbours.keys()[i])
	pass;
func connect_with(cell:Cell,direction):
	if cell.edges.has(direction*-1):
		var potential_edge=cell.edges[direction*-1];
		if potential_edge!=null:
			edges[direction]=potential_edge
			return
	var edge=Edge.new(self,cell)	
	edges[direction]=edge
	cell.edges[direction*-1]=edge
func random_walk():
	
	var unvisited=get_unvisited_neighbours()
	if unvisited.is_empty():
		Mazer.start_walk() 
		return
		#Mazer.start=true; 
		#return
	var next=unvisited.pick_random()
	visit(next)
	pass;
func visit(next:Cell):
	
	var direction=neighbours.find_key(next)
	edges[direction].wall=false
	next.visited=true
	unvisited_cells.erase(self)
	unvisited_cells.erase(next)
	next.random_walk()
		
func get_unvisited_neighbours():
	var unvisited=[]
	for n in neighbours.values():
		if n.visited==false:
			unvisited.append(n)
	return unvisited	
static func pick_random_entry(dict: Dictionary) -> Array:
	var keys = dict.keys()
	var random_key = keys[randi() % keys.size()]
	return [random_key, dict[random_key]]
			
func get_direct_neighbors_dict(maze: Array) -> Dictionary:
	var neighbors = {}
	var directions = {
		Vector2(-1, 0): "Left",
		Vector2(1, 0): "Right",
		Vector2(0, -1): "Up",
		Vector2(0, 1): "Down"
	}

	for direction in directions.keys():
		var nx = x + direction.x
		var ny = y + direction.y

		if nx >= 0 and nx < maze.size() and ny >= 0 and ny < maze[0].size():
			neighbors[direction] = maze[nx][ny]
		
	return neighbors


class Edge:
	var A:Cell
	var B:Cell
	var wall=true;
	func _init(a:Cell,b:Cell) -> void:
		self.A=a
		self.B=b	
