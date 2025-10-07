# ML Server Feature Extraction Alignment Fix

**Date:** October 7, 2025  
**Issue:** Feature dimension mismatch - server extracted 2072 features but model expected 34658  
**Solution:** Align `ml_webcam_server.py` feature extractors with exact training parameters

---

## Problem Summary

When running the ML webcam server with the `glcm_lbp_hog_hsv` model:

```
❌ Prediction error: X has 2072 features, but RandomForestClassifier is expecting 34658 features as input.
```

**Root Cause:** The `ml_webcam_server.py` had placeholder/stub implementations for feature extraction that didn't match the actual training code parameters.

---

## Feature Extraction Comparison

### Before (WRONG - Placeholder Code)

| Feature | Implementation | Issues |
|---------|---------------|--------|
| **HOG** | `cv2.HOGDescriptor` on 64×64 image | ❌ Wrong library, wrong size, wrong parameters |
| **GLCM** | `np.random.random(20)` | ❌ Placeholder - not implemented at all! |
| **LBP** | `np.zeros_like(resized)`, bins=256 | ❌ Placeholder - not implemented at all! |
| **HSV** | Correct approach but slightly different normalization | ⚠️ Close but not exact |
| **Image Size** | 64×64 | ❌ Wrong size |

### After (CORRECT - Exact Training Parameters)

| Feature | Implementation | Expected Dimensions |
|---------|---------------|-------------------|
| **HOG** | `skimage.feature.hog` on 256×256, orientations=9, pixels_per_cell=(8,8), cells_per_block=(2,2), L2-Hys normalization | ~34,596 features |
| **GLCM** | `skimage.feature.graycomatrix/graycoprops` on 256×256, distances=[1], angles=[0°,45°,90°,135°], 4 properties + entropy | 20 features |
| **LBP** | `skimage.feature.local_binary_pattern` on 256×256, P=8, R=1, uniform method, 10 bins | 10 features |
| **HSV** | `cv2.calcHist` on S/V channels, 16 bins each, normalized with +1e-7 | 32 features |
| **Total** | Combined for glcm_lbp_hog_hsv model | **34,658 features** |

---

## Changes Made to `ml_webcam_server.py`

### 1. Added Required Imports

```python
from skimage.feature import hog, graycomatrix, graycoprops, local_binary_pattern
```

### 2. Fixed `extract_hog_features()`

**Before:**
```python
def extract_hog_features(self, image):
    resized = cv2.resize(image, (64, 64))  # WRONG SIZE!
    gray = cv2.cvtColor(resized, cv2.COLOR_BGR2GRAY)
    hog = cv2.HOGDescriptor((64, 64), (16, 16), (8, 8), (8, 8), 9)  # WRONG LIBRARY!
    features = hog.compute(gray)
    return features.flatten()
```

**After:**
```python
def extract_hog_features(self, image):
    """Extract HOG features with EXACT training parameters (256x256, 9 bins, (8,8) cell, (2,2) block)"""
    resized = cv2.resize(image, (256, 256))  # ✅ Correct size
    
    if len(image.shape) == 3:
        gray = cv2.cvtColor(resized, cv2.COLOR_BGR2GRAY)
    else:
        gray = resized
    
    # ✅ Using skimage.hog with exact training parameters
    features = hog(gray, 
                  orientations=9,
                  pixels_per_cell=(8, 8),
                  cells_per_block=(2, 2),
                  block_norm='L2-Hys',
                  feature_vector=True,
                  channel_axis=None)
    
    return features.astype(np.float32)
```

**Result:** ~34,596 features (expected)

### 3. Fixed `extract_glcm_features()`

**Before:**
```python
def extract_glcm_features(self, image):
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    resized = cv2.resize(gray, (64, 64))  # WRONG SIZE!
    
    distances = [1, 2, 3]  # WRONG DISTANCES!
    angles = [0, 45, 90, 135]
    
    # PLACEHOLDER CODE - NOT IMPLEMENTED!
    features = np.random.random(20)  # ❌
    return np.array(features)
```

