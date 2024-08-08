# Core script, initialize game pendencies
extends Node3D

const root = &"res://Scripts/"
static var nodes = {}

# --== INIT ==--
func attach_child(ref: RefCounted, file: String) -> void:
	var instance = ref.new()
	Phaux.debug( ["Attaching node instance:", file] )
	add_child(instance)
	nodes[file] = instance

func load_files_from_dir(dir: String) -> void:
	var path = DirAccess.open(dir)
	if path:
		path.list_dir_begin()
		var file = path.get_next()
		
		while file != "":
			dir = path.get_current_dir() + "/" + file
			if path.current_is_dir():
				Phaux.debug( ["Crawling dir:", dir] )
				load_files_from_dir(dir)
			else:
				Phaux.debug( ["Loading file: ", file, "..."], false )
				var file_node = ResourceLoader.load(dir)
				if file_node == null:
					Phaux.error("Failed to load file: " + file, path.get_line())
				else:
					attach_child(file_node, file)
				Phaux.debug( ["Finished loading file:", file] )
			file = path.get_next()

func _ready():
	Phaux.debug( ["--- BOOTING ---"] )
	Phaux.debug( ["Phaux Engine v"+str(Phaux.version)] )
	Phaux.debug( ["--- LOADING CLASSES/CORE ---"] )
	load_files_from_dir( root + "Classes/Core" )
	Phaux.debug( ["--- FINISHED BOOTING ---"] )
