# Precise NPC Positioning Guide - Coordinate Input Method

**Created:** 2025-10-10  
**Purpose:** Quick guide for moving NPCs to exact coordinates in Godot 3D Editor

---

## Problem

You've duplicated an NPC and need to move it to a specific position, but dragging manually is imprecise and difficult.

## Solution: Direct Coordinate Input ✅

Godot allows you to **type exact coordinates** directly in the Inspector panel - no dragging needed!

---

## Step-by-Step: Moving NPC to Exact Position

### Step 1: Select Your NPC

- In the **Scene Tree** (left panel), click on your NPC node
- Example: Click on "Sisanya1"

### Step 2: Open Inspector Panel

- Look at the **Inspector** panel on the right side
- If it's not visible, press **F4** to show it

### Step 3: Find Transform Section

```
Inspector Panel
├── Node3D
├── Transform ← Look for this
│   ├── Position   ← Click here to expand
│   │   ├── x: 0.0
│   │   ├── y: 0.0
│   │   └── z: 0.0
│   ├── Rotation
│   └── Scale
```

### Step 4: Input Coordinates

1. Click on the **Position** property to expand it
2. Click on the **X value** field
3. Type your X coordinate (e.g., `10`)
4. Press **Enter** or **Tab**
5. Type Y coordinate (e.g., `1`)
6. Press **Enter** or **Tab**
7. Type Z coordinate (e.g., `-5`)
8. Press **Enter**

**The NPC instantly moves to that exact position!** ⚡

---

## Example: Adding 3 Sisanya NPCs

### Duplicate & Position First NPC

1. Select **Historian** NPC (or any existing NPC)
2. Press **Ctrl+D** to duplicate
3. Press **F2** to rename → Type "Sisanya1"
4. In **Inspector** → **Transform** → **Position**:
   ```
   X: 10
   Y: 1
   Z: -5
   ```
5. In **Inspector** → **Script Variables** → **npc_name**: Change to `"Sisanya1"`

### Duplicate & Position Second NPC

1. Press **Ctrl+D** on Sisanya1 to duplicate
2. Press **F2** → Rename to "Sisanya2"
3. In **Inspector** → **Transform** → **Position**:
   ```
   X: -10
   Y: 1
   Z: -5
   ```
4. In **Inspector** → **Script Variables** → **npc_name**: Change to `"Sisanya2"`

### Duplicate & Position Third NPC

1. Press **Ctrl+D** on Sisanya2 to duplicate
2. Press **F2** → Rename to "Sisanya3"
3. In **Inspector** → **Transform** → **Position**:
   ```
   X: 0
   Y: 1
   Z: -15
   ```
4. In **Inspector** → **Script Variables** → **npc_name**: Change to `"Sisanya3"`

### Save Scene

Press **Ctrl+S** to save your changes.

---

## Visual Reference

### Where to Find Transform Position

```
┌─────────────────────────────────┐
│ INSPECTOR                    [×]│
├─────────────────────────────────┤
│ Node3D                          │
│ [Script Icon] CulturalNPC.gd    │
├─────────────────────────────────┤
│ ▼ Transform                     │  ← Click to expand
│   ▼ Position                    │  ← Click to expand
│     x: [  10.0  ]               │  ← Type X here
│     y: [   1.0  ]               │  ← Type Y here
│     z: [  -5.0  ]               │  ← Type Z here
│   ▶ Rotation                    │
│   ▶ Scale                       │
├─────────────────────────────────┤
│ ▼ Script Variables              │
│   npc_name: "Sisanya1"          │  ← Change this too
│   cultural_region: "Indones..."│
│   npc_type: "Guide"             │
└─────────────────────────────────┘
```

---

## Alternative Methods

### Method 2: Copy & Paste Coordinates

If you have coordinates in a text file:

1. **Copy** the X value (Ctrl+C)
2. Click in the **X field** in Inspector
3. **Paste** (Ctrl+V)
4. Repeat for Y and Z

### Method 3: Using Arrow Keys (Small Adjustments)

After positioning, you can nudge with:
- **Arrow Keys**: Move X/Z
- **Page Up/Down**: Move Y
- Hold **Shift** for larger steps

### Method 4: Snap to Grid

For aligned positions:
1. Click **magnet icon** 🧲 in 3D viewport toolbar
2. Enable **Use Snap** and **Snap to Grid**
3. Configure snap step size (right-click magnet)
4. Drag NPC - it will snap to grid points

