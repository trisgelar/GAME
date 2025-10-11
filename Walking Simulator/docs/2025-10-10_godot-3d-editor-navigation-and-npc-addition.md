# Godot 3D Editor Navigation and Adding NPCs to Tambora Scene

**Created:** 2025-10-10  
**Purpose:** Comprehensive guide for navigating Godot's 3D editor and manually adding NPCs to the Tambora scene

---

## Table of Contents

1. [Godot 3D Editor Navigation](#godot-3d-editor-navigation)
2. [Camera Movement Shortcuts](#camera-movement-shortcuts)
3. [Adding NPCs to Tambora Scene](#adding-npcs-to-tambora-scene)
4. [NPC Structure Explained](#npc-structure-explained)
5. [Testing Your NPCs](#testing-your-npcs)
6. [Troubleshooting](#troubleshooting)

---

## Godot 3D Editor Navigation

### Basic 3D Viewport Navigation

The Godot 3D editor uses a standard 3D viewport navigation system:

#### **Mouse-Based Navigation**

| Action | Controls |
|--------|----------|
| **Rotate Camera** | Hold **Middle Mouse Button** + Move Mouse |
| **Pan Camera** | Hold **Shift + Middle Mouse Button** + Move Mouse |
| **Zoom In/Out** | **Mouse Wheel** Up/Down |
| **Orbit Around Selection** | Select object, then **Alt + Middle Mouse Button** |

#### **Keyboard Navigation (WASD Fly Mode)**

| Key | Action |
|-----|--------|
| **Right Mouse Button** | Hold to enable fly mode |
| **W** | Move Forward |
| **S** | Move Backward |
| **A** | Strafe Left |
| **D** | Strafe Right |
| **Q** | Move Down |
| **E** | Move Up |
| **Shift** (while moving) | **MOVE FASTER** ⚡ |
| **Alt** (while moving) | Move Slower (precision mode) |

> **💡 TIP:** To move faster in the 3D viewport, hold **Shift** while using WASD keys. This is the solution to slow movement!

### Advanced Camera Controls

#### **View Shortcuts**

| Shortcut | View |
|----------|------|
| **Numpad 1** | Front View |
| **Ctrl + Numpad 1** | Back View |
| **Numpad 3** | Right View |
| **Ctrl + Numpad 3** | Left View |
| **Numpad 7** | Top View |
| **Ctrl + Numpad 7** | Bottom View |
| **Numpad 5** | Toggle Perspective/Orthogonal |
| **F** | Focus on Selected Object |

#### **Selection and Manipulation**

| Shortcut | Action |
|----------|--------|
| **Left Click** | Select object |
| **Ctrl + Left Click** | Add to selection |
| **W** | Select Mode (default) |
| **Q** | Transform Mode |
| **E** | Rotate Mode |
| **R** | Scale Mode |
| **Ctrl + D** | Duplicate selected object |
| **Delete** | Delete selected object |

#### **Grid and Snap Controls**

| Shortcut | Action |
|----------|--------|
| **Y** | Toggle Snap to Grid |
| **Ctrl + G** | Configure Grid Snap Settings |

### Camera Speed Adjustment

1. Click the **3D Viewport Settings** (three dots) in the top-right of the 3D viewport
2. Look for **View** → **Settings**
3. Adjust **Camera Speed** slider (0.1 - 10.0)
4. Or use **Shift + Mouse Wheel** while holding Right Mouse Button to adjust speed on the fly

---

## Adding NPCs to Tambora Scene

### Current NPCs in Tambora Scene

The Tambora scene currently has **3 NPCs**:
1. **Historian** - Located at position (0, 1, 0)
2. **Geologist** - Located at position (-5, 1, -8)
3. **LocalGuide** - Located at position (5, 1, -8)

Let's add **3 additional NPCs** of type "Guide" named "Sisanya1", "Sisanya2", and "Sisanya3".

---

## Step-by-Step: Adding a New NPC

### Step 1: Open the Tambora Scene

1. Open Godot Engine
2. In the **FileSystem** panel (bottom-left), navigate to:
   ```
   res://Scenes/IndonesiaTengah/TamboraScene.tscn
   ```
3. Double-click to open the scene
4. You should see the 3D viewport with the mountain environment

### Step 2: Prepare the Scene Tree

1. In the **Scene Tree** (left panel), locate the **NPCs** node
2. Click on **NPCs** to select it
3. This node acts as a container for all NPC characters

### Step 3: Create the First New NPC (Sisanya1)

#### 3.1 Create Root NPC Node

1. Right-click on **NPCs** node
2. Select **Add Child Node**
3. Search for **Node3D**
4. Click **Create**
5. Rename it to **"Sisanya1"** (right-click → Rename, or press F2)

#### 3.2 Add NPC to Group

1. With **Sisanya1** selected, look at the **Node** tab in the Inspector (right panel)
2. Click on the **Groups** section
3. Type `npc` in the text field
4. Click **Add**
5. The NPC is now part of the "npc" group (required for game systems)

#### 3.3 Attach the CulturalNPC Script

1. Still with **Sisanya1** selected, look at the **Inspector** panel
2. Find the **Script** section at the top
3. Click the **Script** icon or the **[empty]** button
4. Click **Load**
5. Navigate to: `res://Systems/NPCs/CulturalNPC.gd`
6. Click **Open**

#### 3.4 Configure NPC Properties

In the **Inspector**, you'll now see CulturalNPC properties:

```
Script Variables:
├── npc_name: "Sisanya1"
├── cultural_region: "Indonesia Tengah"
├── npc_type: "Guide"
├── interaction_range: 3.0
└── (leave other properties as default)
```

Set these values:
- **npc_name**: Type `"Sisanya1"`
- **cultural_region**: Type `"Indonesia Tengah"`
- **npc_type**: Type `"Guide"`
- **interaction_range**: Keep at `3.0`

### Step 4: Create Visual Representation (NPCModel)

#### 4.1 Add NPCModel Node

1. Right-click on **Sisanya1** node
2. Select **Add Child Node**
3. Search for **CSGCylinder3D**
4. Click **Create**
5. Rename it to **"NPCModel"**

#### 4.2 Style the NPC Model

1. With **NPCModel** selected, look at **Inspector**
2. Find the **Material** section
3. Expand **CSGShape3D** → **Material**
4. Click the dropdown and select **New StandardMaterial3D**
5. Click on the material to expand its properties
6. Under **Albedo**, click the **Color** property
7. Choose a color (e.g., for guides, use green: R:0.2, G:0.8, B:0.2, A:1.0)

#### 4.3 Optional: Adjust Model Size

In the **Inspector**, you can adjust:
- **Radius**: Default is 1.0 (NPC width)
- **Height**: Default is 2.0 (NPC height)

### Step 5: Create Collision for NPC Body

#### 5.1 Add NPCCollision Node

1. Right-click on **Sisanya1** node
2. Select **Add Child Node**
3. Search for **CharacterBody3D**
4. Click **Create**
5. Rename it to **"NPCCollision"**

#### 5.2 Add Collision Shape

1. Right-click on **NPCCollision** node
2. Select **Add Child Node**
3. Search for **CollisionShape3D**
4. Click **Create**
5. In the **Inspector**, find the **Shape** property
6. Click the dropdown next to **[empty]**
7. Select **New BoxShape3D**
8. Click on the **BoxShape3D** to expand it
9. Set **Size** to: `X: 1, Y: 2, Z: 1` (match NPC body size)

### Step 6: Create Interaction Area

#### 6.1 Add InteractionArea Node

1. Right-click on **Sisanya1** node
2. Select **Add Child Node**
3. Search for **Area3D**
4. Click **Create**
5. Rename it to **"InteractionArea"**

#### 6.2 Add Interaction Collision Shape

1. Right-click on **InteractionArea** node
2. Select **Add Child Node**
3. Search for **CollisionShape3D**
4. Click **Create**
5. In the **Inspector**, find the **Shape** property
6. Click the dropdown next to **[empty]**
7. Select **New SphereShape3D**
8. Click on the **SphereShape3D** to expand it
9. Set **Radius** to: `2.0` (player must be within 2 meters to interact)

### Step 7: Position the NPC in the Scene

#### 7.1 Using the Transform Inspector

1. Select the **Sisanya1** root node
2. In the **Inspector**, find **Transform** → **Position**
3. Set coordinates, for example:
   ```
   X: 10
   Y: 1
   Z: -5
   ```

#### 7.2 Using Visual Positioning (Recommended)

1. Make sure you're in **Select Mode** (press Q or click the arrow icon)
2. Select the **Sisanya1** root node
3. In the 3D viewport, you'll see three colored arrows (gizmo):
   - **Red arrow** = X axis
   - **Green arrow** = Y axis  
   - **Blue arrow** = Z axis
4. Click and drag an arrow to move the NPC along that axis
5. Or click on the center to move freely

**Recommended Positions for New NPCs:**
- **Sisanya1**: `(10, 1, -5)` - East of the path
- **Sisanya2**: `(-10, 1, -5)` - West of the path
- **Sisanya3**: `(0, 1, -15)` - Near the mountain base

### Step 8: Verify Node Structure

Your **Sisanya1** node should look like this in the Scene Tree:

```
NPCs
└── Sisanya1 (Node3D) [Script: CulturalNPC.gd] [Group: npc]
    ├── NPCModel (CSGCylinder3D)
    ├── NPCCollision (CharacterBody3D)
    │   └── CollisionShape3D (BoxShape3D)
    └── InteractionArea (Area3D)
        └── CollisionShape3D (SphereShape3D)
```

### Step 9: Duplicate for Additional NPCs

Now that you have one complete NPC, creating the others is easy:

#### 9.1 Duplicate Sisanya1

1. Right-click on **Sisanya1** in the Scene Tree
2. Select **Duplicate** (or press Ctrl+D)
3. A new node **Sisanya2** appears
4. Select **Sisanya2** and update in Inspector:
   - **npc_name**: Change to `"Sisanya2"`
   - **Transform → Position**: Change to `(-10, 1, -5)`

#### 9.2 Create Third NPC

1. Right-click on **Sisanya1** again
2. Select **Duplicate**
3. Rename to **Sisanya3**
4. Update in Inspector:
   - **npc_name**: Change to `"Sisanya3"`
   - **Transform → Position**: Change to `(0, 1, -15)`

#### 9.3 Optional: Customize Appearance

You can differentiate the NPCs visually:
1. Select each NPC's **NPCModel** child
2. Change the **Material → Albedo → Color**
3. Suggested colors:
   - Sisanya1: Light Green (0.3, 0.9, 0.3)
   - Sisanya2: Cyan (0.3, 0.9, 0.9)
   - Sisanya3: Yellow (0.9, 0.9, 0.3)

### Step 10: Save the Scene

1. Press **Ctrl+S** or click **Scene** → **Save Scene**
2. Godot saves the changes to `TamboraScene.tscn`

---

## NPC Structure Explained

### Node Hierarchy Purpose

```
Sisanya1 (Node3D)
├── NPCModel (CSGCylinder3D)          ← Visual representation
├── NPCCollision (CharacterBody3D)    ← Physical body (blocks movement)
│   └── CollisionShape3D              ← Defines collision bounds
└── InteractionArea (Area3D)          ← Detects player proximity
    └── CollisionShape3D              ← Defines interaction range
```

### Why Each Component?

| Component | Purpose | Details |
|-----------|---------|---------|
| **Root Node3D** | Container & transform | Holds position/rotation of entire NPC |
| **CulturalNPC Script** | Behavior logic | Handles dialogue, state machine, interaction |
| **NPCModel** | Visual mesh | What the player sees |
| **NPCCollision** | Physical collision | Prevents player walking through NPC |
| **InteractionArea** | Interaction detection | Triggers when player is nearby (radius 2m) |

### NPC Properties Reference

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `npc_name` | String | "" | Display name shown in UI |
| `cultural_region` | String | "" | Region this NPC belongs to |
| `npc_type` | String | "Guide" | NPC role (Guide, Vendor, Historian) |
| `interaction_range` | float | 3.0 | Distance for interaction (meters) |
| `dialogue_data` | Array | [] | Dialogue lines (auto-generated if empty) |

---

## Testing Your NPCs

### Step 1: Run the Scene

1. With **TamboraScene.tscn** open, press **F6** (Run Current Scene)
2. Or click the **Play Scene** button (▶️ with a movie clapperboard icon)

### Step 2: Navigate to NPCs

1. Use **WASD** to move your player character
2. Hold **Shift** for faster movement
3. Use **Mouse** to look around
4. Walk towards any of the new NPCs

### Step 3: Test Interaction

1. Walk close to an NPC (within 2 meters)
2. An interaction prompt should appear
3. Press the interaction key (usually **E** or **F**)
4. Dialogue UI should open with NPC name

### Step 4: Check the Radar

1. Look at the **Radar System** in the UI (usually top-right corner)
2. NPCs should appear as **green dots/icons**
3. This confirms the NPC is properly added to the "npc" group

### Debug Checks

If something doesn't work, check:

1. **NPC not visible?**
   - Ensure NPCModel has a material assigned
   - Check Y position (should be 1.0, not 0.0 or underground)

2. **Can't interact?**
   - Verify NPC is in "npc" group
   - Check InteractionArea has SphereShape3D with radius 2.0
   - Ensure CulturalNPC.gd script is attached

3. **Player walks through NPC?**
   - Check NPCCollision has CharacterBody3D node type
   - Verify CollisionShape3D has BoxShape3D assigned

4. **NPC name wrong in UI?**
   - Check `npc_name` property in Inspector
   - Make sure it's spelled correctly

---

## Advanced: Positioning Best Practices

### Using Grid Snap

1. Click the **Magnet** icon in the 3D viewport toolbar
2. Check **Snap to Grid**
3. Configure snap distance: **Transform** → **Configure Snap** → Set to 1 or 0.5

### Strategic NPC Placement

For the Tambora scene, consider placing NPCs at:

| Location Type | Purpose | Example Position |
|--------------|---------|------------------|
| **Entrance** | Greet and orient players | `(0, 1, 5)` |
| **Path markers** | Provide trail information | `(0, 2, -5)` |
| **Historical sites** | Explain significance | Near markers |
| **Mountain base** | Warn about difficulty | `(0, 1, -15)` |
| **Cultural artifact areas** | Provide context | Near artifacts |

### Visual Arrangement

- **Triangle formation**: Place NPCs in triangular patterns for natural discovery
- **Path guidance**: Place along the mountain path at intervals
- **Cluster avoidance**: Keep at least 5 meters between NPCs
- **Height variation**: Adjust Y position to match terrain (e.g., Y: 2 for elevated paths)

---

## Camera Movement Speed Tips

### Method 1: In-Editor Speed Boost

**Fastest way to move in 3D viewport:**
1. Hold **Right Mouse Button** (enters fly mode)
2. Press **W/A/S/D** to move
3. Hold **Shift** while moving = **3x speed boost** ⚡
4. Use **Mouse** to change direction
5. Press **Q/E** for vertical movement

### Method 2: Adjust Camera Speed Setting

1. Click **Editor** → **Editor Settings**
2. Navigate to **Editors** → **3D**
3. Find **Navigation**
4. Adjust these settings:
   - **Navigation Speed**: 4.0 (default) → Try **8.0** or **12.0**
   - **Zoom Speed**: 1.0 → Try **2.0**
   - **Freelook Speed Scale**: 1.0 → Try **2.0**

### Method 3: Dynamic Speed Adjustment

While in fly mode (holding Right Mouse Button):
- **Shift + Mouse Wheel Up**: Increase speed
- **Shift + Mouse Wheel Down**: Decrease speed
- Check the top-left corner for current speed value

### Method 4: Quick Zoom

- **Double-click Right Mouse Button** on an object to instantly focus on it
- Press **F** to frame selected object in viewport

---

## Troubleshooting

### Common Issues

#### Issue 1: "Slow Movement in 3D Viewport"
**Solution:** Hold **Shift** while using WASD. If still slow, increase camera speed in Editor Settings.

#### Issue 2: "Can't See the NPC"
**Possible causes:**
- NPC is underground (Y position too low)
- No material on NPCModel
- Camera is too far away

**Solution:** 
1. Select NPC root node
2. Press **F** to focus camera
3. Check Transform Y position ≥ 1.0
4. Verify NPCModel has material

#### Issue 3: "NPC Not Appearing on Radar"
**Solution:**
1. Select NPC root node
2. Inspector → **Node** tab
3. **Groups** section → Add `npc` group
4. Save and re-run scene

#### Issue 4: "Interaction Not Working"
**Check:**
1. CulturalNPC.gd script is attached to root node (not children)
2. InteractionArea exists with SphereShape3D
3. Player controller has interaction system enabled
4. Check console (Output panel) for errors

#### Issue 5: "Duplicated NPC Has Wrong Name"
**Solution:**
1. After duplicating, select the new NPC
2. Inspector → Find **npc_name** property
3. Change it to unique name
4. Node name and npc_name can be different

---

## Quick Reference Card

### Essential Shortcuts

```
NAVIGATION
├── Right Mouse + WASD    : Fly mode
├── Shift (while moving)  : FASTER MOVEMENT ⚡
├── Middle Mouse          : Rotate camera
├── Shift + Middle Mouse  : Pan camera
├── Mouse Wheel           : Zoom
└── F                     : Focus on selection

EDITING
├── Q  : Select/Move mode
├── E  : Rotate mode
├── R  : Scale mode
├── Ctrl+D  : Duplicate
└── Ctrl+S  : Save

VIEWS
├── Numpad 1/3/7  : Front/Right/Top
├── Numpad 5      : Toggle perspective
└── F             : Frame selection
```

### NPC Creation Checklist

- [ ] Create Node3D root
- [ ] Rename to unique name (e.g., "Sisanya1")
- [ ] Add to "npc" group
- [ ] Attach CulturalNPC.gd script
- [ ] Set npc_name property
- [ ] Set cultural_region property
- [ ] Set npc_type property
- [ ] Add CSGCylinder3D child (NPCModel)
- [ ] Add material to NPCModel
- [ ] Add CharacterBody3D child (NPCCollision)
- [ ] Add CollisionShape3D to NPCCollision (BoxShape3D, size 1×2×1)
- [ ] Add Area3D child (InteractionArea)
- [ ] Add CollisionShape3D to InteractionArea (SphereShape3D, radius 2.0)
- [ ] Position NPC in scene (Y ≥ 1.0)
- [ ] Save scene (Ctrl+S)
- [ ] Test in-game (F6)

---

## Summary

You've learned:

1. ✅ **Navigate efficiently** in Godot's 3D editor using **Shift + WASD**
2. ✅ **Create complete NPCs** with proper structure and collision
3. ✅ **Duplicate and customize** NPCs for variety
4. ✅ **Position strategically** in the scene
5. ✅ **Test and debug** NPC functionality

### Next Steps

- Customize dialogue for each new NPC
- Add unique visual models (replace CSGCylinder3D with custom meshes)
- Implement quest systems for NPCs
- Create patrol paths for walking NPCs

---

## Additional Resources

- **CulturalNPC System:** `res://Systems/NPCs/CulturalNPC.gd`
- **Dialogue System:** `res://Systems/NPCs/NPCDialogueSystem.gd`
- **State Machine:** `res://Systems/NPCs/NPCStateMachine.gd`
- **Region Controller:** `res://Scenes/RegionSceneController.gd`

For more information about NPC systems and dialogue, check the `Systems/NPCs/` directory.

---

**Document Status:** ✅ Complete  
**Last Updated:** 2025-10-10  
**Author:** ISSAT Game Development Team  
**Version:** 1.0

