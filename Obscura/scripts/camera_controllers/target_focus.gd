class_name TargetFocusLerp
extends CameraControllerBase


@export var lead_speed: float = 600.0				# the speed at which the camera moves toward the direction of the input. This should be faster than the Vessel's movement speed.
@export var catchup_delay_duration: float = 1.0		# the time delay between when the target stops moving and when the camera starts to catch up to the target.
@export var catchup_speed: float = 300.0				# When the player has stopped, what speed shoud the camera move to match the vesse's position.
@export var leash_distance: float = 15.0			# The maxiumum allowed distance between the vessel and the center of the camera.
@export var delay_speed: float = 35.0 # the speed at which the camera moves toward the target when the target is not moving, during the delay period.


var catchup_timer: Timer


func _ready() -> void:
	super()
	position = target.position
	catchup_timer = Timer.new()
	catchup_timer.wait_time = catchup_delay_duration
	catchup_timer.one_shot = true
	add_child(catchup_timer)


func _process(delta: float) -> void:
	if !current:
		return
	
	if draw_camera_logic:
		draw_logic()
	
	super(delta)

func _physics_process(delta: float) -> void:
	if !current:
		return
	
	var target_velocity: Vector3 = target.velocity
	var target_position = target.global_position
	#var relative_position = target_position - global_position

	if target_velocity.length() < 0.1:
		if !catchup_timer.is_stopped():
			global_position = global_position.lerp(target_position, delta * (delay_speed / 100))
		else:
			global_position = global_position.lerp(target_position, delta * (catchup_speed / 100))
	else:
		catchup_timer.start()
		global_position = global_position.lerp(target_position + target_velocity.normalized() * leash_distance, delta * (lead_speed / 100))

	# Ensure leash_distance is respected
	var tpos = target.global_position
	var cpos = global_position

	# Boundary checks
	# left
	var diff_between_left_edges = (tpos.x - target.WIDTH / 2.0) - (cpos.x - leash_distance / 2.0)
	if diff_between_left_edges < 0:
		global_position.x += diff_between_left_edges
	# right
	var diff_between_right_edges = (tpos.x + target.WIDTH / 2.0) - (cpos.x + leash_distance / 2.0)
	if diff_between_right_edges > 0:
		global_position.x += diff_between_right_edges
	# top
	var diff_between_top_edges = (tpos.z - target.HEIGHT / 2.0) - (cpos.z - leash_distance / 2.0)
	if diff_between_top_edges < 0:
		global_position.z += diff_between_top_edges
	# bottom
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