---

## Understanding Coordinates in Tambora Scene

### Coordinate System

```
        Y (Up)
        │
        │
        └───── X (Right)
       ╱
      ╱
     Z (Forward into screen)
```

### Y-Axis Values (Height)

| Y Value | Meaning |
|---------|---------|
| 0.0 | Ground level |
| 1.0 | Standard NPC height (recommended) |
| 2.0 | Elevated path/platform |
| 5.0 | Mountain mid-level |

⚠️ **Important:** Never use Y < 0.5 or NPC will be partially underground!

### Common X/Z Positions in Tambora

| Position | X | Y | Z | Description |
|----------|---|---|---|-------------|
| Starting area | 0 | 1 | 0 | Scene entrance |
| East path | 10 | 1 | -5 | Right side of path |
| West path | -10 | 1 | -5 | Left side of path |
| Mountain base | 0 | 1 | -15 | Near mountain |
| Path marker 1 | 0 | 1 | -10 | First marker area |
| Path marker 2 | 0 | 2 | -8 | Elevated marker |

---

## Pro Tips

### Tip 1: View Coordinates While Moving

When you drag an NPC in 3D viewport:
- Watch the **Inspector panel** - coordinates update in real-time
- Stop dragging when you see the values you want

### Tip 2: Round Numbers

Use round numbers for easy memory:
- ✅ Good: `X: 10, Y: 1, Z: -5`
- ❌ Harder to remember: `X: 9.847, Y: 1.123, Z: -4.932`

### Tip 3: Keep Y Consistent

For NPCs on flat ground, use the same Y value:
- All ground NPCs: `Y: 1.0`
- All elevated NPCs: `Y: 2.0`
- This makes them appear "standing" properly

### Tip 4: Use Negative Z for "Into Scene"

In Godot's default camera view:
- **Positive Z** = Toward camera (closer to player start)
- **Negative Z** = Away from camera (deeper into scene)

For Tambora mountain scene, NPCs near the mountain use **negative Z** values.

---

## Quick Reference: Positioning Workflow

```
1. Duplicate NPC      → Ctrl+D
2. Rename             → F2
3. Select node        → Left click in Scene Tree
4. Open Inspector     → F4 (if not visible)
5. Find Transform     → Top of Inspector
6. Click Position     → Expand section
7. Type X value       → Enter
8. Type Y value       → Enter
9. Type Z value       → Enter
10. Update npc_name   → Scroll down to Script Variables
11. Save scene        → Ctrl+S
```

---

## Troubleshooting

### NPC Disappears After Entering Coordinates

**Cause:** Coordinates are too far from camera view or underground

**Solution:**
1. With NPC selected, press **F** to focus camera on it
2. Check Y value is ≥ 1.0
3. If still can't see, try: `X: 0, Y: 1, Z: 0` (center position)

### Coordinates Don't Save

**Cause:** Forgot to press Enter or save scene

**Solution:**
1. After typing each value, press **Enter**
2. After positioning all NPCs, press **Ctrl+S** to save scene

### NPC Floating or Underground

**Cause:** Wrong Y value

**Solution:**
1. For flat ground in Tambora: Use `Y: 1.0`
2. For paths: Use `Y: 1.0` to `Y: 2.0`
3. For mountain areas: Check terrain height first

### Can't See Transform Section

**Cause:** Wrong node selected or Inspector collapsed

**Solution:**
1. Make sure you selected the **root NPC node** (not a child like NPCModel)
2. Root node should show "Node3D" type
3. If collapsed, click the **▶** arrow next to "Transform"

---

## Summary

✅ **Use Inspector Panel → Transform → Position for exact coordinates**  
✅ **Type numbers directly - no dragging needed**  
✅ **Press Enter after each value**  
✅ **Use Y: 1.0 for ground-level NPCs**  
✅ **Save scene with Ctrl+S when done**

This is much faster and more accurate than dragging manually!

---

## Related Documents

- Main guide: `2025-10-10_godot-3d-editor-navigation-and-npc-addition.md`
- NPC system documentation: `res://Systems/NPCs/`

---

**Document Status:** ✅ Complete  
**Last Updated:** 2025-10-10  
**Author:** ISSAT Game Development Team  
**Version:** 1.0

