class_name Mirrored
extends RigidBody2D

var primary: RigidBody2D
export var clone_scene_name: String
export var is_primary: bool = true
var viewport_dimensions: Vector2
var clones = []
var last_linear_velocity: Vector2 = Vector2.ZERO
var last_angular_velocity: float = 0
export var shouldLog = false

var jump_to_position: Vector2
var did_jump: bool

enum ClonePosition {
	TopLeft,
	Top,
	TopRight,
	Left,
	Primary,
	Right,
	BottomLeft,
	Bottom,
	BottomRight
}

var clone_position: int = ClonePosition.Primary




var clonesPositioned = false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	viewport_dimensions = get_viewport().size
	if is_primary:
		create_clones(clone_scene_name)
		pass
	pass # Replace with function body.
	
func _physics_process(delta):
	if is_primary:
		#position_clones_transform(transform)
		pass
	pass
	
func create_clones(scene_name):
	var clone_scene = load(scene_name)
	for i in range(9):
		if i == 4:
			self.layers = 0b1
			self.collision_mask = 0b11
			clones.append(self)
			continue
		
		var clone: RigidBody2D = clone_scene.instance()
		clone.is_primary = false
		clone.primary = self
		clone.clone_position = i
		clone.layers = 0b10
		clone.collision_mask = 0b1
		get_parent().call_deferred("add_child", clone)
		clones.append(clone)
	position_clones_transform(transform)
	
func _integrate_forces(state):
	if is_primary:
		reposition_primary(state)
		pass
	
	if !is_primary:
		#var linear_velocity_difference = state.linear_velocity - last_linear_velocity
		#var angular_velocity_difference = state.angular_velocity - last_angular_velocity
		#primary.linear_velocity += linear_velocity_difference
		#primary.angular_velocity += angular_velocity_difference #Causing things not to rotate.
		state.linear_velocity = primary.linear_velocity
		state.angular_velocity = primary.angular_velocity
		position_clone(state)
		
	last_linear_velocity = state.linear_velocity
	last_angular_velocity = state.angular_velocity
	pass

func is_on_screen(x: float, y: float):
	return x > 0 and x < viewport_dimensions.x and y > 0 and y < viewport_dimensions.y

func is_on_screen_vec(position: Vector2):
	return position.x > 0 and position.x < viewport_dimensions.x and position.y > 0 and position.y < viewport_dimensions.y

# When the primary goes off screen we reposition it to the clone on the screen.
func reposition_primary(state: Physics2DDirectBodyState):
	if is_on_screen_vec(self.position):
		return
	
	for c in clones:
		if !c.is_primary && is_on_screen_vec(c.position):
			reassign_primary(c.clone_position, clones)
			break
	pass
	
func reset_clone_array_position(clones: Array) -> Array:
	var new_array: Array = [0, 0, 0, 0, 0, 0, 0, 0, 0]
	
	for c in clones:
		new_array[c.clone_position] = c
	
	return new_array
	
func swap_clones(clone_array: Array, target: int, new_position: int):
	clone_array[target].clone_position = new_position
	
