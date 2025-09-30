extends HSlider

@export var bus_name: String

var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)

	value = db_to_linear(
		AudioServer.get_bus_volume_db(bus_index)
	)

func _on_value_changed(slider_value: float) -> void:
	var volume_setting: String = bus_name + '_volume'
#	NOTE: If you don't want this slider to affect saved global config settings, you can easily just pull that logic
#	out of Settings Manager
	Settings.set_setting(volume_setting.to_lower(), slider_value)
