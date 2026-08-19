extends ParallaxBackground

var vitesse_background : float = 100.0 # سرعة الخلفية (بدلها كيف بغيتي)

func _process(delta: float) -> void:
	# هاد السطر كيجر الخلفية لتحت ديما
	scroll_offset.y += vitesse_background * delta
