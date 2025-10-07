# Indonesia 3D Map Coordinate System

**Date**: 2025-09-17  
**Status**: ✅ Complete  
**Author**: AI Assistant  

## 🗺️ Final Coordinate Mapping

This document records the final, tested coordinates for the Indonesia 3D map system, providing a reference for future development and maintenance.

## 📍 Region Coordinates

### **Production Coordinates**
These coordinates have been tested and confirmed to work correctly with the 3D Indonesia map:

```gdscript
# Final working coordinates for region placeholders
var region_data: Array[Dictionary] = [
	{
		"id": "indonesia_barat",
		"name": "Indonesia Barat",
		"description": "Jakarta & Traditional Markets",
		"position": Vector3(-120.8738, 19.7, 66.2856),
		"scene_path": "res://Scenes/IndonesiaBarat/PasarScene.tscn",
		"color": Color.RED
	},
	{
		"id": "indonesia_tengah", 
		"name": "Indonesia Tengah",
		"description": "NTB & Mount Tambora",
		"position": Vector3(-13.45436, 19.7, 77.36392),
		"scene_path": "res://Scenes/IndonesiaTengah/TamboraScene.tscn",
		"color": Color.GREEN
	},
	{
		"id": "indonesia_timur",
		"name": "Indonesia Timur",
		"description": "Papua Highlands", 
		"position": Vector3(160.3569, 19.7, -1.466873),
		"scene_path": "res://Scenes/IndonesiaTimur/PapuaScene_Terrain3D.tscn",
		"color": Color.BLUE
	}
]
```

## 🧭 Coordinate System Analysis

### **Godot 3D Coordinate System**
```
X axis: Left ← → Right (horizontal movement)
Y axis: Down ↓ ↑ Up (vertical height)
Z axis: Back ← → Forward (depth)
```

### **Map Orientation**
The Indonesia map (`pulau_indonesia_rework HUT RI.obj`) is positioned with:
- **Transform**: `Transform3D(0.5, 0, 0, 0, 0.5, 0, 0, 0, 0.5, -5, 0.1, 0)`
- **Scale**: 0.5x in all dimensions
- **Position**: Offset by (-5, 0.1, 0)

## 📊 Coordinate Breakdown

### **Indonesia Barat (Jakarta Region)**
- **X**: -120.8738 (Far left of map)
- **Y**: 19.7 (Consistent height above terrain)
- **Z**: 66.2856 (Forward position)
- **Real-world Location**: Java/Jakarta area
- **Game Scene**: Traditional Market (Pasar Scene)

### **Indonesia Tengah (Central Region)**  
- **X**: -13.45436 (Center-left of map)
- **Y**: 19.7 (Consistent height above terrain)
- **Z**: 77.36392 (Forward position)
- **Real-world Location**: Nusa Tenggara Barat (NTB)
- **Game Scene**: Mount Tambora Scene

### **Indonesia Timur (Eastern Region)**
- **X**: 160.3569 (Far right of map)
- **Y**: 19.7 (Consistent height above terrain) 
- **Z**: -1.466873 (Slightly back position)
- **Real-world Location**: Papua Highlands
- **Game Scene**: Papua Terrain3D Scene

## 🎯 Height Considerations

### **Y-Axis (Vertical) Settings**
- **Placeholder Height**: Y = 19.7 (final positioned height)
- **Minimum Drag Height**: Y = 10.0 (enforced during drag & drop)
- **Sea Level**: Y = -0.5 (blue sea plane)
- **Indonesia Map**: Y = 0.1 (terrain surface)

### **Height Calculation**
```gdscript
# Height enforcement during drag & drop
var new_y = max(10.0, ground_pos.y + 5.0)
node.position = Vector3(ground_pos.x, new_y, ground_pos.z)
```

## 🗺️ Geographical Mapping

### **Real Indonesia vs 3D Model**
The coordinates roughly correspond to these real Indonesian regions:

| Region | 3D Coordinate | Real Location | Key Islands |
|--------|---------------|---------------|-------------|
| Barat  | (-120, 19, 66) | Western Indonesia | Java, Sumatra |
| Tengah | (-13, 19, 77)  | Central Indonesia | Nusa Tenggara, Bali |
| Timur  | (160, 19, -1)  | Eastern Indonesia | Papua, Maluku |

