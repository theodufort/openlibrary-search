import json

def remove_json_objects(json_obj, keys_to_remove):
    """
    Remove specified keys from a JSON object recursively.
    
    Args:
        json_obj: The JSON object (dict or list) to process
        keys_to_remove: List of keys to remove from the JSON object
        
    Returns:
        Modified JSON object with specified keys removed
    """
    if isinstance(json_obj, dict):
        return {
            key: remove_json_objects(value, keys_to_remove)
            for key, value in json_obj.items()
            if key not in keys_to_remove
        }
    elif isinstance(json_obj, list):
        return [remove_json_objects(item, keys_to_remove) for item in json_obj]
    else:
        return json_obj
