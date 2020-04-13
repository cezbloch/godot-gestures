extends Node2D

const MAX_POINTS = 10

var points = []

var last_dist = 0
var current_dist = 0
var zoom_rate = 0.05
var zoom_started = false

var last_angle = 0
var current_angle = 0
var rotate_rate = 1
var rotate_started = 0

signal on_zoom(val)
signal on_rotate(val)

var dragging = false

func _ready():
	for x in range(MAX_POINTS):
		points.append({pos=Vector2(), start_pos=Vector2(), state=false})
		
	set_process_input(true)
	set_process(true)
	
	connect("on_zoom", self, "scale_table")
	connect("on_rotate", self, "rotate_table")

func _input(event):
	# Handling gestures
	if event is InputEventScreenDrag:
		points[event.index].pos  = event.position
		
	if event is InputEventScreenTouch:
		points[event.index].state = event.pressed
		points[event.index].pos  = event.position
		if event.pressed:
			points[event.index].start_pos = event.position
		
	var count = 0
	for point in points:
		if point.state:
			count += 1
			
	if event is InputEventScreenTouch:
		if not event.pressed and count < 2:
			last_dist = 0
			current_dist = 0
			zoom_started = false
			
			last_angle = 0
			current_angle = 0
			rotate_started = 0
			
		if event.pressed and count == 2:
			zoom_started = true
			rotate_started = true
			
	if count == 2:
		handle_zoom(event)
		handle_rotate(event)

func handle_zoom(event):
	if event is InputEventScreenDrag:
		var dist = points[0].pos.distance_to(points[1].pos)
		if zoom_started:
			zoom_started = false
			last_dist = dist
			current_dist = dist
		else:
			current_dist = last_dist - dist
			last_dist = dist
		
		emit_signal("on_zoom", current_dist)
	
func handle_rotate(event):
	if event is InputEventScreenDrag:
		var angle = points[0].pos.angle_to_point(points[1].pos)
		if rotate_started:
			rotate_started = false
			last_angle = angle
			current_angle = angle
		else:
			current_angle = last_angle - angle
			last_angle = angle
		
		emit_signal("on_rotate", current_angle)

func scale_table(val):
	if abs(current_dist) > 0.1 and abs(current_dist) < 20:
		var s = $Sprite.scale
		var zoom = - current_dist * zoom_rate
		s.x = clamp(s.x + zoom, 1, 10)
		s.y = clamp(s.y + zoom, 1, 10)
		$Sprite.scale = s
	
func rotate_table(val):
	if abs(current_angle) > 0.001 and abs(current_angle) < 0.5:
		var r = $Sprite.rotation
		var a = current_angle * rotate_rate
		$Sprite.rotation = r - a

func _process(delta):
	 update()

func _draw():
	for point in points:
		var c = Color(1, 0, 0)
		if not point.state:
			c = Color(0, 0, 1)
			
		draw_circle(point.pos, 32, c)
		draw_circle(point.start_pos, 32, Color(0, 1, 0))
		draw_line(point.pos, point.start_pos, Color(1, 1, 0), 4)
