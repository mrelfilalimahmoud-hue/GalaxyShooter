extends Sprite2D

var speed : float = 40.0         
var rotation_speed : float = 0.5  
var velocity : Vector2 = Vector2.ZERO
var screen_size : Vector2

func _ready():
	screen_size = get_viewport_rect().size
	speed = randf_range(30.0, 70.0)
	rotation_speed = randf_range(-0.8, 0.8)
	
	scale = Vector2(randf_range(0.3, 0.6), randf_range(0.3, 0.6))
	modulate.a = randf_range(0.6, 0.9) # الشفافية الواضحة اللي قدينا
	
	# نختاروا اتجاه عشوائي للحركة (ماشي غير لتحت بوحده)
	var angle = randf_range(0, PI) # زاويّة لتحت (نصف الدائرة السفلي باش ديما يدوزو فالشاشة)
	velocity = Vector2(cos(angle), sin(angle)) * speed

func _process(delta):
	# التحرك بناءً على الاتجاه العشوائي
	global_position += velocity * delta
	rotation += rotation_speed * delta
	
	# إلا خرجو من الشاشة من أي قنت، نرجعوهم لفوق من بلاصة جديدة
	if global_position.y > screen_size.y + 50 or global_position.x < -100 or global_position.x > screen_size.x + 100:
		global_position = Vector2(randf_range(0, screen_size.x), -50.0)
