# Terrain3D Integration - Decomposition Plan

**Date:** 2025-08-28  
**Goal:** Safe, incremental terrain integration without breaking existing code  
**Approach:** Decomposition thinking, step-by-step implementation, rollback safety  

## Decomposition Strategy

### Phase 0: Preparation & Safety (Before Any Changes)

#### Step 0.1: Create Backup Branch
```bash
# Create backup of current working state
git checkout -b backup-before-terrain-integration
git add .
git commit -m "Backup: Working state before terrain integration"
git checkout main
```

#### Step 0.2: Document Current State
- **Current Working Systems:**
  - Player movement and interaction
  - NPC dialogue system
  - Scene transitions
  - UI systems (radar, dialogue)
  - Audio system
  - Inventory system

- **Current Scene Structure:**
  - `Scenes/IndonesiaTimur/PapuaScene.tscn` (working)
  - `Scenes/IndonesiaTengah/TamboraScene.tscn` (working)
  - `Scenes/IndonesiaBarat/PasarScene.tscn` (working)

 - **Verification Snapshot (2025-08-28):**
   - Branches: `backup-before-terrain-integration` created, `terrain-integration-test` created.
   - Logging: `Systems/Core/GameLogger.gd` writes to `logs/game_log_*.log` and respects `Systems/Core/DebugConfig.gd` level/env.
   - Tests: Custom test harness present (`Tests/TestRunner.tscn`, `Tests/run_tests.gd`). Ready to run.
   - Player/Interaction: Controllers present (`Player Controller/PlayerController.gd`, `InteractionController.gd`). No changes made.
   - Systems Inventory: `Systems/Core`, `Systems/NPCs`, `Systems/UI`, `Systems/Commands`, `Systems/Audio` present and compile.
   - Non-Goals acknowledged for Phase 0: No terrain changes, no scene migrations, isolation-only work.

#### Step 0.3: Create Test Environment
```bash
# Create test branch for terrain development
git checkout -b terrain-integration-test
```

### Phase 1: Foundation Setup (Safe, Non-Destructive)

#### Step 1.1: Add Terrain3D Addon (Isolated)
**Goal:** Add addon without affecting existing code
**Location:** `addons/terrain_3d/`
**Action:**
1. Copy `addons/terrain_3d/` from examples to project
2. Update `project.godot` to enable addon
3. Test that project still compiles
4. Verify existing scenes still work

**Rollback Plan:** Remove addon folder and revert `project.godot`

#### Step 1.2: Create Terrain Directory Structure (Isolated)
**Goal:** Set up folder structure without affecting existing files
**Action:**
```
Assets/
├── Terrain/
│   ├── Papua/
│   ├── Tambora/
│   └── Shared/
Systems/
└── Terrain/
```

**Rollback Plan:** Delete new directories

#### Step 1.3: Create Base Terrain System (Isolated)
**Goal:** Create terrain management system without integration
**Files to Create:**
- `Systems/Terrain/TerrainManager.gd`
- `Systems/Terrain/TerrainMaterialFactory.gd`
- `Systems/Terrain/PSXAssetManager.gd`

**Action:**
1. Create each file with basic structure
2. No integration with existing systems yet
3. Test that files compile
4. Verify existing scenes still work

**Rollback Plan:** Delete new files

### Phase 2: PSX Asset Organization (Safe, Non-Destructive)

#### Step 2.1: Organize PSX Assets (Isolated)
**Goal:** Organize PSX assets without affecting existing assets
**Action:**
1. Create `Assets/Terrain/Shared/psx_models/` structure
2. Create symbolic links or copy PSX assets to organized structure
3. Keep original assets untouched
4. Test that existing scenes still work

**Rollback Plan:** Remove organized structure, keep originals

#### Step 2.2: Create PSX Asset Packs (Isolated)
**Goal:** Create asset resource files without integration
**Files to Create:**
- `Assets/Terrain/Papua/psx_assets.tres`
- `Assets/Terrain/Tambora/psx_assets.tres`

**Action:**
1. Create basic asset pack resources
2. Reference PSX models and textures
3. Test that resources load correctly
4. Verify existing scenes still work

**Rollback Plan:** Delete asset pack files

### Phase 3: Test Scene Creation (Isolated Development)

#### Step 3.1: Create Test Terrain Scene (Isolated)
**Goal:** Create terrain test scene without affecting existing scenes
**Action:**
1. Create `Tests/test_terrain.tscn`
2. Create `Tests/test_terrain.gd`
3. Implement basic Terrain3D setup
4. Test terrain functionality in isolation

**Rollback Plan:** Delete test scene files

#### Step 3.2: Create Test PSX Asset Scene (Isolated)
**Goal:** Create PSX asset test scene without affecting existing scenes
**Action:**
1. Create `Tests/test_psx_assets.tscn`
2. Create `Tests/test_psx_assets.gd`
3. Implement PSX asset placement
4. Test PSX functionality in isolation

**Rollback Plan:** Delete test scene files

#### Step 3.3: Integration Testing (Isolated)
**Goal:** Test terrain + PSX integration in isolation
**Action:**
1. Create `Tests/test_terrain_integration.tscn`
2. Combine terrain and PSX assets
3. Test performance and functionality
4. Document any issues

**Rollback Plan:** Delete integration test files

### Phase 4: Papua Integration (Incremental, Safe)

#### Step 4.1: Create Papua Terrain Scene (Parallel)
**Goal:** Create Papua terrain scene alongside existing scene
**Action:**
1. Create `Scenes/IndonesiaTimur/PapuaTerrain.tscn`
2. Create `Scenes/IndonesiaTimur/PapuaPSXAssets.tscn`
3. Implement terrain and PSX assets
4. Test in isolation

