class_name SimpleJsonClassConverter

#region Json to Class

## Loads a JSON file and converts its contents into a Godot class instance.
static func json_file_to_class(file_path: String, security_key: String = "") -> Object:
	var file: FileAccess
	if not FileAccess.file_exists(file_path):
		return
	if security_key.length() == 0:
		file = FileAccess.open(file_path, FileAccess.READ)
	else:
		file = FileAccess.open_encrypted_with_pass(file_path, FileAccess.READ, security_key)
	var json_string = file.get_as_text()
	var json = JSON.new()
	var parse_result: Error = json.parse(json_string)
	if parse_result != Error.OK:
		return
	return json_to_class(json.data)
	
## Converts a JSON string into a Godot class instance.
static func json_string_to_class(json_string: String) -> Object:
	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_string)
	if parse_result == Error.OK:
		return json_to_class(json.data)
	return null

## Converts a JSON dictionary into a Godot class instance.
## This is the core deserialization function.
static func json_to_class(json):
	if json is Array:
		var array: Array = []
		for element in json:
			array.append(json_to_class(element))
		return array
	elif json is Dictionary:
		var _class: Object
		if json.has("gd_script"):
			# Dictionary with a gd_script, we must convert into an object
			var script_type = null
			script_type = get_gdscript(json.gd_script)
			# Create an instance of the target class
			_class = script_type.new() as Object
			# Iterate through each key-value pair in the JSON dictionary
			for key: String in json.keys():
				if key != "gd_script":
					var value: Variant = json[key]
					if value is Array:
						var array_remp: Array = json_to_class(value)
						for obj_array in array_remp:
							_class.get(key).append(obj_array)
					else:
						_class[key] = json_to_class(value)
			return _class
		elif json.has("gd_type"):
			if json["gd_type"] == "Resource":
				return ResourceLoader.load(json["value"])
			elif json["gd_type"] == "String":
				return json["value"]
			else:
				return str_to_var(json["value"])
		else:
			# It is a normal Godot dictionary
			var dictionary = {}
			for key: String in json.keys():
				var value: Variant = json[key]
				dictionary[key] = json_to_class(value)
			return dictionary

## Helper function to find a GDScript by its class name.
static func get_gdscript(hint_class: String) -> GDScript:
	for className: Dictionary in ProjectSettings.get_global_class_list():
		if className. class == hint_class:
			return load(className.path)
	return null

#endregion

#region Class to Json
## Stores a JSON dictionary to a file, optionally with encryption.
static func store_json_file(file_path: String, data: Dictionary, security_key: String = "") -> bool:
	var file: FileAccess
	if security_key.length() == 0:
		file = FileAccess.open(file_path, FileAccess.WRITE)
	else:
		file = FileAccess.open_encrypted_with_pass(file_path, FileAccess.WRITE, security_key)
	if not file:
		printerr("Error writing to a file")
		return false
	var json_string: String = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()
	return true

## Converts a Godot class instance into a JSON string.
static func class_to_json_string(_class) -> String:
	return JSON.stringify(class_to_json(_class))

## Converts a Godot class instance into a JSON dictionary.
## This is the core serialization function.
static func class_to_json(_class):
	var dictionary: Dictionary = {}
	
	if _class is Object:
		var script = _class.get_script()
		if script:
			# Store the script name for reference during deserialization
			dictionary["gd_script"] = script.get_global_name()
			var properties: Array = _class.get_property_list()

			# Iterate through each property of the class
			for property: Dictionary in properties:
				var property_name: String = property["name"]
				# Skip the built-in 'script' property
				if property_name == "script":
					continue
				var property_value: Variant = _class.get(property_name)

				# Only serialize properties that are exported or marked for storage
				if not property_name.is_empty() and property.usage >= PROPERTY_USAGE_SCRIPT_VARIABLE and property.usage & PROPERTY_USAGE_STORAGE > 0:
					dictionary[property_name] = class_to_json(property_value)
		else:
			# Basic resource without a script attached
			dictionary["gd_type"] = "Resource"
			dictionary["value"] = _class.resource_path
	elif _class is Dictionary:
		for key: String in _class.keys():
			var value: Variant = _class[key]
			dictionary[key] = class_to_json(value)
	elif _class is Array:
		var array = []
		for element in _class:
			array.append(class_to_json(element))
		return array
	# Other non Object types
	else:
		dictionary["gd_type"] = type_string(typeof(_class))
		if (type_string(typeof(_class)) == "String"):
			dictionary["value"] = _class
		else:
			dictionary["value"] = var_to_str(_class)
	return dictionary
#endregion
