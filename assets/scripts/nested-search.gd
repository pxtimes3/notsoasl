extends Node

# Helper function to perform the recursive search for a key in a nested dictionary
func search_key(haystack: Dictionary, needle: String) -> Variant:
	for key in haystack.keys():
		if key == needle:
			return haystack[key]
		elif typeof(haystack[key]) == TYPE_DICTIONARY and key not in ["structure"]:
			var result = search_key(haystack[key], needle)
			if result != null:
				return result
	return null

# Main function to find the dictionary associated with a key in the nested dictionary
func find_key_dict(haystack: Dictionary, needle: String) -> Variant:
	return search_key(haystack, needle)

func _ready():
	var nested_dict = {
		"company-hq": {
			"radio": true,
			"entities": {
				"coc": 1,
				"ceo": 1,
				"cfs": 1,
				"cs": 1,
				"b": 1,
				"mess": 1
			}
		},
		"rifleplatoon": {
			"structure": {
				"rifleplatoon-hq": 1,
				"rifleplatoon-squad": 3
			},
			"rifleplatoon-hq": {
				"count": 1,
				"radio": true,
				"entities": {
					"pltlead": 1,
					"pltsgt": 1,
					"riflegren": 1,
					"rifleman": 1,
					"sniper": 1
				}
			},
			"rifleplatoon-squad": {
				"radio": true,
				"entities": {
					"squadlead": 1,
					"squadleadasst": 1,
					"bar": 1,
					"barass": 1,
					"ammo": 1,
					"riflegren": 2,
					"rifleman": 5
				}
			}
		}
	}

	var needles = ["company-hq", "rifleplatoon-hq", "rifleplatoon-squad"]
	for needle in needles:
		var dict_for_key = find_key_dict(nested_dict, needle)
		print("Dictionary for '%s': %s" % [needle, dict_for_key])
