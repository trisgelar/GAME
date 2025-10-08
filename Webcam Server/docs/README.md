# ML Ethnicity Detection Server - Documentation

**Last Updated:** October 8, 2025

This folder contains documentation for the ML Ethnicity Detection Server.

---

## 📚 Documentation Index

### October 8, 2025 - Dual Webcam Implementation

**New Features:**
- **[2025-10-08_continuous-operation.md](2025-10-08_continuous-operation.md)** - Continuous webcam operation documentation
- **[2025-10-08_dual-webcam-quick-start.md](2025-10-08_dual-webcam-quick-start.md)** - Quick start guide for dual webcam
- **[2025-10-08_dual-server-stability-fix.md](2025-10-08_dual-server-stability-fix.md)** - Dual server stability improvements
- **[2025-10-08_webcam-resource-fix.md](2025-10-08_webcam-resource-fix.md)** - Webcam resource conflict fixes
- **[2025-10-08_feature-verification.md](2025-10-08_feature-verification.md)** - Feature verification tests
- **[2025-10-08_integration-status.md](2025-10-08_integration-status.md)** - Integration status
- **[2025-10-08_integration-complete.md](2025-10-08_integration-complete.md)** - Integration completion
- **[2025-10-08_dual-server-readme.md](2025-10-08_dual-server-readme.md)** - Dual server README
- **[2025-10-08_topeng-nusantara-integration-guide.md](2025-10-08_topeng-nusantara-integration-guide.md)** - Topeng integration guide
- **[2025-10-08_ml-server-changes-detailed-explanation.md](2025-10-08_ml-server-changes-detailed-explanation.md)** - ML server changes

### October 7, 2025 - Multi-Scene Architecture

**Architecture:**
- **[2025-10-07_multi-scene-webcam-architecture.md](2025-10-07_multi-scene-webcam-architecture.md)** - Multi-scene webcam architecture
- **[2025-10-07_multi-scene-webcam-summary.md](2025-10-07_multi-scene-webcam-summary.md)** - Multi-scene summary
- **[2025-10-07_ml-server-feature-alignment-fix.md](2025-10-07_ml-server-feature-alignment-fix.md)** - ML feature alignment fixes

### October 3, 2025 - ML System & Refactoring

**ML System:**
- **[2025-10-03_ml-ethnicity-detection-guide.md](2025-10-03_ml-ethnicity-detection-guide.md)** - ML ethnicity detection guide
- **[2025-10-03_exact-training-parameters-guide.md](2025-10-03_exact-training-parameters-guide.md)** - Exact training parameters
- **[2025-10-03_model-management-system.md](2025-10-03_model-management-system.md)** - Model management
- **[2025-10-03_configuration-management-system.md](2025-10-03_configuration-management-system.md)** - Configuration management

**Architecture:**
- **[2025-10-03_solid-architecture-refactoring.md](2025-10-03_solid-architecture-refactoring.md)** - SOLID architecture refactoring
- **[2025-10-03_refactoring-summary.md](2025-10-03_refactoring-summary.md)** - Refactoring summary
- **[2025-10-03_implementation-summary.md](2025-10-03_implementation-summary.md)** - Implementation summary
- **[2025-10-03_readme-refactored.md](2025-10-03_readme-refactored.md)** - Refactored README

**Setup & Testing:**
- **[2025-10-03_quick-start-guide.md](2025-10-03_quick-start-guide.md)** - Quick start guide
- **[2025-10-03_setup-and-branch-management.md](2025-10-03_setup-and-branch-management.md)** - Setup and branch management
- **[2025-10-03_testing-and-validation.md](2025-10-03_testing-and-validation.md)** - Testing and validation
- **[2025-10-03_comprehensive-logging-system.md](2025-10-03_comprehensive-logging-system.md)** - Logging system

**Legacy:**
- **[README_IMPLEMENTATION_SUMMARY.md](README_IMPLEMENTATION_SUMMARY.md)** - Implementation summary (old format)

---

## 🎯 Quick Links

### For Users

