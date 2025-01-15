extends Node3D
class_name Mazer
var xr_interface: XRInterface
var maze:Array[Array]=[]
var maze_size=6;
var block_size=2
static var instance
static var start=false;
# Called when the node enters the scene tree for the first time.
@export var hand:Node3D
@export var player:XROrigin3D
@export var ball_player:XROrigin3D
@export var ball:Node3D
var webxr_interface
 
func _ready() -> void:
	$CanvasLayer.visible = false
	$CanvasLayer/Button.pressed.connect(self._on_button_pressed)
	print("parent init")
	instance=self
	init_maze()
	$spectator/spec_origin.current=true
	$ball/ball_origin.current=false
	start_walk()
	xr_interface = XRServer.find_interface("OpenXR")
	
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully")
		print("playarea:"+str(xr_interface.set_play_area_mode(XRInterface.XR_PLAY_AREA_UNKNOWN)))
	
		# Turn off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Change our main viewport to output to the HMD
		get_viewport().use_xr = true
	else:
		print("OpenXR not initialized, please check if your headset is connected")
	return
	webxr_interface = XRServer.find_interface("WebXR")
	if webxr_interface:
		# WebXR uses a lot of asynchronous callbacks, so we connect to various
		# signals in order to receive them.
		webxr_interface.session_supported.connect(self._webxr_session_supported)
		webxr_interface.session_started.connect(self._webxr_session_started)
		webxr_interface.session_ended.connect(self._webxr_session_ended)
		webxr_interface.session_failed.connect(self._webxr_session_failed)
 
		webxr_interface.select.connect(self._webxr_on_select)
		webxr_interface.selectstart.connect(self._webxr_on_select_start)
		webxr_interface.selectend.connect(self._webxr_on_select_end)
 
		webxr_interface.squeeze.connect(self._webxr_on_squeeze)
		webxr_interface.squeezestart.connect(self._webxr_on_squeeze_start)
		webxr_interface.squeezeend.connect(self._webxr_on_squeeze_end)
 
		# This returns immediately - our _webxr_session_supported() method
		# (which we connected to the "session_supported" signal above) will
		# be called sometime later to let us know if it's supported or not.
		webxr_interface.is_session_supported("immersive-vr")
 
 
func _webxr_session_supported(session_mode: String, supported: bool) -> void:
	if session_mode == 'immersive-vr':
		if supported:
			$CanvasLayer.visible = true
		else:
			OS.alert("Your browser doesn't support VR")
 
func _on_button_pressed() -> void:
	# We want an immersive VR session, as opposed to AR ('immersive-ar') or a
	# simple 3DoF viewer ('viewer').
	webxr_interface.session_mode = 'immersive-vr'
	# 'bounded-floor' is room scale, 'local-floor' is a standing or sitting
	# experience (it puts you 1.6m above the ground if you have 3DoF headset),
	# whereas as 'local' puts you down at the ARVROrigin.
	# This list means it'll first try to request 'bounded-floor', then
	# fallback on 'local-floor' and ultimately 'local', if nothing else is
	# supported.
	webxr_interface.requested_reference_space_types = 'bounded-floor, local-floor, local'
	# In order to use 'local-floor' or 'bounded-floor' we must also
	# mark the features as required or optional.
	webxr_interface.required_features = 'local-floor'
	webxr_interface.optional_features = 'bounded-floor'
 
	# This will return false if we're unable to even request the session,
	# however, it can still fail asynchronously later in the process, so we
	# only know if it's really succeeded or failed when our
	# _webxr_session_started() or _webxr_session_failed() methods are called.
	if not webxr_interface.initialize():
		OS.alert("Failed to initialize WebXR")
		return
 
func _webxr_session_started() -> void:
	$CanvasLayer.visible=false
	# This tells Godot to start rendering to the headset.
	get_viewport().use_xr = true
	# This will be the reference space type you ultimately got, out of the
	# types that you requested above. This is useful if you want the game to
	# work a little differently in 'bounded-floor' versus 'local-floor'.
	print ("Reference space type: " + webxr_interface.reference_space_type)
 
func _webxr_session_ended() -> void:
	#$CanvasLayer.visible = true
	# If the user exits immersive mode, then we tell Godot to render to the web
	# page again.
	get_viewport().use_xr = false
 
func _webxr_session_failed(message: String) -> void:
	OS.alert("Failed to initialize: " + message)
 
func _on_left_controller_button_pressed(button: String) -> void:
	print ("Button pressed: " + button)
 
func _on_left_controller_button_released(button: String) -> void:
	print ("Button release: " + button)
 
#func _process(_delta: float) -> void:

	#var thumbstick_vector: Vector2 = $XROrigin3D/LeftController.get_vector2("thumbstick")
	#if thumbstick_vector != Vector2.ZERO:
		#print ("Left thumbstick position: " + str(thumbstick_vector))
 
func _webxr_on_select(input_source_id: int) -> void:
	print("Select: " + str(input_source_id))
 
	var tracker: XRPositionalTracker = webxr_interface.get_input_source_tracker(input_source_id)
	var xform = tracker.get_pose('default').transform
	print (xform.origin)
 
