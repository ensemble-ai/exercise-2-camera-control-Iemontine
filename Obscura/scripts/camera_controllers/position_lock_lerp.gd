class_name PositionLockLerp
extends CameraControllerBase


@export var follow_speed: float = 5.0
@export var catchup_speed: float = 10.0
@export var leash_distance: float = 15.0	# Maximum allowed distance between camera and target
var current_speed: float = follow_speed

func _ready() -> void:
	super()
	position = target.position


func _process(delta: float) -> void:
	if !current:
		return
	
	if draw_camera_logic:
		draw_logic()

	super(delta)

func _physics_process(delta: float) -> void:
	if !current:
		return
		
	var target_position = target.global_position
	var relative_position = target_position - global_position
	var target_distance_from_center = relative_position.length() + relative_position.y

	var speed: float
	if target.velocity.length() < 0.1:
		speed = catchup_speed
	else:
		speed = follow_speed
		
	global_position = global_position.lerp(target_position, delta * (speed / 10))
	
	# Ensure leash_distance is respected
	var tpos = target.global_position
	var cpos = global_position
	
	# Boundary checks
	#left
	var diff_between_left_edges = (tpos.x - target.WIDTH / 2.0) - (cpos.x - leash_distance / 2.0)
	if diff_between_left_edges < 0:
		global_position.x += diff_between_left_edges
	#right
	var diff_between_right_edges = (tpos.x + target.WIDTH / 2.0) - (cpos.x + leash_distance / 2.0)
	if diff_between_right_edges > 0:
		global_position.x += diff_between_right_edges
	#top
	var diff_between_top_edges = (tpos.z - target.HEIGHT / 2.0) - (cpos.z - leash_distance / 2.0)
	if diff_between_top_edges < 0:
		global_position.z += diff_between_top_edges
	#bottom
	var diff_between_bottom_edges = (tpos.z + target.HEIGHT / 2.0) - (cpos.z + leash_distance / 2.0)
	if diff_between_bottom_edges > 0:
		global_position.z += diff_between_bottom_edges
	
	
func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var cross_size: float = 5.0
	var left: float = -cross_size / 2
	var right: float = cross_size / 2
	var top: float = -cross_size / 2
	var bottom: float = cross_size / 2

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(Vector3(right, 0, 0))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, 0))

	immediate_mesh.surface_add_vertex(Vector3(0, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(0, 0, bottom))
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1, 1, 1)

	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y + 1, global_position.z)

	await get_tree().process_frame
	mesh_instance.queue_free()

#
	#var mesh_instance := MeshInstance3D.new()
	#var immediate_mesh := ImmediateMesh.new()
	#var material := ORMMaterial3D.new()
	#
	#mesh_instance.mesh = immediate_mesh
	#mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	#
	#var left: float = top_left.x
	#var right: float = bottom_right.x
	#var top: float = top_left.y
	#var bottom: float = bottom_right.y
	#
	#immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	#immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
	#immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
	#
	#immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
	#immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
	#
	#immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
	#immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
	#
	#immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
	#immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
	#immediate_mesh.surface_end()
#
	#material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	#material.albedo_color = Color(1, 1, 1)
	#
	#add_child(mesh_instance)
	#mesh_instance.global_transform = Transform3D.IDENTITY
	#mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	#
	#await get_tree().process_frame
	#mesh_instance.queue_free()