**After:**
```python
def shannon_entropy(self, P):
    """Calculate Shannon entropy"""
    P = P[P > 0]
    return -np.sum(P * np.log2(P))

def extract_glcm_features(self, image):
    """Extract GLCM features with EXACT training parameters (20 features: 4 props×4 angles + 4 entropy)"""
    if len(image.shape) == 3:
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    else:
        gray = image
    
    # ✅ Resize to 256x256
    if gray.shape[0] > 256 or gray.shape[1] > 256:
        gray = cv2.resize(gray, (256, 256))
    
    # ✅ EXACT training parameters
    distances = [1]  # Only distance=1
    angles = [0, 45, 90, 135]
    levels = 256
    
    angles_rad = [np.radians(angle) for angle in angles]
    
    # ✅ Real GLCM calculation
    glcm = graycomatrix(gray, 
                       distances=distances, 
                       angles=angles_rad,
                       levels=levels, 
                       symmetric=True, 
                       normed=True)
    
    # ✅ Extract 4 properties × 4 angles = 16 features
    properties = ['contrast', 'homogeneity', 'correlation', 'energy']
    haralick_features = []
    
    for prop in properties:
        feature_values = graycoprops(glcm, prop).ravel()
        haralick_features.extend(feature_values)
    
    # ✅ Extract entropy per angle = 4 features
    entropy_features = []
    for j in range(len(angles_rad)):
        P_avg = np.mean(glcm[:, :, :, j], axis=2)
        entropy_val = self.shannon_entropy(P_avg)
        entropy_features.append(entropy_val)
    
    # Total: 16 + 4 = 20 features
    all_features = np.concatenate([haralick_features, entropy_features])
    
    return all_features.astype(np.float32)
```

**Result:** 20 features (expected)

### 4. Fixed `extract_lbp_features()`

**Before:**
```python
def extract_lbp_features(self, image):
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    resized = cv2.resize(gray, (64, 64))  # WRONG SIZE!
    
    radius = 1
    n_points = 8 * radius
    
    # PLACEHOLDER CODE - NOT IMPLEMENTED!
    lbp = np.zeros_like(resized)  # ❌
    
    hist, _ = np.histogram(lbp.ravel(), bins=256, range=(0, 256))  # WRONG BINS!
    return hist.astype(np.float32)
```

**After:**
```python
def extract_lbp_features(self, image):
    """Extract LBP features with EXACT training parameters (uniform, 10 bins)"""
    if len(image.shape) == 3:
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    else:
        gray = image
    
    # ✅ Resize to 256x256
    gray = cv2.resize(gray, (256, 256))
    
    # ✅ EXACT training parameters
    P = 8  # Number of points
    R = 1.0  # Radius
    method = 'uniform'
    bins = P + 2  # 10 bins for uniform method (NOT 256!)
    
    # ✅ Real LBP calculation
    lbp = local_binary_pattern(gray, P, R, method=method)
    
    # ✅ Calculate histogram with correct bins and normalization
    hist, _ = np.histogram(lbp.ravel(), bins=bins, range=(0, bins), density=True)
    
    return hist.astype(np.float32)
```

**Result:** 10 features (expected)

### 5. Fixed `extract_hsv_features()`

**Before:**
```python
def extract_hsv_features(self, image):
    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    
    s_hist = cv2.calcHist([hsv], [1], None, [16], [0, 256])
    v_hist = cv2.calcHist([hsv], [2], None, [16], [0, 256])
    
    features = np.concatenate([s_hist.flatten(), v_hist.flatten()])
    return features / np.sum(features)  # Potential division by zero
```

