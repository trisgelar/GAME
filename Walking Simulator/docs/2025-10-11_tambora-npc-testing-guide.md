# Tambora NPC Testing Guide

**Created:** 2025-10-11  
**Status:** Ready for Testing

---

## 🔧 **Issue Fixed**

The error `Cannot get class 'DialogueResource'` was caused by Godot not recognizing the new custom resource class. I've implemented a **dynamic loading solution** that doesn't require Inspector assignment.

## ✅ **What I've Done**

### **1. Removed Dialogue Resource References from TamboraRoot.tscn**
- Removed all `dialogue_resource = ExtResource()` lines
- Reset `load_steps` back to 19
- NPCs now load dialogues dynamically at runtime

### **2. Added Dynamic Loading in CulturalNPC.gd**
- Added `load_dialogue_resource_by_name()` function
- NPCs automatically load their dialogue resources based on `npc_name`
- Falls back to default dialogue if resource fails to load

### **3. Current NPC Setup in TamboraRoot.tscn**

| NPC Name | Node Name | Position | npc_type | Status |
|----------|-----------|----------|----------|---------|
| **Dr. Heinrich** | DrHeinrich | (205, 107, -1853) | Historian | ✅ Ready |
| **Dr. Sari** | DrSari | (489, 88, -1882) | Historian | ✅ Ready |
| **Pak Budi** | PakBudi | (742, 89, -1699) | Guide | ✅ Ready |
| **Ibu Maya** | IbuMaya | (461, 79, -349) | Guide | ✅ Ready |
| **Dr. Ahmad** | DrAhmad | (586, 107, 356) | Historian | ✅ Ready |
| **Pak Karsa** | PakKarsa | (501, 101, -56) | Guide | ✅ Ready |

---

## 🧪 **Testing Steps**

### **Step 1: Reload Godot Project**
1. **Close Godot completely**
2. **Reopen Godot**
3. **Open your project**
4. This ensures Godot recognizes the new `DialogueResource` class

### **Step 2: Test TamboraRoot.tscn**
1. **Open TamboraRoot.tscn** in Godot
2. **Save the scene** (Ctrl+S) - should save without errors
3. **Run the scene** (F6)
4. **Check console output** for dialogue loading messages

### **Step 3: Test NPC Interactions**
1. **Approach each NPC** and press E to interact
2. **Check if dialogues are unique** for each NPC:
   - **Dr. Heinrich** should talk about 1847 expedition
   - **Dr. Sari** should talk about volcano monitoring
   - **Pak Budi** should share 1815 family stories
   - **Ibu Maya** should discuss spiritual beliefs
   - **Dr. Ahmad** should explain climate impact
   - **Pak Karsa** should provide climbing guidance

### **Step 4: Verify Console Output**
Look for these messages in the console:
```
Cultural NPC Dr. Heinrich initialized in Indonesia Tengah
Successfully loaded dialogue resource for Dr. Heinrich
Loaded X dialogue nodes from resource
```

---

## 🔍 **Expected Results**

### **If Working Correctly:**
- ✅ **No errors** in console
- ✅ **Unique dialogues** for each NPC
- ✅ **Rich, historically-accurate content** from .tres files
- ✅ **Multiple dialogue options** with branching

### **If Still Having Issues:**
- ❌ **Generic dialogues** (fallback to default system)
- ❌ **Error messages** about DialogueResource
- ❌ **All NPCs have same dialogue**

---

## 🛠️ **Troubleshooting**

### **Issue 1: Still Getting DialogueResource Errors**
**Solution:**
1. Close Godot completely
2. Delete `.godot` folder in your project directory
3. Reopen Godot and project
4. This forces Godot to rebuild the project

### **Issue 2: NPCs Still Have Same Dialogue**
**Check:**
1. Console for "Successfully loaded dialogue resource" messages
2. Verify dialogue resource files exist in `Resources/Dialogues/Tambora/`
3. Check NPC names match exactly: "Dr. Heinrich", "Dr. Sari", etc.

### **Issue 3: Scene Won't Save**
**Solution:**
1. Make sure no dialogue_resource references remain in TamboraRoot.tscn
2. Verify load_steps=19 at top of file
3. Try saving with Ctrl+S

---

## 📊 **Dialogue Content Verification**

Each NPC should have unique dialogue based on the .tres files:

### **Dr. Heinrich (Swiss Explorer):**
- 1847 expedition story
- Local warnings about mountain spirits
- Summit discoveries and scientific documentation

### **Dr. Sari (Indonesian Volcanologist):**
- Modern volcano monitoring systems
- VEI 7 significance explanation
- Future eruption possibilities

### **Pak Budi (Sumbawan Elder):**
- 1815 eruption eyewitness stories
- Three kingdoms destruction
- Family survival stories

### **Ibu Maya (Traditional Healer):**
- Spiritual beliefs about volcanoes
- Traditional healing methods
- Protection rituals for mountain climbing

### **Dr. Ahmad (Climate Scientist):**
- Year Without Summer explanation
- Global climate effects
- Cultural impact on art and literature

### **Pak Karsa (Mountain Guide):**
- Climbing routes and preparation
- Safety protocols and equipment
- Crater information and respect

---

## 🎵 **Audio Integration**

Once dialogues are working correctly:
1. **Add audio files** to `Assets/Audio/Dialog/`
2. **Long dialogues** will automatically play audio
3. **Short dialogues** will display text only

---

## 🎯 **Success Criteria**

✅ **Scene saves without errors**  
✅ **All 6 NPCs load unique dialogues**  
✅ **No console errors about DialogueResource**  
✅ **Rich, historically-accurate content displays**  
✅ **Multiple dialogue options work**  
✅ **Ready for audio file integration**  

---

**Status:** 🚀 **Ready for Testing**  
**Last Updated:** 2025-10-11  
**Next Step:** Test the scene and verify unique dialogues for each NPC

---

*The dynamic loading solution should resolve the DialogueResource class recognition issue and allow each NPC to display their unique, historically-accurate dialogues.*
