# Core script, initialize game pendencies
extends Node3D

var Phaux = {
	"name": "Phaux",
	"version": 0.1,
	"pretty": ":= PHAUX =:\t"
}

func debug(array_msg: Array[String]):
	print(Phaux.pretty, "\t".join(array_msg))

# --== INIT ==--
func load_files_from_dir(dir: String):
	var path = DirAccess.open(dir)
	if path:
		path.list_dir_begin()
		var file = path.get_next()
		
		while file != "":
			dir = path.get_current_dir() + "/" + file
			if path.current_is_dir():
				debug( ["Crawling dir:", dir] )
				load_files_from_dir(dir)
			else:
				debug( ["Loading file:", file] )
				var file_node = load(dir)
				var node = file_node.new()
				add_child(node)
				debug( ["Finished loading file:", file] )
			file = path.get_next()

func _ready():
	debug( ["--- BOOTING ---"])
	debug( ["Phaux Engine v"+str(Phaux.version)] )
	debug( ["--- LOADING CLASSES/CORE ---"])
	load_files_from_dir("res://Scripts/Classes/Core")
	debug( ["--- FINISHED BOOTING ---"])