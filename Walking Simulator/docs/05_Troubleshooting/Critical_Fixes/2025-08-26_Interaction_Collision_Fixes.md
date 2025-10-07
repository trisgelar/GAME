# Interaction and Collision System Fixes - 2025-08-26

## Issues Identified from Debug Log

### **1. Scene Tree Timing Error (Critical)**
**Error**: `Condition "!is_inside_tree()" is true. Returning: Transform3D()`
**Location**: `CulturalNPC.gd:155` in `_create_interaction_indicator()`
**Cause**: Interaction indicator was being created before NPC was in scene tree

### **2. Missing Collision Shapes**
**Warning**: "Missing collision shape!"
**Cause**: Stalls and artifacts were using wrong collision shapes (wall shapes instead of proper sizes)

### **3. RayCast Not Detecting Objects**
**Issue**: RayCast only hitting ground/walls, never NPCs or artifacts
**Cause**: Collision layers not properly configured

## Fixes Applied

### **1. Scene Tree Timing Fix**

**Problem**: `global_position` failing because NPC not in scene tree
```gdscript
# Before (ERROR)
indicator.global_position = global_position + Vector3(0, 2, 0)
```

**Solution**: Added deferred creation and used relative positioning
```gdscript
# After (FIXED)
if not is_inside_tree():
    call_deferred("_create_interaction_indicator")
    return

indicator.position = Vector3(0, 2, 0)  # Relative to NPC
```

### **2. Collision Shape Fixes**

**Problem**: Wrong collision shapes for objects
```gdscript
# Before (WRONG)
shape = SubResource("BoxShape3D_wall")  # 50x4x1 for walls
```

**Solution**: Created proper collision shapes
```gdscript
# Added new resources
[sub_resource type="BoxShape3D" id="BoxShape3D_stall"]
size = Vector3(4, 2, 3)  # Proper stall size

[sub_resource type="CylinderShape3D" id="CylinderShape3D_artifact"]
radius = 0.5
height = 1.0  # Proper artifact size
```

**Applied to**:
- All 4 stalls: `Stall1Collision` to `Stall4Collision`
- All 4 artifacts: `SotoRecipeCollision`, `LotekRecipeCollision`, `BasoRecipeCollision`, `SateRecipeCollision`

### **3. Collision Layer Configuration**

**Problem**: RayCast not detecting objects due to collision layer mismatch

**Solution**: Set proper collision layers
```gdscript
# RayCast configuration
[node name="InteractionController" type="RayCast3D" parent="."]
collision_mask = 1  # Detect layer 1

# Object collision layers
[node name="NPCCollision" type="CharacterBody3D" parent="NPCs/MarketGuide"]
collision_layer = 1  # On layer 1

[node name="Stall1Collision" type="StaticBody3D" parent="Environment/MarketStalls"]
collision_layer = 1  # On layer 1
```

**Applied to**:
- All NPC collision bodies
- All stall collision bodies  
- All artifact collision bodies

## Files Modified

### **1. Systems/NPCs/CulturalNPC.gd**
- Fixed `_create_interaction_indicator()` timing issue
- Added deferred creation for scene tree safety

### **2. Scenes/IndonesiaBarat/PasarScene.tscn**
- Added proper collision shape resources
- Updated all collision shapes to correct sizes
- Set collision layers for all interactive objects
- Updated `load_steps` count

### **3. Player Controller/Player.tscn**
- Added `collision_mask = 1` to RayCast

## Expected Results

After these fixes:

### **✅ Collision System**
1. **No more "menembus" objects** - stalls and artifacts will block player movement
2. **Proper collision detection** - all objects have correct collision shapes
3. **Collision layers working** - player can't walk through walls, stalls, or artifacts

### **✅ Interaction System**
1. **RayCast detects NPCs** - interaction prompts will appear when approaching NPCs
2. **RayCast detects artifacts** - collection prompts will appear when near artifacts
3. **No scene tree errors** - interaction indicators create properly
4. **Visual feedback works** - glowing indicators appear above NPCs

### **✅ Debug System**
1. **No more timing errors** - all operations happen after scene tree is ready
2. **Proper collision logging** - debug shows correct collision detection
3. **Clean error logs** - no more missing collision shape warnings

## Testing Instructions

1. **Run the game** and load Pasar scene
2. **Walk around** - you should now hit walls, stalls, and artifacts (no more "menembus")
3. **Approach NPCs** - you should see "[E] Talk to [NPC Name]" prompts
4. **Press E** - NPC dialogue should start
5. **Approach artifacts** - you should see collection prompts
6. **Check debug log** - should show successful collision and interaction detection

## Verification Commands

The debug log should now show:
```
[INFO] RayCast hit: MarketGuide (Type: CulturalNPC)
[INFO] Found CulturalInteractableObject: MarketGuide
[INFO] Near interactable: MarketGuide - [E] Talk to MarketGuide
[INFO] Player entered interaction range of MarketGuide
[DEBUG] Created interaction indicator for MarketGuide
```
