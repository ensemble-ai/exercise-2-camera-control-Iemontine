class_name FrameBoundAutoscroller
extends CameraControllerBase


@export var top_left: Vector2
@export var bottom_right: Vector2
@export var autoscroll_speed: Vector3


func _ready() -> void:
	super()
	position = target.position


func _process(delta: float) -> void:
	if !current:
		return
	
	if draw_camera_logic:
		draw_logic()
	
	# Ray-casting method to determine location of screen bounds using camera FOV
	var camera = self
	var top_left_ray = camera.project_ray_origin(Vector2(0, 0))
	var top_left_direction = camera.project_ray_normal(Vector2(0, 0))
	var bottom_right_ray = camera.project_ray_origin(Vector2(camera.get_viewport().size.x, camera.get_viewport().size.y))
	var bottom_right_direction = camera.project_ray_normal(Vector2(camera.get_viewport().size.x, camera.get_viewport().size.y))
	
	# Cast the rays originating from camera at FOV angles onto the x-z plane that the target is on
	var plane = Plane(Vector3(0, 1, 0), target.global_position.y)
	var top_left_hit = plane.intersects_ray(top_left_ray, top_left_direction)
	var bottom_right_hit = plane.intersects_ray(bottom_right_ray, bottom_right_direction)

	# Use hit locations to determine ideal top_left and bottom_right coordinates relative to vessel and screen dims
	var corner_offset = Vector2(0.5,0.5)
	var position_offset = Vector2(position.x, position.z)
	if top_left_hit and bottom_right_hit:
		top_left = Vector2(top_left_hit.x, top_left_hit.z) + corner_offset - position_offset
		bottom_right = Vector2(bottom_right_hit.x, bottom_right_hit.z) - corner_offset - position_offset
		
	# Update the camera's global position based on autoscroll_speed and delta
	global_position.x += autoscroll_speed.x * delta
	global_position.z += autoscroll_speed.z * delta

	var tpos = target.global_position
	var cpos = global_position
	
	# Boundary checks to ensure the player stays within the frame
	# Left
	if (tpos.x - target.WIDTH / 2.0) < cpos.x + top_left.x:
		tpos.x = cpos.x + top_left.x + target.WIDTH / 2.0
	# Right
	if (tpos.x + target.WIDTH / 2.0) > cpos.x + bottom_right.x:
		tpos.x = cpos.x + bottom_right.x - target.WIDTH / 2.0
	# Top
	if (tpos.z - target.HEIGHT / 2.0) < cpos.z + top_left.y:
		tpos.z = cpos.z + top_left.y + target.HEIGHT / 2.0
	# Bottom
	if (tpos.z + target.HEIGHT / 2.0) > cpos.z + bottom_right.y:
		tpos.z = cpos.z + bottom_right.y - target.HEIGHT / 2.0

	target.global_position = tpos

	super(delta)


func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	var left: float = top_left.x
	var right: float = bottom_right.x
	var top: float = top_left.y
	var bottom: float = bottom_right.y
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
	
	immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1, 1, 1)
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	await get_tree().process_frame
	mesh_instance.queue_free()
