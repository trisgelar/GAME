class_name UnicodeUtils
extends RefCounted

# Global Unicode utilities for Godot
# Ensures all text is properly encoded as UTF-8

static func sanitize_text(text: String) -> String:
	"""Sanitize text to ensure proper UTF-8 encoding for Godot"""
	if text == null:
		return ""
	
	# Convert to string and validate UTF-8
	var clean_text = str(text)
	
	# Remove any invalid Unicode characters
	var valid_chars = ""
	for i in range(clean_text.length()):
		var char_code = clean_text.unicode_at(i)
		# Only allow valid Unicode range (0x0 to 0x10FFFF)
		if char_code >= 0 and char_code <= 0x10FFFF:
			valid_chars += clean_text[i]
		else:
			print("UnicodeUtils: Removed invalid codepoint: ", char_code)
	
	# Ensure proper UTF-8 encoding
	var utf8_bytes = valid_chars.to_utf8_buffer()
	var utf8_string = utf8_bytes.get_string_from_utf8()
	
	return utf8_string

static func is_valid_unicode(text: String) -> bool:
	"""Check if text contains only valid Unicode characters"""
	if text == null or text.length() == 0:
		return true
		
	for i in range(text.length()):
		var char_code = text.unicode_at(i)
		if char_code < 0 or char_code > 0x10FFFF:
			return false
	
	return true

static func get_unicode_info(text: String) -> Dictionary:
	"""Get information about Unicode characters in text"""
	var info = {
		"length": text.length(),
		"byte_length": text.to_utf8_buffer().size(),
		"invalid_chars": [],
		"is_valid": true
	}
	
	for i in range(text.length()):
		var char_code = text.unicode_at(i)
		if char_code < 0 or char_code > 0x10FFFF:
			info.invalid_chars.append({"position": i, "codepoint": char_code})
			info.is_valid = false
	
	return info
