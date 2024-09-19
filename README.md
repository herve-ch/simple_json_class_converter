# SimpleJsonClassConverter

This GDScript provides a set of utility functions for converting Godot classes to JSON dictionaries and vice versa. 

## Features

* **Serialization (Class to JSON):**
	* Converts Godot class instances to JSON-like dictionaries.
	* Handles nested objects and arrays recursively.
	* Supports saving JSON data to files (with optional encryption).
	* Will store all scripts names and types in JSON.
	* Support resources.
	* Supports dictionnaries of any type of key
	* Supports inheritence
* **Deserialization (JSON to Class):**
	* Loads JSON data from files (with optional decryption).
	* No need to specify target class as the script will automatically get the types from the JSON format.
	* Converts JSON strings and dictionaries into class instances.
	* Handles nested object structures.

* **Automatic Type Recognition:**  Intelligently handles various data types.

## Installation

1. Create a new script file named `SimpleJsonClassConverter.gd` (or similar) in your Godot project.
2. Copy and paste the code provided into the script file.

## Usage

### 1. Class to JSON

**a) Convert a Class Instance to a JSON Dictionary:**

```gdscript
# Assume you have a class named 'SaveData':
var save_data = SaveData.new()
# ... (Set properties of save_data)

# Convert to a JSON dictionary:
var json_data = SimpleJsonClassConverter.class_to_json(save_data) 

# json_data now contains a Dictionary representation of your class instance
```


**b) Save JSON Data to a File:**

```gdscript
var file_success: bool = SimpleJsonClassConverter.store_json_file("user://saves/save_data.json", json_data, "my_secret_key")  # Optional encryption key

# Check if saving was successful:
if file_success:
	print("Player data saved successfully!")
else:
	print("Error saving player data.") 
```

### 2. JSON to Class

**a) Load JSON Data from a File:**

```gdscript
var loaded_data: SaveData = SimpleJsonClassConverter.json_file_to_class("user://saves/save_data.json", "my_secret_key") # Optional decryption key

if loaded_data:
	# ... (Access properties of the loaded_data)
else:
	print("Error loading player data.")
```

**b) Convert a JSON Dictionary to a Class Instance:**

```gdscript
var json_dict = { "name": "Bob", "score": 2000 }
var player_data: PlayerData = SimpleJsonClassConverter.json_to_class(json_dict)
```

## Important Notes
* **Use class_name:** Only object with a class_name will get serialized

* **Exported Properties:** Only exported properties (those declared with `@export`) or properties with the `[PROPERTY_USAGE_STORAGE]` meta will be serialized and deserialized.

* **Properties naming:** Don't use "gd_script" or "gd_type" in any property name or dictionary key as they are used for internal type storage for Serialization and Deserialization.

## Credits

Original code: https://github.com/EiTaNBaRiBoA/JsonClassConverter.

Thanks to him
