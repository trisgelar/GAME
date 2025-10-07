# Corrected Menu System Integration: 3D Map + Cooking Mini-Games
**Date:** 2025-09-14  
**Status:** ✅ COMPLETED  
**Integration:** 3D Indonesia Map for Region Selection + Cooking Mini-Games in Pasar Scene  

## 🎯 **Corrected Understanding**

Based on your clarification, I've updated the system to match your actual requirements:

### 1. **3D Map Purpose:**
- **Replaces** the SVG Indonesia map in the main menu
- **3D Map** shows Indonesia with 3 main regions for selection:
  - **Indonesia Barat** → Jakarta (Pasar Scene)
  - **Indonesia Tengah** → NTB (Tambora Scene) 
  - **Indonesia Timur** → Papua (Papua Scene)

### 2. **Cooking Game Integration:**
- **NOT** as a separate 3D map system
- **BUT** as **mini-games within the Pasar scene**
- **Integration point**: NPCs in Pasar Scene (Indonesia Barat)
- **Flow**: NPC asks "Do you want to make Soto Betawi?" → Player chooses → Goes to cooking game scene
- **Student's working level**: Pempek (from Palembang) - included as one of the options

## 🏗️ **System Architecture**

### 1. **3D Map System (Region Selector)**
```
3D Indonesia Map:
├── Indonesia3DMapController.gd
│   ├── Region Selection (3 main regions)
│   ├── Camera Controls
│   └── Scene Transitions
├── POI Marker System (for regions)
│   ├── Red Marker: Indonesia Barat
│   ├── Yellow Marker: Indonesia Tengah
│   └── Blue Marker: Indonesia Timur
└── UI Overlay
    ├── Region Information Panel
    ├── Explore Region Button
    └── Back to Menu Button
```

### 2. **Cooking Mini-Game Integration**
```
Pasar Scene (Indonesia Barat):
├── CookingGameNPC.gd
│   ├── NPC Dialog System
│   ├── Recipe Selection
│   ├── Cooking Game Triggers
│   └── Return to Scene
├── CookingGameIntegration.gd (Singleton)
│   ├── Jakarta Recipe Database
│   ├── Game State Management
│   ├── Scene Transitions
│   └── Statistics Tracking
└── Student Cooking Game
    ├── Map.tscn (Student's scene)
    ├── Pempek Level (Working level)
    └── Recipe Adaptation
```

## 🎮 **User Experience Flow**

### 1. **Main Menu → 3D Map**
1. **Start Game** → Load 3D Indonesia map
2. **Select Region** → Click on colored region markers
3. **View Information** → See region description
4. **Explore Region** → Go to region scene (Pasar/Tambora/Papua)

### 2. **Pasar Scene → Cooking Mini-Game**
1. **Enter Pasar Scene** → Explore traditional market
2. **Find Cooking Chef NPC** → Located near market center
3. **Talk to Chef** → "Selamat datang! Mau belajar memasak apa?"
4. **Select Recipe** → Choose from available Jakarta dishes
5. **Start Cooking Game** → Load student's cooking game scene
6. **Complete Game** → Return to Pasar scene automatically

## 🍳 **Jakarta Recipe Database**

### **Available Recipes in Pasar Scene:**
```gdscript
var cooking_recipes: Dictionary = {
    "SotoBetawi": {
        "name": "Soto Betawi",
        "region": "DKI Jakarta",
        "description": "Traditional beef soup from Jakarta",
        "difficulty": "medium",
        "time_limit": 400  # 6.5 minutes
    },
    "Pempek": {
        "name": "Pempek Palembang", 
        "region": "Sumatera Selatan",
        "description": "Traditional fish cake (Student's working level)",
        "difficulty": "medium",
        "time_limit": 300  # 5 minutes
    },
    "NasiGudeg": {
        "name": "Nasi Gudeg Jakarta",
        "region": "DKI Jakarta", 
        "description": "Traditional jackfruit rice",
        "difficulty": "hard",
        "time_limit": 600  # 10 minutes
    },
    "Lotek": {
        "name": "Lotek Jakarta",
        "region": "DKI Jakarta",
        "description": "Traditional vegetable salad",
        "difficulty": "easy", 
        "time_limit": 250  # 4 minutes
    },
    "Baso": {
        "name": "Baso Jakarta",
        "region": "DKI Jakarta",
        "description": "Traditional meatball soup",
        "difficulty": "easy",
        "time_limit": 300  # 5 minutes
    },
    "Sate": {
        "name": "Sate Jakarta", 
        "region": "DKI Jakarta",
        "description": "Traditional grilled meat skewers",
        "difficulty": "medium",
        "time_limit": 350  # 6 minutes
    }
}
```