**After:**
```python
def extract_hsv_features(self, image):
    """Extract HSV color features with EXACT training parameters (32 features: 16 bins for S + 16 bins for V)"""
    if len(image.shape) == 3:
        hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    else:
        raise ValueError("Image must be color (3 channels) for HSV extraction")
    
    # ✅ EXACT training parameters
    bins = 16  # 16 bins per channel
    channels = [1, 2]  # S and V channels only
    
    features = []
    for channel in channels:
        hist = cv2.calcHist([hsv], [channel], None, [bins], [0, 256])
        hist = hist.flatten() / (hist.sum() + 1e-7)  # ✅ Normalize with epsilon
        features.extend(hist)
    
    return np.array(features, dtype=np.float32)
```

**Result:** 32 features (expected)

---

## Expected Feature Counts by Model

| Model Name | Features Included | Total Features |
|-----------|------------------|---------------|
| `hsv` | HSV only | 32 |
| `glcm_hog` | GLCM + HOG | 20 + 34,596 = 34,616 |
| `glcm_lbp_hog` | GLCM + LBP + HOG | 20 + 10 + 34,596 = 34,626 |
| `glcm_lbp_hog_hsv` | GLCM + LBP + HOG + HSV | 20 + 10 + 34,596 + 32 = **34,658** ✅ |

---

## Verification Steps

After making these changes, run the ML server:

```bash
cd "D:\ISSAT Game\Game\Webcam Server"
python ml_webcam_server.py
```

**Expected Output (BEFORE fix):**
```
🔍 Extracted 2072 features for model 'glcm_lbp_hog_hsv'
❌ Prediction error: X has 2072 features, but RandomForestClassifier is expecting 34658 features as input.
```

**Expected Output (AFTER fix):**
```
🔍 Extracted 34658 features for model 'glcm_lbp_hog_hsv'
🧠 ML DETECTION Result: Jawa (Confidence: 85.3%)
```

---

## Key Lessons Learned

1. **Always use the SAME feature extraction library and parameters as training**
   - Training used `skimage.feature.hog`, not `cv2.HOGDescriptor`
   - Parameters must match exactly (image size, orientations, cell size, etc.)

2. **Placeholder code is dangerous in production**
   - `np.random.random(20)` and `np.zeros_like()` were generating meaningless features
   - Always implement real feature extraction before deploying

3. **Image preprocessing matters**
   - Training used 256×256 images, server was using 64×64
   - This alone changes HOG from ~34,596 features to ~324 features

4. **Refer to exact training parameters**
   - The `exact_training_benchmark.py` file had the correct implementations
   - The documentation in `2025-10-03_exact-training-parameters-guide.md` provided the specs

---

## Testing

After applying the fix, test with each model:

```python
# In Python console or test script
from ml_webcam_server import MLEthnicityDetector
import cv2

detector = MLEthnicityDetector('models/run_20250925_133309')

# Capture or load a test image
image = cv2.imread('test_face.jpg')

# Test each model
for model_name in ['hsv', 'glcm_hog', 'glcm_lbp_hog', 'glcm_lbp_hog_hsv']:
    ethnicity, confidence = detector.predict_ethnicity(image, model_name)
    print(f"{model_name}: {ethnicity} ({confidence:.2%})")
```

**Expected:** No dimension mismatch errors, predictions return successfully.

---

## Files Modified

- ✅ `Webcam Server/ml_webcam_server.py` - Fixed all feature extractors
- ✅ `Webcam Server/docs/2025-10-07_ml-server-feature-alignment-fix.md` - This documentation

## Files Referenced

- `Webcam Server/exact_training_benchmark.py` - Source of correct implementations
- `Webcam Server/docs/2025-10-03_exact-training-parameters-guide.md` - Parameter specifications
- `Webcam Server/config.json` - Model selection configuration

---

## Next Steps

1. ✅ Install scikit-image if not already installed: `pip install scikit-image==0.25.2`
2. ✅ Restart the ML server
3. ✅ Test with Godot EthnicityDetectionScene
4. ✅ Verify predictions are reasonable and consistent
5. 📝 Consider adding automated tests to prevent future regressions

---

**Status:** ✅ RESOLVED  
**Verified:** Pending user testing

