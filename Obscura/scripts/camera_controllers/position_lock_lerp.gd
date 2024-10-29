class_name PositionLockLerp
extends CameraControllerBase


@export var follow_speed: float = 5.0
@export var catchup_speed: float = 10.0
@export var leash_distance: float = 15.0

func _ready() -> void:
	super()
	position = target.position


func _process(delta: float) -> void:
	if !current:
		return
	
	if draw_camera_logic:
		draw_logic()
	
	var tpos = target.global_position
	var cpos = global_position
	var distance_to_target = tpos.distance_to(cpos)
	print(distance_to_target)

	var speed: float
	if distance_to_target < leash_distance:
		# Transition to follow_speed
		speed = lerp(catchup_speed, follow_speed, distance_to_target / leash_distance)
	else:
		# Transition to catchup_speed
		speed = lerp(follow_speed, catchup_speed, distance_to_target / leash_distance)

	# Move the camera towards the target at the calculated speed
	global_position = cpos.lerp(tpos, speed * delta / distance_to_target)
	super(delta)


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
