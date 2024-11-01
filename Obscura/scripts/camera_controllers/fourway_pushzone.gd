class_name FourwayPushzone
extends CameraControllerBase


@export var push_ratio: float = 0.5
@export var pushbox_offset_percentage: float = 0.55			# outer bounds are pushbox
@export var speedup_zone_offset_percentage: float = 0.165	# inner bounds are speedup_zone
@export var square_bounds: bool = true
var outer_top_left: Vector2 = Vector2.ZERO			# The top left corner of the screen bounds
var outer_bottom_right: Vector2 = Vector2.ZERO		# The bottom right corner of the screen bounds
var inner_top_left: Vector2 = Vector2.ZERO			# The top left corner of the screen bounds
var inner_bottom_right: Vector2 = Vector2.ZERO		# The bottom right corner of the screen bounds


func _ready() -> void:
	super()
	position = target.position


func _process(delta: float) -> void:
	if !current:
		return

	if draw_camera_logic:
		draw_logic()

	# var tpos = target.global_position
	# global_position = Vector3(tpos.x, global_position.y, tpos.z)


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
	var full_bounds = Vector2(bottom_right_hit.x - top_left_hit.x, bottom_right_hit.z - top_left_hit.z)
	var outer_offset = full_bounds * (1.0 - pushbox_offset_percentage) / 2.0
	var inner_offset = full_bounds * (1.0 - speedup_zone_offset_percentage) / 2.0
	var position_offset = Vector2(position.x, position.z)

	if top_left_hit and bottom_right_hit:
		outer_top_left = Vector2(top_left_hit.x, top_left_hit.z) + outer_offset - position_offset
		inner_top_left = Vector2(top_left_hit.x, top_left_hit.z) + inner_offset - position_offset
		outer_bottom_right = Vector2(bottom_right_hit.x, bottom_right_hit.z) - outer_offset - position_offset
		inner_bottom_right = Vector2(bottom_right_hit.x, bottom_right_hit.z) - inner_offset - position_offset
		if square_bounds:
			# First determine the height for each box that would have been used above then find new top_left and bottom_right such that the width is the same as that height
			var outer_height = outer_bottom_right.y - outer_top_left.y
			var inner_height = inner_bottom_right.y - inner_top_left.y
			var outer_width = outer_bottom_right.x - outer_top_left.x
			var inner_width = inner_bottom_right.x - inner_top_left.x

			var outer_size = max(outer_height, outer_width)
			var inner_size = max(inner_height, inner_width)

			var outer_center = (outer_top_left + outer_bottom_right) / 2
			var inner_center = (inner_top_left + inner_bottom_right) / 2

			outer_top_left = outer_center - Vector2(outer_size / 2, outer_size / 2)
			outer_bottom_right = outer_center + Vector2(outer_size / 2, outer_size / 2)

			inner_top_left = inner_center - Vector2(inner_size / 2, inner_size / 2)
			inner_bottom_right = inner_center + Vector2(inner_size / 2, inner_size / 2)

	super(delta)


func _physics_process(delta: float) -> void:
	var target_position = target.global_position
	var relative_position = target_position - global_position

	# Check if the target is pushing against the outer box
	var pushing_left = relative_position.x - target.RADIUS < outer_top_left.x
	var pushing_right = relative_position.x + target.RADIUS > outer_bottom_right.x
	var pushing_top = relative_position.z - target.RADIUS < outer_top_left.y
	var pushing_bottom = relative_position.z + target.RADIUS > outer_bottom_right.y
	var target_is_moving = target.velocity.length() > 0.1

	if pushing_left:
		global_position.x += (relative_position.x - target.RADIUS - outer_top_left.x)
	elif pushing_right:
		global_position.x += (relative_position.x + target.RADIUS - outer_bottom_right.x)

	if pushing_top:
		global_position.z += (relative_position.z - target.RADIUS - outer_top_left.y)
	elif pushing_bottom:
		global_position.z += (relative_position.z + target.RADIUS - outer_bottom_right.y)

	# If target is entirely outside of the speedup zone and not pushing against the outer box, push the camera towards the target
	if not (pushing_left or pushing_right or pushing_top or pushing_bottom) or not target_is_moving:
		if (relative_position.x - target.RADIUS < inner_top_left.x or 		# left
			relative_position.x + target.RADIUS > inner_bottom_right.x or 	# right
			relative_position.z - target.RADIUS < inner_top_left.y or 		# top
			relative_position.z + target.RADIUS > inner_bottom_right.y):	# bottom
			var direction_to_target = (target_position - global_position).normalized()
			global_position += direction_to_target * target.BASE_SPEED * push_ratio * delta
		else:
			# Otherwise if the target is within the speedup zone, move the camera at the target's speed
			if pushing_left or pushing_right:
				global_position.x += target.velocity.x * delta
			else:
				global_position.x += target.velocity.x * push_ratio * delta

			if pushing_top or pushing_bottom:
				global_position.z += target.velocity.z * delta
			else:
				global_position.z += target.velocity.z * push_ratio * delta

	return


func draw_logic() -> void:
	draw_box(outer_top_left, outer_bottom_right, Color(1, 0, 0))  # Red outer box
	draw_box(inner_top_left, inner_bottom_right, Color(0, 1, 0))  # Green inner box


func draw_box(top_left: Vector2, bottom_right: Vector2, color: Color) -> void:
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
	material.albedo_color = color

	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)

	await get_tree().process_frame
	mesh_instance.queue_free()