func _webxr_on_select_start(input_source_id: int) -> void:
	print("Select Start: " + str(input_source_id))
 
func _webxr_on_select_end(input_source_id: int) -> void:
	print("Select End: " + str(input_source_id))
 
func _webxr_on_squeeze(input_source_id: int) -> void:
	print("Squeeze: " + str(input_source_id))
 
func _webxr_on_squeeze_start(input_source_id: int) -> void:
	print("Squeeze Start: " + str(input_source_id))
 
func _webxr_on_squeeze_end(input_source_id: int) -> void:
	print("Squeeze End: " + str(input_source_id))

func init_maze():
	for i in range(maze_size):
		var row = []
		for n in range(maze_size):
			row.append(Cell.new(i, n, false))
		maze.append(row)
	for i in range(maze_size):
		for n in range(maze_size):
			maze[i][n].connect_neighbours(maze)
	maze[0][0].visited=true;
	Cell.unvisited_cells.erase(maze[0][0])
	maze[0][0].random_walk()		
	pass;

func get_astar():
	var astar= AStar2D.new()
	for i in range(maze_size):
		for n in range(maze_size):
			astar.add_point(maze[i][n].id,Vector2(i,n))
	for i in range(maze_size):
		for n in range(maze_size):
			for e in maze[i][n].edges.values():
				if not e.wall and not astar.are_points_connected(e.A.id,e.B.id):
					astar.connect_points(e.A.id,e.B.id)
	return astar						
	pass;
	
static func start_walk():
	var relevant_cells=[]
	for cell in Cell.unvisited_cells:
		for n in cell.neighbours.values():
			if n.visited:
				relevant_cells.append(cell)
				continue
	if relevant_cells.is_empty():
		print("maze done!")
		instance.build_walls()
		return			
	var next=relevant_cells.pick_random() as Cell
	Cell.unvisited_cells.erase(next)
	var visited_neigh
	for n in next.neighbours.values():
			if n.visited:
				visited_neigh=n
	visited_neigh.visit(next)
	
	pass;
var directions = {
		Vector2(-1, 0): "Left",
		Vector2(1, 0): "Right",
		Vector2(0, -1): "Up",
		Vector2(0, 1): "Down"
	}	
var maze_body	
func build_walls():
	if maze_body:return
	maze_body=load("res://maze.tscn").instantiate()
	add_child(maze_body)
	hand.target=maze_body
	for i in range(maze_size):
		for n in range(maze_size):
			var cell=maze[i][n]
			for dir in directions:
				if not cell.edges.has(dir):
					var pos=Vector2(i,n)*block_size+dir*block_size/2
					
					var angle=90
					if dir==Vector2.LEFT or dir == Vector2.RIGHT:
						angle=0
					place_wall(pos.x,pos.y,angle)
			for dir in cell.edges.keys():
			
				if cell.edges[dir].wall==true:
					var pos=Vector2(i,n)*block_size+dir*block_size/2
					
					var angle=90
					if dir==Vector2.LEFT or dir == Vector2.RIGHT:
						angle=0
					place_wall(pos.x,pos.y,angle)
	$wall.queue_free()
	var children=maze_body.get_children()					
	#for i in range(maze_size):
		#var pos=Vector2(i+block_size,0)*block_size*block_size/2
		#var angle=90
		#place_wall(pos.x,pos.y,angle)
		#pos=Vector2(i+block_size,maze_size-1)*block_size*block_size/2
		#place_wall(pos.x,pos.y,angle)
		#pos=Vector2(0,i+block_size)*block_size*block_size/2
		#angle=0
		#place_wall(pos.x,pos.y,angle)
		#pos=Vector2(maze_size-1,i+block_size)*block_size*block_size/2
		#place_wall(pos.x,pos.y,angle)					
	var astar=get_astar()
	var path=astar.get_point_path(maze[0][0].id,maze[maze_size-1][maze_size-1].id)
	
	var curve=Curve3D.new()
	for p in path:
		curve.add_point(Vector3(p.x*block_size,0.5,p.y*block_size))
	#$maze/Path3D.curve=curve
	
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#
	##if start:
		##start_walk()
		##start=false;
	#if Input.is_action_just_pressed(&"restart"):
		#get_tree().reload_current_scene()
	#pass

func get_wall(x,z,rot):
	var wall=$wall.duplicate() 
	wall.transform=$wall.transform
	wall.visible=true;
	
	wall.global_position=Vector3(x,global_position.y,z)
	wall.rotation_degrees.z=90
	wall.rotation_degrees.y=rot
	
	
	
	return wall
var counter=0	
func place_wall(x,z,rot):
	counter+=1;
	
	var wall=get_wall(x,z,rot)
	
	maze_body.add_child(wall)
	
	return wall
		
	


func _on_right_button_pressed(name: String) -> void:
	print("pressed")
	print(name)
	ball_player.current=true
#	player.reparent(ball,false)
	pass # Replace with function body.


func _on_right_button_released(name: String) -> void:
	print("pressed")
	print(name)
	player.current=true
	#player.reparent($spectator,false)
	pass # Replace with function body.
