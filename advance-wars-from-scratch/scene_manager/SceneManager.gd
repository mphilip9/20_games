extends Node
#Shamelessly stolen from: https://baconandgames.itch.io/scene-manager-source-code/devlog/707099/scenemanager-v11


signal load_start(loading_screen: PackedScene)
signal scene_added(loaded_scene: Node, loading_screen: PackedScene)
signal load_complete(loaded_scene: Node)

signal _content_finished_loading(content: Node)
signal _content_invalid(content_path:String)
signal _content_failed_to_load(content_path:String)

var _loading_screen_scene:PackedScene = preload("res://scene_manager/Menus/loading_screen.tscn")# Add link to loading scene here
var _loading_screen: LoadingScreen
var _transition:String
var _content_path:String
var _load_progress_timer: Timer
var _load_scene_into:Node
var _scene_to_unload:Node
var _loading_in_progress:bool = false

# connect required internal signals on startup
func _ready() -> void:
	_content_invalid.connect(_on_content_invalid)
	_content_failed_to_load.connect(_on_content_failed_to_load)
	_content_finished_loading.connect(_on_content_finished_loading)

func _add_loading_screen(transition_type:String='start_wipe_from_right') -> void:
	_transition = "no_to_transition" if transition_type == "no_transition" else transition_type
	print('the transition here', _transition)
	_loading_screen = _loading_screen_scene.instantiate() as LoadingScreen #TODO: Define loading screen class
	get_tree().root.add_child(_loading_screen)
	_loading_screen.start_transition(_transition)


func swap_scenes(scene_to_load:String, load_into:Node=null, scene_to_unload:Node=null, transition_type:String='start_wipe_from_right') -> void:

	if _loading_in_progress:
		push_warning('SceneManager is already loading something')
		return

	_loading_in_progress = true
	if load_into == null: load_into = get_tree().root
	_load_scene_into = load_into
	_scene_to_unload = scene_to_unload

	_add_loading_screen(transition_type)
	_load_content(scene_to_load)

func _load_content(content_path:String) -> void:

	load_start.emit(_loading_screen)
#	This await ensures nothing gets loaded until that initial 'start' animation is finished. THis stops stuff from showing
# 	in the background while the animation is taking place.
	await _loading_screen.anim_player.animation_finished


	_content_path = content_path
	var loader: Error = ResourceLoader.load_threaded_request(content_path)
	if not ResourceLoader.exists(content_path) or loader == null:
		_content_invalid.emit(content_path)
		return

	_load_progress_timer = Timer.new()
	_load_progress_timer.wait_time = 0.1
	_load_progress_timer.timeout.connect(_monitor_load_status)

	get_tree().root.add_child(_load_progress_timer)
	_load_progress_timer.start()


func _monitor_load_status() -> void:
	var load_progress: Array = [] #What the hell is the type for this array?
	var load_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(_content_path, load_progress)
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			print('invalid resource match')
			_content_invalid.emit(_content_path)
			_load_progress_timer.stop()
			return
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			print('thread in progress')
			if _loading_screen != null:
				_loading_screen.update_bar(load_progress[0] * 100) # 0.1
		ResourceLoader.THREAD_LOAD_FAILED:
			print('thread failed')
			_content_failed_to_load.emit(_content_path)
			_load_progress_timer.stop()
			return
		ResourceLoader.THREAD_LOAD_LOADED:
			print('thread loaded')
			_load_progress_timer.stop()
			_load_progress_timer.queue_free()
			_content_finished_loading.emit(ResourceLoader.load_threaded_get(_content_path).instantiate())

func _on_content_failed_to_load(path:String) -> void:
	printerr("error: Failed to laod resourceL '%s'" % [path])

func _on_content_invalid(path:String) -> void:
	printerr("error: Cannot load resource: '%s' " % [path])

func _on_content_finished_loading(incoming_scene: Node) -> void:
	var outgoing_scene: Node = _scene_to_unload

	if outgoing_scene != null:
		if outgoing_scene.has_method("get_data") and incoming_scene.has_method("receive_data"):
			incoming_scene.receive_data(outgoing_scene.get_data())

	_load_scene_into.add_child(incoming_scene)

	scene_added.emit(incoming_scene, _loading_screen)

	if _scene_to_unload != null:
		if _scene_to_unload != get_tree().root:
			_scene_to_unload.queue_free()

	if incoming_scene.has_method("init_scene"):
		incoming_scene.init_scene()

	if _loading_screen != null:

		_loading_screen.finish_transition()
#		TODO: Is this awai necessary, because we already await in the loading screen itself
		await _loading_screen.anim_player.animation_finished


	if incoming_scene.has_method("start_scene"):
		incoming_scene.start_scene()

	_loading_in_progress = false
	load_complete.emit(incoming_scene)
