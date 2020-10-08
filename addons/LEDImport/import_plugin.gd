tool
extends EditorImportPlugin

enum Presets { DEFAULT }

const reader = preload("LEDReader.gd")


func get_importer_name():
	return "led_level"
func get_visible_name():
	return "LeD JSON Level"
func get_recognized_extensions():
	return ["json"]
	#remember to sanitize bc json common
func get_save_extension():
	return "scn"	

func get_resource_type():
	return "PackedScene"
func get_preset_count():
	return Presets.size()
	
func get_preset_name(preset):
	match preset:
		Presets.DEFAULT:
			return "Default"
			
func get_import_options(preset):
	match preset:
		Presets.DEFAULT:
			return [{
				"name": "learning",
				"default_value": false
			}]
	return []
func get_option_visibility(option, options):
	return true


func import(source_file, save_path, options, r_platform_variants, r_gen_files):
	
	
	var led_reader = reader.new()
	var scene = led_reader.build(source_file, options)
	var packed_scene = PackedScene.new()
	packed_scene.pack(scene)
	
	return ResourceSaver.save("%s.%s" % [save_path, get_save_extension()], packed_scene)
	