**Getting Started:**
1. Read: [2025-10-08_dual-webcam-quick-start.md](2025-10-08_dual-webcam-quick-start.md)
2. Read: [2025-10-03_quick-start-guide.md](2025-10-03_quick-start-guide.md)
3. See: `../README.md` for main overview

**Troubleshooting:**
- [2025-10-08_webcam-resource-fix.md](2025-10-08_webcam-resource-fix.md)
- [2025-10-08_dual-server-stability-fix.md](2025-10-08_dual-server-stability-fix.md)

### For Developers

**Architecture:**
- [2025-10-07_multi-scene-webcam-architecture.md](2025-10-07_multi-scene-webcam-architecture.md)
- [2025-10-03_solid-architecture-refactoring.md](2025-10-03_solid-architecture-refactoring.md)
- `../ARCHITECTURE.md` (Parent folder)

**ML System:**
- [2025-10-03_ml-ethnicity-detection-guide.md](2025-10-03_ml-ethnicity-detection-guide.md)
- [2025-10-03_exact-training-parameters-guide.md](2025-10-03_exact-training-parameters-guide.md)
- [2025-10-03_model-management-system.md](2025-10-03_model-management-system.md)

---

## 🚀 Quick Start

### Setup

```bash
cd "Webcam Server"
python -m venv env
env\Scripts\activate.bat
pip install -r requirements.txt
```

### Start Server

```bash
cd "Webcam Server"
start_ml_ethnicity_server.bat
```

**Or manually:**
```bash
cd "Webcam Server"
env\Scripts\activate.bat
python ml_webcam_server.py
```

---

## 🧠 ML Models

**Location:** `../models/run_20250925_133309/`

**Available Models:**
- `glcm_lbp_hog_hsv` - All features (Best, 96.44% accuracy)
- `glcm_lbp_hog` - GLCM + LBP + HOG
- `glcm_hog` - GLCM + HOG
- `hsv` - HSV color only (99.72% accuracy)
- `hog` - HOG only
- `glcm` - GLCM only
- `lbp` - LBP only

**See:** [2025-10-03_ml-ethnicity-detection-guide.md](2025-10-03_ml-ethnicity-detection-guide.md)

---

## 📝 Main Documentation Files

**In Parent Folder:**
- **`../README.md`** - Main ML server overview
- **`../README_ML.md`** - ML system documentation
- **`../README_START_HERE.md`** - Start here guide
- **`../README_INDEX.md`** - Documentation index
- **`../QUICK_START.md`** - Quick start reference
- **`../ARCHITECTURE.md`** - Architecture overview

---

## 🔧 Configuration

### Camera Configuration

**File:** `../config.json`

```json
{
  "camera": {
    "camera_id": 0,
    "notes": "Camera ID 0 = First USB webcam"
  }
}
```

**See:** [2025-10-03_configuration-management-system.md](2025-10-03_configuration-management-system.md)

---

## 🎯 Key Features

### ML Ethnicity Detection
- Real-time face detection
- Multiple ML models
- Automatic detection (every 2 seconds)
- Confidence scoring

### UDP Video Streaming
- Port 8888
- Optimized 640x480 @ 15FPS
- JPEG compression (Q40)
- Efficient packet fragmentation

### Continuous Operation
- Camera always active (dedicated hardware)
- No pause/resume bugs
- Instant client connections

**See:** [2025-10-08_continuous-operation.md](2025-10-08_continuous-operation.md)

---

## 📖 Related Documentation

### Root Documentation
- `../../docs/` - Project-wide dual webcam docs
- `../../README_SERVERS.md` - Dual server architecture

### Topeng Server Documentation
- `../../Topeng Server/docs/` - Topeng server docs

---

## 🔄 Documentation Organization

**Date Format:** `YYYY-MM-DD_title-with-hyphens.md`

**Categories:**
- **Setup** - Installation and configuration guides
- **ML System** - Machine learning documentation
- **Architecture** - System design and structure
- **Integration** - Component integration guides
- **Fixes** - Bug fixes and improvements

---

**Server Status:** ✅ Production Ready  
**Port:** 8888  
**Camera:** ID 0 (USB)  
**ML Models:** 7 models available