# new_primary is a ClonePosition
func reassign_primary(new_primary: int, clones: Array):
	var clone_array = clones
	var new_primary_clone = clone_array[new_primary]
	var old_primary_clone = clone_array[ClonePosition.Primary]
	new_primary_clone.is_primary = true
	new_primary_clone.clones = clone_array
	new_primary_clone.primary = null
	new_primary_clone.layers = 0b1
	new_primary_clone.collision_mask = 0b11
	old_primary_clone.is_primary = false
	old_primary_clone.clones = null
	old_primary_clone.primary = new_primary_clone
	old_primary_clone.layers = 0b10
	old_primary_clone.collision_mask = 0b1
	
	match new_primary:
		ClonePosition.TopLeft:
			swap_clones(clone_array, ClonePosition.TopLeft, ClonePosition.Primary)
			swap_clones(clone_array, ClonePosition.Top, ClonePosition.Right)
			swap_clones(clone_array, ClonePosition.TopRight, ClonePosition.Left)
			swap_clones(clone_array, ClonePosition.Left, ClonePosition.Bottom)
			swap_clones(clone_array, ClonePosition.Primary, ClonePosition.BottomRight)
			swap_clones(clone_array, ClonePosition.Right, ClonePosition.BottomLeft)
			swap_clones(clone_array, ClonePosition.BottomLeft, ClonePosition.Top)
			swap_clones(clone_array, ClonePosition.Bottom, ClonePosition.TopRight)
			swap_clones(clone_array, ClonePosition.BottomRight, ClonePosition.TopLeft)
			pass
		ClonePosition.Top:
			swap_clones(clone_array, ClonePosition.TopLeft, ClonePosition.Left)
			swap_clones(clone_array, ClonePosition.Top, ClonePosition.Primary)
			swap_clones(clone_array, ClonePosition.TopRight, ClonePosition.Right)
			swap_clones(clone_array, ClonePosition.Left, ClonePosition.BottomLeft)
			swap_clones(clone_array, ClonePosition.Primary, ClonePosition.Bottom)
			swap_clones(clone_array, ClonePosition.Right, ClonePosition.BottomRight)
			swap_clones(clone_array, ClonePosition.BottomLeft, ClonePosition.TopLeft)
			swap_clones(clone_array, ClonePosition.Bottom, ClonePosition.Top)
			swap_clones(clone_array, ClonePosition.BottomRight, ClonePosition.TopRight)
			pass
		ClonePosition.TopRight:
			swap_clones(clone_array, ClonePosition.TopLeft, ClonePosition.Right)
			swap_clones(clone_array, ClonePosition.Top, ClonePosition.Left)
			swap_clones(clone_array, ClonePosition.TopRight, ClonePosition.Primary)
			swap_clones(clone_array, ClonePosition.Left, ClonePosition.BottomRight)
			swap_clones(clone_array, ClonePosition.Primary, ClonePosition.BottomLeft)
			swap_clones(clone_array, ClonePosition.Right, ClonePosition.Bottom)
			swap_clones(clone_array, ClonePosition.BottomLeft, ClonePosition.TopRight)
			swap_clones(clone_array, ClonePosition.Bottom, ClonePosition.TopLeft)
			swap_clones(clone_array, ClonePosition.BottomRight, ClonePosition.Top)
			pass
		ClonePosition.Left:
			swap_clones(clone_array, ClonePosition.TopLeft, ClonePosition.Top)
			swap_clones(clone_array, ClonePosition.Top, ClonePosition.TopRight)
			swap_clones(clone_array, ClonePosition.TopRight, ClonePosition.TopLeft)
			swap_clones(clone_array, ClonePosition.Left, ClonePosition.Primary)
			swap_clones(clone_array, ClonePosition.Primary, ClonePosition.Right)
			swap_clones(clone_array, ClonePosition.Right, ClonePosition.Left)
			swap_clones(clone_array, ClonePosition.BottomLeft, ClonePosition.Bottom)
			swap_clones(clone_array, ClonePosition.Bottom, ClonePosition.BottomRight)
			swap_clones(clone_array, ClonePosition.BottomRight, ClonePosition.BottomLeft)
			pass
		ClonePosition.Right:
			swap_clones(clone_array, ClonePosition.TopLeft, ClonePosition.TopRight)
			swap_clones(clone_array, ClonePosition.Top, ClonePosition.TopLeft)
			swap_clones(clone_array, ClonePosition.TopRight, ClonePosition.Top)
			swap_clones(clone_array, ClonePosition.Left, ClonePosition.Right)
			swap_clones(clone_array, ClonePosition.Primary, ClonePosition.Left)
			swap_clones(clone_array, ClonePosition.Right, ClonePosition.Primary)
			swap_clones(clone_array, ClonePosition.BottomLeft, ClonePosition.BottomRight)
			swap_clones(clone_array, ClonePosition.Bottom, ClonePosition.BottomLeft)
			swap_clones(clone_array, ClonePosition.BottomRight, ClonePosition.Bottom)
			pass
		ClonePosition.BottomLeft:
			swap_clones(clone_array, ClonePosition.TopLeft, ClonePosition.Bottom)
			swap_clones(clone_array, ClonePosition.Top, ClonePosition.BottomRight)
			swap_clones(clone_array, ClonePosition.TopRight, ClonePosition.BottomLeft)
			swap_clones(clone_array, ClonePosition.Left, ClonePosition.Top)
			swap_clones(clone_array, ClonePosition.Primary, ClonePosition.TopRight)
			swap_clones(clone_array, ClonePosition.Right, ClonePosition.TopLeft)
			swap_clones(clone_array, ClonePosition.BottomLeft, ClonePosition.Primary)
			swap_clones(clone_array, ClonePosition.Bottom, ClonePosition.Right)
			swap_clones(clone_array, ClonePosition.BottomRight, ClonePosition.Left)
			pass
		ClonePosition.Bottom:
			swap_clones(clone_array, ClonePosition.TopLeft, ClonePosition.BottomLeft)
			swap_clones(clone_array, ClonePosition.Top, ClonePosition.Bottom)
			swap_clones(clone_array, ClonePosition.TopRight, ClonePosition.BottomRight)
			swap_clones(clone_array, ClonePosition.Left, ClonePosition.TopLeft)
			swap_clones(clone_array, ClonePosition.Primary, ClonePosition.Top)
			swap_clones(clone_array, ClonePosition.Right, ClonePosition.TopRight)
			swap_clones(clone_array, ClonePosition.BottomLeft, ClonePosition.Left)
			swap_clones(clone_array, ClonePosition.Bottom, ClonePosition.Primary)
			swap_clones(clone_array, ClonePosition.BottomRight, ClonePosition.Right)
			pass
		ClonePosition.BottomRight:
			swap_clones(clone_array, ClonePosition.TopLeft, ClonePosition.BottomRight)
			swap_clones(clone_array, ClonePosition.Top, ClonePosition.BottomLeft)
			swap_clones(clone_array, ClonePosition.TopRight, ClonePosition.Bottom)
			swap_clones(clone_array, ClonePosition.Left, ClonePosition.TopRight)
			swap_clones(clone_array, ClonePosition.Primary, ClonePosition.TopLeft)
			swap_clones(clone_array, ClonePosition.Right, ClonePosition.Top)
			swap_clones(clone_array, ClonePosition.BottomLeft, ClonePosition.Right)
			swap_clones(clone_array, ClonePosition.Bottom, ClonePosition.Left)
			swap_clones(clone_array, ClonePosition.BottomRight, ClonePosition.Primary)
			pass
	
	clone_array = reset_clone_array_position(clone_array)
	
	var n = 0
	for c in clone_array:
		if !c.is_primary:
			c.primary = clone_array[ClonePosition.Primary]
	
	new_primary_clone.clones = clone_array
	
	
	