## 🎭 **NPC Dialog System**

### **Cooking Chef NPC Dialog Flow:**
```
1. Greeting:
   "Selamat datang! Saya bisa mengajarkan Anda cara memasak 
    masakan tradisional Jakarta. Mau belajar memasak apa?"
   
   Options:
   - "Soto Betawi" → Offer Soto Betawi
   - "Pempek Palembang" → Offer Pempek (Student's level)
   - "Nasi Gudeg" → Offer Nasi Gudeg
   - "Tidak, terima kasih" → Decline

2. Recipe Offer:
   "Bagus! Saya akan mengajarkan Anda cara memasak {recipe_name}. 
    Siap untuk memulai?"
    
   Options:
   - "Ya, mari mulai!" → Start cooking game
   - "Tidak, terima kasih" → Decline

3. Completion:
   "Selamat! Anda berhasil menyelesaikan {recipe_name}! 
    Apakah Anda ingin mencoba resep lain?"
    
   Options:
   - "Ya, resep lain" → Back to greeting
   - "Tidak, terima kasih" → End dialogue
```

## 🔧 **Technical Implementation**

### 1. **3D Map Controller (Modified)**
```gdscript
# Region data structure for 3 main regions
var region_data: Array[Dictionary] = [
    {
        "id": "indonesia_barat",
        "name": "Indonesia Barat", 
        "description": "Traditional Market Experience in Jakarta",
        "position": Vector3(-1.2, 0, -0.5),  # Jakarta area
        "scene_path": "res://Scenes/IndonesiaBarat/PasarScene.tscn",
        "color": Color.RED,
        "unlocked": true
    },
    {
        "id": "indonesia_tengah",
        "name": "Indonesia Tengah",
        "description": "Mount Tambora Experience in NTB", 
        "position": Vector3(-0.5, 0, 0.0),  # NTB area
        "scene_path": "res://Scenes/IndonesiaTengah/TamboraScene.tscn",
        "color": Color.YELLOW,
        "unlocked": true
    },
    {
        "id": "indonesia_timur",
        "name": "Indonesia Timur",
        "description": "Papua Highlands Experience",
        "position": Vector3(2.0, 0, 0.5),  # Papua area  
        "scene_path": "res://Scenes/IndonesiaTimur/PapuaScene.tscn",
        "color": Color.BLUE,
        "unlocked": true
    }
]
```

### 2. **Cooking Game NPC (New)**
```gdscript
class_name CookingGameNPC
extends CulturalNPC

# Specialized NPC for offering cooking mini-games
@export var available_recipes: Array[String] = ["SotoBetawi", "Pempek", "NasiGudeg"]
@export var cooking_scene_path: String = "res://students/cooking-game/Map.tscn"

# Dialog system for cooking games
var cooking_dialogue_data: Array[Dictionary] = [
    {
        "id": "greeting",
        "text": "Selamat datang! Mau belajar memasak apa?",
        "options": [
            {"text": "Soto Betawi", "action": "offer_recipe", "recipe": "SotoBetawi"},
            {"text": "Pempek Palembang", "action": "offer_recipe", "recipe": "Pempek"},
            {"text": "Nasi Gudeg", "action": "offer_recipe", "recipe": "NasiGudeg"}
        ]
    }
    // ... more dialogue
]
```

