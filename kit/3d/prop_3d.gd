## Drops a generated GLB prop into a 3D scene with a box collider fitted to its mesh,
## so it can be clicked (input_ray_pickable) or bumped into.
##   var p := Prop3D.new(); p.ref = "sains/microscope"; add_child(p)
class_name Prop3D
extends StaticBody3D

signal clicked(ref: String)

@export var ref := "classroom/desk":
	set(v):
		ref = v
		if is_inside_tree():
			_build()
@export var spin_speed := 0.0  ## radians/sec, for showcase turntables
@export var hover_lift := 0.0

var model: Node3D
var aabb := AABB()


func _ready() -> void:
	input_ray_pickable = true
	_build()


func _build() -> void:
	for c in get_children():
		c.queue_free()
	var scene := EduAssets.model(ref)
	if scene == null:
		push_warning("Prop3D: unknown model " + ref)
		return
	model = scene.instantiate()
	add_child(model)
	aabb = _mesh_aabb(model, Transform3D.IDENTITY)
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = aabb.size.max(Vector3.ONE * 0.01)
	col.shape = box
	col.position = aabb.get_center()
	add_child(col)


static func _mesh_aabb(n: Node, xf: Transform3D) -> AABB:
	var out := AABB()
	var first := true
	var t: Transform3D = xf * ((n as Node3D).transform if n is Node3D else Transform3D.IDENTITY)
	if n is MeshInstance3D and (n as MeshInstance3D).mesh:
		out = t * (n as MeshInstance3D).mesh.get_aabb()
		first = false
	for c in n.get_children():
		var a := _mesh_aabb(c, t)
		if a.size != Vector3.ZERO:
			out = a if first else out.merge(a)
			first = false
	return out


func _process(delta: float) -> void:
	if spin_speed != 0.0 and model:
		model.rotate_y(spin_speed * delta)


func _input_event(_cam: Camera3D, event: InputEvent, _pos: Vector3, _n: Vector3, _idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Audio.sfx("pop", 0.1)
		if model:
			var tw := create_tween()
			tw.tween_property(model, "scale", Vector3.ONE * 1.12, 0.08)
			tw.tween_property(model, "scale", Vector3.ONE, 0.18).set_trans(Tween.TRANS_BACK)
		clicked.emit(ref)
