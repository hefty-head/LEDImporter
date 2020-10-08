tool
extends Reference


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var source_path_globe

# Called when the node enters the scene tree for the first time.
func build(source_path, options):
	source_path_globe = source_path
	var map = read_file(source_path)
	#code to validate map
	if typeof(map) != TYPE_DICTIONARY:
		return ERR_INVALID_DATA

	var defs = {
		"layers": map.defs.layers,
		"entities": map.defs.entities,
		"tilesets": map.defs.tilesets,
		"enums": map.defs.enums,
		"externalEnums": map.defs.externalEnums
	} #store the def info in a dictionary for easy access
	#printerr(defs["tilesets"])
	var levelsDict = {
		"identifier" : map.levels[0].identifier, 
		"uid" : map.levels[0], 
		"pxWid" : map.levels[0], 
		"pxHei" : map.levels[0], #add the .pxHei and whatever to the other ones
		"layerInstances" : map.levels[0] 
	}#this is useless lol
	
	var root = Node2D.new()
	root.set_name("defaultName")
	root.add_child(Sprite.new())
	
	for layer in map.levels[0].layerInstances:
		make_layer(layer, root, root, map.defs)
	return root
	
func make_layer(layer, parent, root, data):
	#update this to identify the type of layer and build based on that
	var layerType = layer.__identifier

	printerr(layerType)
	#idk if i need the othr info in the layerInstance
	if layerType == "Tiles": #change this to a switch statement
		
		var gridTiles = layer.gridTiles
		#printerr(intGrid)
		var tilemap = TileMap.new()
		tilemap.cell_size = Vector2(layer.__gridSize,layer.__gridSize)
		tilemap.set_name("gridTiles")
		tilemap.visible = true
		tilemap.mode = TileMap.MODE_SQUARE
		
		tilemap.tile_set = build_layer_tileset(data, layer.__cWid, layer.__cHei)
		for tiles in gridTiles:
			tilemap.set_cell(tiles["__x"]/layer.__gridSize, tiles["__y"]/layer.__gridSize, tiles["tileId"], 0, 0, 0) #get rid of these magic numbers
		parent.add_child(tilemap)
		tilemap.set_owner(root)
	if layerType == "IntGrid":
		#printerr(layer.autoTiles)
		var autoTiles = layer.autoTiles
		var tilemap = TileMap.new()
		tilemap.cell_size = Vector2(layer.__gridSize - 1,layer.__gridSize - 1)
		tilemap.set_name("intGrid")
		tilemap.visible = true
		tilemap.mode = TileMap.MODE_SQUARE
		
		tilemap.tile_set = build_layer_tileset(data, layer.__cWid, layer.__cHei)
		for tile in autoTiles:
			for innerTile in tile.results:
				var flips = innerTile.flips
				var horizFlip = false
				var vertFlip = false
				if flips == 0:
					pass
				elif flips == 1:
					horizFlip  = true
				elif flips == 2:
					vertFlip = true
				elif flips == 3:
					horizFlip = true
					vertFlip = true
				for tileList in innerTile.tiles:
					#printerr(tileList)
					tilemap.set_cell(tileList["__x"]/layer.__gridSize, tileList["__y"]/layer.__gridSize, tileList["tileId"], horizFlip, vertFlip, 0)
		parent.add_child(tilemap)
		tilemap.set_owner(root)
	if layerType == "AutoLayer":
		pass#print(layer)
func build_layer_tileset(data, imageX, imageY): #something is wrong with how you build these
	var result = TileSet.new()
	#  tilecount = imageWidth/tileWidth * imageHeight/tileHeight
	var tilecount = data.tilesets[0].pxWid/data.tilesets[0].tileGridSize  * data.tilesets[0].pxHei/data.tilesets[0].tileGridSize
	var i = 0
	var x = 0
	var y = 0
	var column = 0
	var columns = data.tilesets[0].pxWid/data.tilesets[0].tileGridSize
	printerr(columns)
	var id = result.get_last_unused_tile_id()
	var tilesize = Vector2(data.tilesets[0].tileGridSize,data.tilesets[0].tileGridSize)
	while i < tilecount:
		var tilepos = Vector2(x, y)
		var region = Rect2(tilepos, tilesize )
		
		result.create_tile(id)
		var idString = String(id)
		result.tile_set_name(id, idString)
		#printerr(data.tilesets[0].relPath)
		var image = load_image(data.tilesets[0].relPath, source_path_globe, null)
		result.tile_set_texture(id, image)
		
		result.tile_set_region(id, region) #there is somthing funky going on with how the tilests are being arranged
		i+=1
		column+=1
		x+= tilesize.x
		id+=1
		if (columns > 0 and column >= columns) or x > data.tilesets[0].pxWid or x + tilesize.x > data.tilesets[0].pxWid:
			x = 0
			y+= tilesize.y 
			column = 0
	return result
func build_tileset_for_scene(tilesets, source_path, options):
	pass#should build a tileset from LeD info
func read_tileset_file(path):
	var file = File.new()
	var err = file.open(path, File.READ)
	if err != OK:
		return err

	var content = JSON.parse(file.get_as_text())
	if content.error != OK:
		printerr("Error parsing JSON: " + content.error_string)
		return content.error

	return content.result

func parse_jason():
	var file = File.new()
	#var err = validate_file
	#err = f.open(ts_source_path, File.READ)
	#if err != OK:
	#	print_error("Error opening tileset '%s'." % [ts.source])
	#	return err   #write error catching functions
	var json_res = JSON.parse(file.get_as_text())
	#write error catch
	var result = json_res.result
	#error check to make sure result is dictionary
	
func read_file(path):
	var file = File.new()
	file.open(path, file.READ)
	var content = JSON.parse(file.get_as_text())
	
	
	return content.result


func load_image(rel_path, source_path, options):
	var flags =  Texture.FLAGS_DEFAULT
	var embed =  false

	var ext = rel_path.get_extension().to_lower()
	if ext != "png" and ext != "jpg":
		printerr("Unsupported image format: %s. Use PNG or JPG instead." % [ext])
		return ERR_FILE_UNRECOGNIZED

	var total_path = rel_path
	if rel_path.is_rel_path():
		total_path = ProjectSettings.globalize_path(source_path.get_base_dir()).plus_file(rel_path)
	total_path = ProjectSettings.localize_path(total_path)

	var dir = Directory.new()
	if not dir.file_exists(total_path):
		printerr("Image not found: %s" % [total_path])
		return ERR_FILE_NOT_FOUND

	if not total_path.begins_with("res://"):
		# External images need to be embedded
		embed = true

	var image = null
	if embed:
		image = ImageTexture.new()
		image.load(total_path)
	else:
		image = ResourceLoader.load(total_path, "ImageTexture")

	if image != null:
		image.set_flags(flags)

	return image