**Rollback Plan:** Delete new scene files

#### Step 4.2: Create Papua Integration Script (Parallel)
**Goal:** Create integration script without modifying existing controller
**Action:**
1. Create `Scenes/IndonesiaTimur/PapuaTerrainIntegration.gd`
2. Implement terrain loading logic
3. Test integration script
4. Keep existing `RegionSceneController.gd` untouched

**Rollback Plan:** Delete integration script

#### Step 4.3: Test Papua Integration (Parallel)
**Goal:** Test Papua integration without affecting existing scene
**Action:**
1. Create test scene that loads both old and new systems
2. Compare functionality
3. Test performance
4. Document differences

**Rollback Plan:** Use existing Papua scene

#### Step 4.4: Gradual Papua Migration (Optional)
**Goal:** Gradually migrate Papua to new system
**Action:**
1. Create backup of current Papua scene
2. Implement new terrain system
3. Test thoroughly
4. Keep backup for rollback

**Rollback Plan:** Restore backup scene

### Phase 5: Tambora Integration (Incremental, Safe)

#### Step 5.1: Create Tambora Terrain Scene (Parallel)
**Goal:** Create Tambora terrain scene alongside existing scene
**Action:**
1. Create `Scenes/IndonesiaTengah/TamboraTerrain.tscn`
2. Create `Scenes/IndonesiaTengah/TamboraPSXAssets.tscn`
3. Implement mountain terrain and PSX assets
4. Test in isolation

**Rollback Plan:** Delete new scene files

#### Step 5.2: Test Tambora Integration (Parallel)
**Goal:** Test Tambora integration without affecting existing scene
**Action:**
1. Create test scene for Tambora integration
2. Test mountain-specific features
3. Test performance
4. Document results

**Rollback Plan:** Use existing Tambora scene

### Phase 6: Player Integration (Incremental, Safe)

#### Step 6.1: Create Terrain-Aware Player (Parallel)
**Goal:** Create terrain-aware player without modifying existing player
**Action:**
1. Create `Player Controller/PlayerTerrainAware.tscn`
2. Create `Player Controller/PlayerTerrainAware.gd`
3. Implement terrain height detection
4. Test in isolation

**Rollback Plan:** Delete terrain-aware player files

#### Step 6.2: Test Player Integration (Parallel)
**Goal:** Test player integration without affecting existing player
**Action:**
1. Test terrain-aware player with terrain scenes
2. Compare with existing player functionality
3. Test performance
4. Document differences

**Rollback Plan:** Use existing player

### Phase 7: Navigation Integration (Incremental, Safe)

#### Step 7.1: Create Terrain Navigation (Parallel)
**Goal:** Create terrain navigation without affecting existing navigation
**Action:**
1. Create `Systems/Terrain/TerrainNavigationBaker.gd`
2. Implement terrain navigation baking
3. Test in isolation
4. Document functionality

**Rollback Plan:** Delete navigation files

#### Step 7.2: Test Navigation Integration (Parallel)
**Goal:** Test navigation integration without affecting existing systems
**Action:**
1. Test terrain navigation with NPCs
2. Test pathfinding on terrain
3. Test performance
4. Document results

**Rollback Plan:** Use existing navigation

### Phase 8: Final Integration (Optional, Safe)

#### Step 8.1: Gradual Scene Migration (Optional)
**Goal:** Gradually migrate scenes to new system
**Action:**
1. Create feature flag system
2. Allow switching between old and new systems
3. Test both systems thoroughly
4. Document migration process

**Rollback Plan:** Use feature flags to switch back

#### Step 8.2: Performance Optimization (Optional)
**Goal:** Optimize performance without breaking functionality
**Action:**
1. Profile terrain performance
2. Optimize PSX asset rendering
3. Test performance improvements
4. Document optimizations

**Rollback Plan:** Revert optimizations if needed

## Safety Measures

### Before Each Step
1. **Create Git Branch:** `git checkout -b step-X-description`
2. **Test Current State:** Verify existing scenes work
3. **Document Current State:** Note what's working

### During Each Step
1. **Isolated Development:** Work in separate files/scenes
2. **Frequent Testing:** Test after each small change
3. **Documentation:** Document what was changed

### After Each Step
1. **Test Existing Systems:** Verify nothing broke
2. **Commit Changes:** `git add . && git commit -m "Step X: Description"`
3. **Document Results:** Note what works and what doesn't

### Rollback Strategy
1. **Immediate Rollback:** `git reset --hard HEAD~1`
2. **Branch Rollback:** `git checkout main && git branch -D step-X-description`
3. **Full Rollback:** `git checkout backup-before-terrain-integration`

## Success Criteria for Each Step

### Step Success Criteria
- ✅ Existing scenes still work
- ✅ New functionality works in isolation
- ✅ No performance degradation
- ✅ Code compiles without errors
- ✅ Documentation updated

### Phase Success Criteria
- ✅ All steps in phase completed
- ✅ Integration tested thoroughly
- ✅ Rollback plan verified
- ✅ Performance acceptable
- ✅ Documentation complete

## Next Steps

1. **Review this decomposition plan**
2. **Start with Phase 0: Preparation & Safety**
3. **Begin Step 0.1: Create Backup Branch**
4. **Proceed step-by-step with safety measures**

## Questions Before Starting

1. **Git Setup:** Do you have Git configured for this project?
2. **Backup Strategy:** Are you comfortable with the backup approach?
3. **Testing Approach:** Do you want to test each step individually?
4. **Timeline:** How much time do you want to spend on each phase?
5. **Priority:** Which phase should we prioritize first?

This decomposition approach ensures we can safely implement terrain integration without risking the working code. Each step is isolated and has a clear rollback plan.
