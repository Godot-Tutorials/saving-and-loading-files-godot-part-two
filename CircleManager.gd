extends Node2D

# Get the child button node so I can connect to its pressed signal
onready var buttonNode: Button = get_child(0)

var randomFloats: RandomNumberGenerator = RandomNumberGenerator.new()
var circlePool: Array = [] # Object Pooling
const TOTAL_CIRCLES = 10

func _ready() -> void:
	randomFloats.randomize()
	
	# connect to the pressed signal
	buttonNode.connect("pressed", self, "updateCirclePositions")
	
	loadCircles()
	


func updateCirclePositions() -> void:
	for x in circlePool:
		x.updatePosition(randomGeneratePostions())


func createRandomCircleNode() -> Node2D:
	var circleNode: Node2D
	circleNode = Circle.new(randomGeneratePostions())
	return circleNode


func createLoadedCircleNode(position: Vector2) -> Node2D:
	var circleNode: Node2D
	circleNode = Circle.new(position)
	return circleNode


func randomGeneratePostions() -> Vector2:
	var width = randomFloats.randf_range(0.0, 1000.0)
	var height = randomFloats.randf_range(0.0, 500.0)
	
	return Vector2(width, height)


func createNewCircles() -> void:
	for i in TOTAL_CIRCLES:
		var x: Circle = createRandomCircleNode()
		x.set_name("circle" + String(i+1))
		circlePool.push_back(x)
		self.add_child(x)






func saveCircles() -> void:
	var saveFile: File = File.new()
	saveFile.open("user://circlesFile.txt", File.WRITE)
	
	for x in circlePool:
		var circleData: Dictionary = {
			"position": var2str(x.circlePosition),
			"color": var2str(x.circleColor),
			"name": x.get_name(), # x.name
			"radius": x.circleRadius,
			"script": x.get_script().get_path()
		}
		
		saveFile.store_line(to_json(circleData))
	
	saveFile.close()


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		self.saveCircles() # save circle nodes
		get_tree().quit() # default behavior


func loadCircles() -> void:
	var openFile: File = File.new()
	
	if not openFile.file_exists("user://circlesFile.txt"):
		self.createNewCircles()
		return
	
	openFile.open("user://circlesFile.txt", File.READ)
	
	# don't iterate if file is empty
	if openFile.get_len() <= 0:
		self.createNewCircles()
		return
	
	while openFile.get_position() < openFile.get_len():
		var data: Dictionary = parse_json(openFile.get_line())
		
		# make sure that the key name 'script' exist
		if not data.has('script'):
			print("script is null")
			continue
		
		var circleLoad: Reference = load(data.script)
		var circleObject = circleLoad.new(str2var(data.position))
		circleObject.set_name(data.name)
		add_child(circleObject)
		circlePool.push_back(circleObject)
	
	openFile.close()
	
	return