func position_clone(state: Physics2DDirectBodyState):
	if clone_position == ClonePosition.TopLeft:
		state.transform = Transform2D(primary.rotation, primary.position + -viewport_dimensions)
		
	if clone_position == ClonePosition.Top:
		state.transform = Transform2D(primary.rotation, primary.position + Vector2(0, -viewport_dimensions.y))
		
	if clone_position == ClonePosition.TopRight:
		state.transform = Transform2D(primary.rotation, primary.position + Vector2(viewport_dimensions.x, -viewport_dimensions.y))
		
	if clone_position == ClonePosition.Left:
		state.transform = Transform2D(primary.rotation, primary.position + Vector2(-viewport_dimensions.x, 0))
		
	if clone_position == ClonePosition.Right:
		state.transform = Transform2D(primary.rotation, primary.position + Vector2(viewport_dimensions.x, 0))
		
	if clone_position == ClonePosition.BottomLeft:
		state.transform = Transform2D(primary.rotation, primary.position + Vector2(-viewport_dimensions.x, viewport_dimensions.y))
		
	if clone_position == ClonePosition.Bottom:
		state.transform = Transform2D(primary.rotation, primary.position + Vector2(0, viewport_dimensions.y))
		
	if clone_position == ClonePosition.BottomRight:
		state.transform = Transform2D(primary.rotation, primary.position + viewport_dimensions)

func position_clones_transform(transform: Transform2D):
	var clone_offset: Vector2
	
	# Top-Left
	clone_offset = -viewport_dimensions
	clones[0].transform = transform.translated(clone_offset)
	
	# Top-Middle
	clone_offset.x = 0
	clones[1].transform = transform.translated(clone_offset)
	
	# Top-Right
	clone_offset.x = viewport_dimensions.x
	clones[2].transform = transform.translated(clone_offset)
	
	# Middle-Left
	clone_offset.y = 0
	clone_offset.x = -viewport_dimensions.x
	clones[3].transform = transform.translated(clone_offset)
	
	# Middle-Right
	clone_offset.x = viewport_dimensions.x
	clones[5].transform = transform.translated(clone_offset)
	
	# Bottom-Left
	clone_offset.y = viewport_dimensions.y
	clone_offset.x = -viewport_dimensions.x
	clones[6].transform = transform.translated(clone_offset)
		
	# Bottom_Middle
	clone_offset.x = 0
	clones[7].transform = transform.translated(clone_offset)
	
	# Bottom-Right
	clone_offset.x = viewport_dimensions.x
	clones[8].transform = transform.translated(clone_offset)
	

func position_clones():
	var clone_position = Vector2.ZERO
	
	# Top-Left
	clone_position.x = position.x - viewport_dimensions.x
	clone_position.y = position.y - viewport_dimensions.y
	clones[0].position = clone_position
	
	# Top-Middle
	clone_position.x = position.x
	clones[1].position = clone_position
	
	# Top-Right
	clone_position.x = position.x + viewport_dimensions.x
	clones[2].position = clone_position
	
	# Middle-Left
	clone_position.y = position.y
	clone_position.x = position.x - viewport_dimensions.x
	clones[3].position = clone_position
	
	# Middle-Right
	clone_position.x = position.x + viewport_dimensions.x
	clones[4].position = clone_position
	
	# Bottom-Left
	clone_position.y = position.y + viewport_dimensions.y
	clone_position.x = position.x - viewport_dimensions.x
	clones[5].position = clone_position
		
	# Bottom_Middle
	clone_position.x = position.x
	clones[6].position = clone_position
	
	# Bottom-Right
	clone_position.x = position.x + viewport_dimensions.x
	clones[7].position = clone_position
	
	for c in clones:
		c.rotation = rotation
	
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
