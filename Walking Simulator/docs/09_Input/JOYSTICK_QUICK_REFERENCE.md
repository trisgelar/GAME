# 🎮 Joystick Quick Reference Card

**For "Pelupa" Users - Pin this to your monitor!**

---

## How to Change Joystick Settings (NO CODE EDITING!)

### 3 Easy Steps:

1. **Open Godot** → Open `Player Controller/Player.tscn`
2. **Select Player node** → Find "Input Settings" in Inspector
3. **Assign resource**: `Resources/Input/default_input_settings.tres`

### To Adjust Sensitivity:

1. **Click on the InputSettings resource** in Inspector
2. **Find "Joystick Camera Sensitivity"** slider
3. **Drag slider** left (slower) or right (faster)
4. **Press Ctrl+S** to save
5. **Test!**

---

## Controller Button Map

```
        [LB]                    [RB]
         
    [LT]                            [RT]


        [Y]                 (  )    (  )
    [X]   [B]                 Right
        [A]                   Analog
                             (Camera)
    
     Left
    Analog      [≡]  [☰]
   (Movement)
    
      [←→]
      [↑↓]
```

| Button | In Game | In Menus | Keyboard |
|--------|---------|----------|----------|
| **A** | Jump | Select/Enter | Spacebar/Enter |
| **Y** | Interact/Talk | - | E |
| **B** | Pick Item | Back/Cancel | F/Escape |
| **LB** | Sprint/Run | - | Shift |
| **Left Stick** | Move | Navigate | WASD/Arrows |
| **Right Stick** | Camera | - | Mouse |
| **D-Pad** | Move | Navigate | WASD/Arrows |

---

## Common Problems & Quick Fixes

### 😵 "Camera too fast!"
→ Lower **Joystick Camera Sensitivity** to **100** or **120**

### 🐌 "Camera too slow!"
→ Raise **Joystick Camera Sensitivity** to **300** or **350**

### 🔄 "Stick drifts by itself!"
→ Increase **Joystick Deadzone** to **0.25** or **0.30**

### 🔀 "Camera upside down!"
→ Check **Invert Joystick Y** (for up/down)
→ Check **Invert Joystick X** (for left/right)

### 🏃 "Player too slow/fast!"
→ Adjust **Walk Speed** (normal)
→ Adjust **Run Speed** (sprint with LB)

### 🦘 "Jump too high/low!"
→ Adjust **Jump Force** slider

---

## File Locations (Don't Forget!)

```
📁 Where to find settings:
   Walking Simulator/
   └── Resources/
       └── Input/
           └── default_input_settings.tres  ← EDIT THIS ONE!

📁 Where to assign settings:
   Walking Simulator/
   └── Player Controller/
       └── Player.tscn  ← Open this, select Player node
```

---

## Default Values (In Case Kamu Lupa)

| Setting | Default |
|---------|---------|
| Joystick Camera Sensitivity | 200.0 |
| Mouse Sensitivity | 0.02 |
| Joystick Deadzone | 0.15 |
| Walk Speed | 4.0 |
| Run Speed | 6.0 |
| Jump Force | 5.0 |
| Min Pitch | -1.5 |
| Max Pitch | 1.5 |

---

## Remember:

✅ **Save after changes** (Ctrl+S)  
✅ **Test in game** immediately  
✅ **No need to restart Godot** - just reload scene  
✅ **Can create multiple presets** - just duplicate the .tres file!  
✅ **Can't break anything** - sliders prevent invalid values  

---

## Works in ALL Scenes!

✅ Pasar (Indonesia Barat)  
✅ Tambora (Indonesia Tengah)  
✅ Papua (Indonesia Timur)  

All player controllers updated with joystick support!

---

**Full Guides:**
- Detailed setup: `docs/2025-10-08_joystick-setup.md`
- Inspector guide: `docs/2025-10-08_input-settings-guide.md`

**Questions?** Check the full guides above!

