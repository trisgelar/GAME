# Terrain3D Folder Structure Guide

**Date:** 2025-09-18  
**Status:** Completed  
**Scope:** Folder Organization and File Responsibilities  

## 📁 **Complete Folder Structure**

```
Systems/Terrain3D/
├── Core/                                    # Core business logic
│   ├── Terrain3DBaseController.gd          # Abstract base class
│   ├── Terrain3DBaseController.gd.uid      # Godot UID file
│   ├── Terrain3DPapuaController.gd         # Papua concrete implementation
│   ├── Terrain3DPapuaController.gd.uid     # Godot UID file
│   ├── Terrain3DController.gd              # Facade controller
│   ├── Terrain3DController.gd.uid          # Godot UID file
│   ├── Terrain3DControllerFactory.gd       # Factory for object creation
│   ├── Terrain3DControllerFactory.gd.uid   # Godot UID file
│   ├── Terrain3DInitializer.gd             # Terrain initialization
│   └── Terrain3DInitializer.gd.uid         # Godot UID file
├── Scenes/                                  # Reusable scene components
│   └── Terrain3DAssets.tscn                # Terrain asset scenes
├── Tools/                                   # Development tools
│   ├── Terrain3DEditor.gd                  # Terrain editor tool
│   ├── Terrain3DEditor.gd.uid              # Godot UID file
│   ├── Terrain3DEditor.tscn                # Editor UI scene
│   └── SceneDebugger.gd                    # Scene debugging tool
├── Research/                                # Experimental features
│   ├── Terrain3DResearch.gd                # Research functions
│   ├── Terrain3DResearch.gd.uid            # Godot UID file
│   └── README.md                           # Research documentation
└── README.md                               # Main system documentation
```

## 🎯 **Folder Responsibilities**

### **📂 Core/ - Business Logic**
**Purpose:** Contains the core business logic and main system components.

#### **Files & Responsibilities:**

| File | Responsibility | SOLID Principle |
|------|----------------|-----------------|
| `Terrain3DBaseController.gd` | Abstract base class defining common terrain behavior | SRP, OCP |
| `Terrain3DPapuaController.gd` | Concrete Papua region implementation | LSP |
| `Terrain3DController.gd` | Facade providing simplified interface | ISP |
| `Terrain3DControllerFactory.gd` | Factory for creating controller instances | DIP |
| `Terrain3DInitializer.gd` | Terrain system initialization logic | SRP |

#### **Usage Guidelines:**
- ✅ **DO**: Add new terrain types by extending `Terrain3DBaseController`
- ✅ **DO**: Use factory to create controller instances
- ✅ **DO**: Keep business logic separate from UI concerns
- ❌ **DON'T**: Put UI code in Core folder
- ❌ **DON'T**: Put experimental code in Core folder

### **📂 Scenes/ - Reusable Components**
**Purpose:** Contains reusable scene files and assets.

#### **Files & Responsibilities:**

| File | Responsibility | Usage |
|------|----------------|-------|
| `Terrain3DAssets.tscn` | Reusable terrain asset scenes | Shared across regions |

#### **Usage Guidelines:**
- ✅ **DO**: Create reusable scene components
- ✅ **DO**: Use generic names for cross-region compatibility
- ❌ **DON'T**: Put region-specific scenes here
- ❌ **DON'T**: Put UI scenes here (use Tools folder)

### **📂 Tools/ - Development Tools**
**Purpose:** Contains development and debugging tools.

#### **Files & Responsibilities:**

| File | Responsibility | Usage |
|------|----------------|-------|
| `Terrain3DEditor.gd` | Terrain editing tool | Development only |
| `Terrain3DEditor.tscn` | Editor UI scene | Development only |
| `SceneDebugger.gd` | Scene structure debugging | Debugging |

#### **Usage Guidelines:**
- ✅ **DO**: Add debugging and development tools here
- ✅ **DO**: Keep tools separate from production code
- ❌ **DON'T**: Put production logic in Tools folder
- ❌ **DON'T**: Reference Tools from production scenes

### **📂 Research/ - Experimental Features**
**Purpose:** Contains experimental and research code.

#### **Files & Responsibilities:**

| File | Responsibility | Status |
|------|----------------|--------|
| `Terrain3DResearch.gd` | Experimental terrain functions | Research |
| `README.md` | Research documentation | Documentation |

#### **Usage Guidelines:**
- ✅ **DO**: Put experimental features here
- ✅ **DO**: Test new concepts before moving to Core
- ✅ **DO**: Keep research code isolated
- ❌ **DON'T**: Reference Research code from production
- ❌ **DON'T**: Put stable features in Research

## 🔗 **File Dependencies**

### **Core Dependencies**
```
Terrain3DController.gd (Facade)
    ↓ depends on
Terrain3DControllerFactory.gd
    ↓ creates
Terrain3DBaseController.gd (Abstract)
    ↓ implemented by
Terrain3DPapuaController.gd (Concrete)
```

### **Initialization Flow**
```
Terrain3DInitializer.gd
    ↓ initializes
Terrain3DController.gd
    ↓ uses factory to create
Terrain3DPapuaController.gd
    ↓ extends
Terrain3DBaseController.gd
```

## 📋 **File Naming Conventions**

