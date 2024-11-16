extends Node

const LOCAL_MANIFEST_PATH := "user://cache/manifest.json"
const LOCAL_PACK_SAVE_FOLDER := "user://cache/packs"
	
func save_resource_pack(pack: ResourcePack) -> Error:
	DirAccess.make_dir_recursive_absolute(LOCAL_PACK_SAVE_FOLDER)
	return ResourceSaver.save(pack, __pack_save_path(pack.id), ResourceSaver.FLAG_COMPRESS)
	
func has_resource_pack(id: String) -> bool:
	return FileAccess.file_exists(__pack_save_path(id))

func get_resource_pack(id: String) -> ResourcePack:
	return ResourceLoader.load(__pack_save_path(id))
	
func __pack_save_path(id: String) -> String:
	return "%s/%s.res" % [LOCAL_PACK_SAVE_FOLDER, id]