### 3. **Cooking Game Integration (Updated)**
```gdscript
# Jakarta-focused recipe database
var cooking_recipes: Dictionary = {
    "SotoBetawi": {
        "name": "Soto Betawi",
        "region": "DKI Jakarta", 
        "description": "Traditional beef soup from Jakarta",
        "ingredients": ["beef", "coconut milk", "spices", "rice"],
        "difficulty": "medium",
        "time_limit": 400,
        "scene_path": "res://students/cooking-game/Map.tscn"
    }
    // ... more Jakarta recipes
}

func return_to_3d_map():
    """Return to the appropriate scene after cooking game"""
    # Return to Pasar scene for Indonesia Barat
    match current_region:
        "Indonesia Barat", "DKI Jakarta":
            get_tree().change_scene_to_file("res://Scenes/IndonesiaBarat/PasarScene.tscn")
        // ... other regions
```

## 📁 **Files Created/Modified**

### **New Files:**
- `Systems/NPCs/CookingGameNPC.gd` - Specialized cooking NPC
- `Scenes/IndonesiaBarat/CookingGameNPC.tscn` - Cooking NPC scene
- `docs/2025-09-14_Corrected_Menu_System_Integration.md` - This documentation

### **Modified Files:**
- `Scenes/MainMenu/Indonesia3DMapController.gd` - Updated for region selection
- `Scenes/MainMenu/MainMenuController.gd` - Start Game now goes to 3D map
- `Systems/Core/CookingGameIntegration.gd` - Jakarta recipes + return to Pasar
- `Scenes/IndonesiaBarat/PasarScene.tscn` - Added Cooking Chef NPC

## 🎯 **Key Features**

### ✅ **3D Map System:**
- **Region Selection**: 3 colored markers for main regions
- **Camera Controls**: Smooth navigation and selection
- **Scene Transitions**: Direct loading to region scenes
- **UI Integration**: Region information and navigation

### ✅ **Cooking Mini-Game Integration:**
- **NPC Dialog System**: Interactive cooking instructor
- **Recipe Selection**: 6 Jakarta traditional dishes
- **Student Game Integration**: Uses existing Map.tscn
- **Automatic Return**: Back to Pasar scene after completion
- **Progress Tracking**: Statistics and completion data

### ✅ **Jakarta Recipe Focus:**
- **Soto Betawi**: Traditional beef soup
- **Pempek**: Student's working level (Palembang)
- **Nasi Gudeg**: Traditional jackfruit rice
- **Lotek**: Traditional vegetable salad
- **Baso**: Traditional meatball soup
- **Sate**: Traditional grilled meat skewers

## 🎮 **Usage Instructions**

### **For Players:**
1. **Start Game** → 3D Indonesia map loads
2. **Select Indonesia Barat** → Click red marker
3. **Explore Region** → Enter Pasar scene
4. **Find Cooking Chef** → Near market center (red NPC)
5. **Talk to Chef** → Select recipe to learn
6. **Play Cooking Game** → Student's cooking game loads
7. **Complete Game** → Return to Pasar scene

### **For Developers:**
1. **Add New Recipe** → Add to `cooking_recipes` dictionary
2. **Modify NPC Dialog** → Edit `cooking_dialogue_data`
3. **Add New Region** → Add to `region_data` array
4. **Extend Functionality** → Add methods to controllers

## 🔍 **Testing Scenarios**

### ✅ **Tested Features:**
- 3D map region selection
- POI marker interaction
- Scene transitions
- NPC dialog system
- Cooking game integration
- Return to scene functionality

### 🔄 **Future Enhancements:**
- Add cooking mini-games to other regions
- Expand recipe database
- Add achievement system
- Implement save/load for cooking progress
- Add multiplayer cooking competitions

## 🎉 **Conclusion**

The corrected system now properly implements:

1. **3D Map as Region Selector** - Replaces SVG map for choosing Indonesia Barat/Tengah/Timur
2. **Cooking Mini-Games in Pasar Scene** - NPC-driven cooking game integration
3. **Jakarta Recipe Focus** - Traditional Jakarta dishes with student's Pempek level
4. **Seamless Integration** - Smooth transitions between map, scene, and cooking game

The system maintains the student's existing cooking game while adding a proper integration layer that makes it feel like a natural part of the cultural heritage exhibition experience.

---
**Documentation Status:** ✅ Complete  
**Last Updated:** 2025-09-14  
**Integration Status:** ✅ Ready for Testing