### **Naming Patterns**
- **Base Classes**: `Terrain3D[Feature]Base[Type].gd`
- **Concrete Classes**: `Terrain3D[Region][Feature][Type].gd`
- **Factories**: `Terrain3D[Feature]Factory.gd`
- **Facades**: `Terrain3D[Feature]Controller.gd`
- **Tools**: `Terrain3D[ToolName].gd`

### **Examples**
```
✅ Good Naming:
- Terrain3DBaseController.gd
- Terrain3DPapuaController.gd
- Terrain3DControllerFactory.gd
- Terrain3DEditor.gd

❌ Bad Naming:
- TerrainController.gd (missing Terrain3D prefix)
- PapuaTerrain3DController.gd (wrong order)
- Terrain3D_Controller.gd (underscore inconsistent)
```

## 🔄 **Migration History**

### **Original Files (Before Refactoring)**
```
Scenes/IndonesiaTimur/
├── PapuaScene_TerrainController.gd      → Systems/Terrain3D/Core/Terrain3DController.gd
├── PapuaScene_Terrain3D_Initializer.gd  → Systems/Terrain3D/Core/Terrain3DInitializer.gd
├── PapuaScene_Terrain3DEditor.gd        → Systems/Terrain3D/Tools/Terrain3DEditor.gd
└── PapuaScene_TerrainAssets.tscn        → Systems/Terrain3D/Scenes/Terrain3DAssets.tscn
```

### **New Files (After Refactoring)**
```
Systems/Terrain3D/Core/
├── Terrain3DBaseController.gd           # NEW: Abstract base class
├── Terrain3DPapuaController.gd          # NEW: Concrete implementation
└── Terrain3DControllerFactory.gd        # NEW: Factory pattern
```

## 🎮 **Scene Integration**

### **Scene File References**
```gdscript
# PapuaScene_Terrain3D.tscn
[ext_resource path="res://Systems/Terrain3D/Core/Terrain3DController.gd" id="13_terrain_controller"]
[ext_resource path="res://Systems/Terrain3D/Core/Terrain3DInitializer.gd" id="14_terrain3d_initializer"]

[node name="TerrainController" type="Node3D" parent="."]
script = ExtResource("13_terrain_controller")

[node name="Terrain3DInitializer" type="Node3D" parent="."]
script = ExtResource("14_terrain3d_initializer")
```

### **Asset Path Updates**
```gdscript
# Old paths (region-specific)
res://Scenes/IndonesiaTimur/PapuaScene_TerrainController.gd

# New paths (system-wide)
res://Systems/Terrain3D/Core/Terrain3DController.gd
```

## 🔧 **UID File Management**

### **UID File Purpose**
- **Godot Integration**: UID files enable proper resource references
- **Version Control**: UID files track resource changes
- **Dependency Management**: Automatic dependency resolution

### **UID File Locations**
```
Systems/Terrain3D/Core/
├── Terrain3DBaseController.gd.uid
├── Terrain3DPapuaController.gd.uid
├── Terrain3DController.gd.uid
├── Terrain3DControllerFactory.gd.uid
└── Terrain3DInitializer.gd.uid
```

### **UID File Maintenance**
- ✅ **DO**: Keep UID files in same directory as their script
- ✅ **DO**: Commit UID files to version control
- ❌ **DON'T**: Manually edit UID files
- ❌ **DON'T**: Delete UID files

## 🚀 **Adding New Files**

### **Adding New Terrain Type**
1. **Create Concrete Class**:
   ```
   Systems/Terrain3D/Core/Terrain3DTamboraController.gd
   ```

2. **Update Factory**:
   ```gdscript
   # Terrain3DControllerFactory.gd
   enum TerrainType { PAPUA, TAMBORA }  # Add new type
   
   static func create_controller(terrain_type: TerrainType) -> Terrain3DBaseController:
       match terrain_type:
           TerrainType.TAMBORA:
               return Terrain3DTamboraController.new()  # Add case
   ```

3. **Generate UID**:
   ```
   Systems/Terrain3D/Core/Terrain3DTamboraController.gd.uid
   ```

### **Adding New Tool**
1. **Create Tool File**:
   ```
   Systems/Terrain3D/Tools/Terrain3DNewTool.gd
   ```

2. **Generate UID**:
   ```
   Systems/Terrain3D/Tools/Terrain3DNewTool.gd.uid
   ```

## 📊 **Folder Size Analysis**

| Folder | Files | Purpose | Stability |
|--------|-------|---------|-----------|
| **Core/** | 5 files | Production code | High |
| **Scenes/** | 1 file | Reusable assets | Medium |
| **Tools/** | 3 files | Development tools | Low |
| **Research/** | 2 files | Experimental code | Very Low |

## 🔍 **Best Practices**

### **File Organization**
- ✅ Keep related files together
- ✅ Use consistent naming conventions
- ✅ Separate concerns by folder
- ✅ Maintain clear dependencies

### **Version Control**
- ✅ Commit all .gd and .tscn files
- ✅ Commit UID files
- ✅ Use descriptive commit messages
- ❌ Don't commit temporary files

### **Documentation**
- ✅ Document folder purposes
- ✅ Keep README files updated
- ✅ Document file dependencies
- ❌ Don't leave undocumented code

---

**Next:** [Extension Guide](2025-09-18_terrain3d_extension_guide.md)