### **Scale Reference**
- **Map Scale**: 0.5x original OBJ model size
- **Sea Coverage**: 100x100 units (covers entire archipelago)
- **Placeholder Scale**: 4x original mesh size for visibility

## 🔧 Technical Implementation

### **Coordinate Storage**
```gdscript
# Position stored in region_data array
func _set_region_position(region_id: String, pos: Vector3):
    for i in region_data.size():
        if region_data[i].id == region_id:
            region_data[i].position = pos
            return
```

### **Position Retrieval**
```gdscript
# Get position for specific region
func get_region_position(region_id: String) -> Vector3:
    for region in region_data:
        if region.id == region_id:
            return region.position
    return Vector3.ZERO
```

### **Debug Display**
```gdscript
# Real-time coordinate display (F3 key)
func _update_debug_label():
    var text := "Placeholders:\n"
    for region in region_data:
        var placeholder_node = region_placeholders.get(region.id, null)
        if placeholder_node:
            var n: MeshInstance3D = placeholder_node as MeshInstance3D
            text += region.name + ": " + str(n.position) + "\n"
    lbl.text = text
```

## 🎮 User Interaction

### **Coordinate Adjustment Tools**
- **I Key**: Scatter to preset wide positions for easy access
- **O Key**: Snap back to saved region coordinates  
- **Drag & Drop**: Real-time coordinate adjustment
- **F3 Key**: Toggle coordinate display overlay

### **Scatter Positions**
```gdscript
# Wide scatter positions for easy placeholder access
var offsets := {
    "indonesia_barat": Vector3(-12, 12.0, -8),
    "indonesia_tengah": Vector3(0, 12.0, 12),  
    "indonesia_timur": Vector3(12, 12.0, -12)
}
```

## 📋 Coordinate History

### **Development Progression**
1. **Initial**: Random positions, placeholders not visible
2. **First Fix**: Y = 1.0, placeholders barely above terrain
3. **Second Fix**: Y = 5.0, better visibility
4. **Final**: Y = 19.7, perfect positioning after user testing

### **Key Discoveries**
- **Y is UP**: Critical realization that Y axis controls height
- **Height Enforcement**: Minimum Y values prevent underground placement
- **Coordinate Persistence**: User-adjusted positions must be saved
- **Visual Feedback**: Debug overlay essential for coordinate work

## 🔮 Future Coordinate Work

### **Potential Enhancements**
1. **Sub-region Coordinates**: Specific city/landmark positions
2. **Dynamic Height**: Terrain-following placeholder positioning  
3. **Coordinate Validation**: Bounds checking for valid map areas
4. **Animation Paths**: Smooth transitions between coordinates
5. **Save/Load System**: Persistent coordinate storage

### **Coordinate Extensions**
```gdscript
// Potential expanded coordinate system
var detailed_locations = {
    "jakarta": Vector3(-125, 19.7, 70),
    "bandung": Vector3(-115, 19.7, 65),
    "denpasar": Vector3(-10, 19.7, 75),
    "mataram": Vector3(-8, 19.7, 80),
    "jayapura": Vector3(165, 19.7, -5),
    "manokwari": Vector3(155, 19.7, 5)
}
```

## ✅ Validation Checklist

- [x] All three regions have confirmed working coordinates
- [x] Coordinates place placeholders above terrain surface
- [x] Placeholders are positioned over appropriate map regions
- [x] Height enforcement prevents underground placement
- [x] Debug tools provide real-time coordinate feedback
- [x] Drag & drop system maintains coordinate precision
- [x] Coordinates are properly stored and retrieved
- [x] Documentation includes complete coordinate reference

## 📚 Related Documentation

- [2025-09-17_3D_Indonesia_Map_System_Complete.md](2025-09-17_3D_Indonesia_Map_System_Complete.md)
- [2025-09-17_3D_Drag_Drop_Technical_Implementation.md](2025-09-17_3D_Drag_Drop_Technical_Implementation.md)

---

**Final Note**: These coordinates represent the culmination of extensive testing and user feedback. They provide optimal placement for the Indonesia 3D map system and should be considered the authoritative reference for future development.
