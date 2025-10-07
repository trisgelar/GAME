# Setup and Branch Management Guide

**Date:** 2025-10-03  
**Project:** ISSAT-PCD-Walking-Simulator  
**Branch:** ml-ethnicity-detection  

## Overview

This document provides step-by-step instructions for setting up the project, managing git branches, and working with the ML-enhanced ethnicity detection system.

## Prerequisites

- Git installed on your system
- Python 3.8+ installed
- Godot 4.x installed
- Webcam/camera access

## 1. Initial Project Setup

### Clone the Repository

```bash
# Clone the main repository
git clone https://github.com/your-username/ISSAT-PCD-Walking-Simulator.git

# Navigate to project directory
cd ISSAT-PCD-Walking-Simulator
```

### Verify Initial Setup

```bash
# Check current branch (should be 'master')
git branch

# Check repository status
git status

# View available branches
git branch -a
```

Expected output:
```
* master
  remotes/origin/face-swap
  remotes/origin/gui-update
  remotes/origin/map-indonesia-timur
  remotes/origin/master
  remotes/origin/udp-version
```

## 2. Branch Management

### Switch to GUI Update Branch

```bash
# Switch to the gui-update branch
git checkout gui-update

# Verify branch switch
git branch
```

Expected output:
```
  master
* gui-update
```

### Create New ML Branch

```bash
# Create and switch to new ML branch from gui-update
git checkout -b ml-ethnicity-detection

# Verify new branch creation
git branch
```

Expected output:
```
  gui-update
  master
* ml-ethnicity-detection
```

### Verify Branch Status

```bash
# Check current branch and status
git status

# View branch information
git log --oneline -5
```

## 3. Project Structure Overview

After setup, your project structure should look like:

```
ISSAT-PCD-Walking-Simulator/
├── Walking Simulator/                    # Godot game project
│   ├── Scenes/
│   │   └── EthnicityDetection/          # Ethnicity detection scenes
│   │       ├── MLEthnicityDetectionController.gd
│   │       └── WebcamClient/
│   │           └── MLWebcamManager.gd
│   └── ...
├── Webcam Server/                       # Python ML server
│   ├── ml_webcam_server.py             # Main ML server
│   ├── test_ml_server.py               # Test script
│   ├── requirements.txt                # Python dependencies
│   └── models/                         # Trained ML models
│       └── run_20250925_133309/
└── docs/                               # Documentation
    ├── 2025-10-03_setup-and-branch-management.md
    └── 2025-10-03_ml-ethnicity-detection-guide.md
```

## 4. Branch Workflow

### Daily Development Workflow

```bash
# 1. Check current branch
git branch

# 2. Pull latest changes (if working with team)
git pull origin ml-ethnicity-detection

# 3. Make your changes
# ... edit files ...

# 4. Check status
git status

# 5. Add changes
git add .

# 6. Commit changes
git commit -m "Add ML ethnicity detection feature"

# 7. Push to remote (if needed)
git push origin ml-ethnicity-detection
```

### Switching Between Branches

```bash
# Switch to master branch
git checkout master

# Switch back to ML branch
git checkout ml-ethnicity-detection

# Switch to gui-update branch
git checkout gui-update
```

### Branch Comparison

```bash
# Compare current branch with master
git diff master

# Compare with gui-update branch
git diff gui-update

# View commit history
git log --oneline --graph --all
```

## 5. Troubleshooting Branch Issues

### Common Issues and Solutions

#### Issue: "Your branch is ahead of origin"
```bash
# Push your changes to remote
git push origin ml-ethnicity-detection
```

#### Issue: "Your branch is behind origin"
```bash
# Pull latest changes
git pull origin ml-ethnicity-detection
```

#### Issue: Merge conflicts
```bash
# Check conflicted files
git status

# Resolve conflicts in files
# ... edit conflicted files ...

# Add resolved files
git add .

# Complete merge
git commit
```

#### Issue: Accidentally on wrong branch
```bash
# Check current branch
git branch

# Switch to correct branch
git checkout ml-ethnicity-detection

# If you made changes on wrong branch, stash them
git stash
git checkout ml-ethnicity-detection
git stash pop
```

## 6. Branch Information

### Current Branch: `ml-ethnicity-detection`

**Purpose:** Development of ML-enhanced ethnicity detection system  
**Base Branch:** `gui-update`  
**Created:** 2025-10-03  
**Status:** Active development  

### Key Features in This Branch:

- ✅ ML-enhanced webcam server
- ✅ Real-time ethnicity detection
- ✅ Multiple ML model support
- ✅ Enhanced Godot client
- ✅ Model selection UI
- ✅ Confidence scoring
- ✅ Fallback system

### Files Added/Modified:

**New Files:**
- `Webcam Server/ml_webcam_server.py`
- `Webcam Server/test_ml_server.py`
- `Webcam Server/README_ML.md`
- `Walking Simulator/Scenes/EthnicityDetection/MLEthnicityDetectionController.gd`
- `Walking Simulator/Scenes/EthnicityDetection/WebcamClient/MLWebcamManager.gd`
- `docs/` folder with documentation

**Modified Files:**
- `Webcam Server/requirements.txt` (added ML dependencies)

## 7. Next Steps

After completing branch setup:

1. **Install Dependencies** (see ML guide)
2. **Test ML Server** (see ML guide)
3. **Run Godot Client** (see ML guide)
4. **Verify Integration** (see ML guide)

## 8. Branch Maintenance

### Regular Maintenance Tasks

```bash
# Weekly: Update from main branches
git checkout master
git pull origin master
git checkout ml-ethnicity-detection
git merge master

# Before major commits: Clean up
git status
git add .
git commit -m "Descriptive commit message"
```

### Branch Cleanup

```bash
# Remove local branches (when done)
git branch -d old-branch-name

# Remove remote tracking branches
git remote prune origin
```

## 9. Integration with Main Project

### Merging Back to Main Branches

When ML features are complete:

```bash
# 1. Ensure all tests pass
# 2. Update documentation
# 3. Merge to gui-update
git checkout gui-update
git merge ml-ethnicity-detection

# 4. Push to remote
git push origin gui-update

# 5. Create pull request (if using GitHub)
```

## 10. Backup and Recovery

### Create Backup Branch

```bash
# Create backup of current work
git checkout -b ml-ethnicity-detection-backup

# Switch back to main branch
git checkout ml-ethnicity-detection
```

### Recovery from Issues

```bash
# Reset to last known good commit
git log --oneline
git reset --hard <commit-hash>

# Or reset to remote state
git fetch origin
git reset --hard origin/ml-ethnicity-detection
```

---

**Note:** Always commit your work regularly and push to remote to avoid losing changes. Use descriptive commit messages to track your progress.

**Last Updated:** 2025-10-03  
**Next Review:** 2025-10-10
