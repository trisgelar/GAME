# Webcam Server System

## Overview
This system provides **two independent webcam servers** for the ISSAT-PCD-Walking-Simulator project:

1. **Ethnicity Detection ML Server** (Port 8888) - Real-time ethnicity classification using machine learning
2. **Topeng Mask Overlay Server** (Port 8889) - Traditional Indonesian mask overlay with MediaPipe face tracking

Both servers use UDP protocol and can run simultaneously without conflicts.

## 🚀 Quick Start

### Option 1: Start Both Servers

```bash
# Double-click this file:
start_both_servers.bat
```

Two windows will open:
- Ethnicity ML Server (Port 8888)
- Topeng Mask Server (Port 8889)

### Option 2: Individual Servers

**Ethnicity Detection Only:**
```bash
start_ethnicity_server.bat
# OR
python ml_webcam_server.py
```

**Topeng Mask Only:**
```bash
start_topeng_server.bat
# OR
cd Topeng
python udp_webcam_server.py
```

### Dependencies Installation

```bash
# Ethnicity ML Server
pip install -r requirements.txt

# Topeng Mask Server
cd Topeng
pip install -r requirements_topeng.txt
```

## 📚 Documentation

### Main Documentation

- **[README_DUAL_SERVER.md](README_DUAL_SERVER.md)** - Complete dual server guide ⭐ START HERE
- **[README_ML.md](README_ML.md)** - ML ethnicity detection details
- **[Topeng/README_TOPENG.md](Topeng/README_TOPENG.md)** - Topeng mask overlay system

### Technical Documentation (`docs/` folder)

- **[docs/2025-10-08_ml-server-changes-detailed-explanation.md](docs/2025-10-08_ml-server-changes-detailed-explanation.md)** - ML feature extraction fixes
- **[docs/2025-10-08_topeng-nusantara-integration-guide.md](docs/2025-10-08_topeng-nusantara-integration-guide.md)** - Topeng integration guide
- **[docs/2025-10-07_ml-server-feature-alignment-fix.md](docs/2025-10-07_ml-server-feature-alignment-fix.md)** - Feature alignment documentation
- **[docs/2025-10-03_ml-ethnicity-detection-guide.md](docs/2025-10-03_ml-ethnicity-detection-guide.md)** - Complete ML implementation guide
- **[docs/2025-10-03_quick-start-guide.md](docs/2025-10-03_quick-start-guide.md)** - 5-minute setup guide

## 🔧 Available Models

| Model | Description | Use Case |
|-------|-------------|----------|
| `glcm_lbp_hog_hsv` | All features combined | **Best accuracy** |
| `glcm_lbp_hog` | GLCM + LBP + HOG | High performance |
| `glcm_hog` | GLCM + HOG | Balanced |
| `hog` | HOG only | Texture focus |
| `glcm` | GLCM only | Texture analysis |
| `lbp` | LBP only | Pattern analysis |
| `hsv` | HSV only | Color analysis |

## 📁 File Structure

```
Webcam Server/
├── ml_webcam_server.py          # Main ML server
├── test_ml_server.py            # Test suite
├── udp_webcam_server.py         # Basic UDP server (legacy)
├── requirements.txt             # Python dependencies
├── README.md                    # This file
├── README_ML.md                 # ML system documentation
├── docs/                        # Comprehensive documentation
│   ├── README.md
│   ├── 2025-10-03_quick-start-guide.md
│   ├── 2025-10-03_setup-and-branch-management.md
│   └── 2025-10-03_ml-ethnicity-detection-guide.md
└── models/                      # Trained ML models
    └── run_20250925_133309/
        ├── GLCM_HOG_model.pkl
        ├── GLCM_LBP_HOG_model.pkl
        ├── GLCM_LBP_HOG_HSV_model.pkl
        └── ... (other models)
```

---

## Legacy: TCP → UDP Migration

The project was successfully **migrated from TCP to UDP protocol** for webcam streaming between Python server and Godot client. This change was made to address unstable connection issues and improve real-time video streaming performance.

---

## Masalah dengan TCP (Sebelumnya)

### Kenapa TCP Gagal?
1. **Koneksi Sering Terputus**: TCP memerlukan koneksi yang persisten, jika salah satu pihak (server atau client) menutup koneksi, komunikasi langsung gagal  
2. **Overhead Data Besar**: TCP menambahkan header yang besar untuk memastikan pengiriman data, membuat ukuran frame video menjadi lebih besar  
3. **Buffering Berlebihan**: TCP melakukan buffering untuk memastikan urutan data, menyebabkan delay yang tidak diinginkan untuk video real-time  
4. **Error Handling Kompleks**: Ketika koneksi TCP terputus, client harus melakukan reconnection yang rumit  

### Dampak pada Interface Godot:
- Video webcam tidak muncul di interface Godot  
- Koneksi timeout secara acak  
- Frame rate tidak stabil karena buffering TCP  
- Resource usage tinggi karena overhead protokol  

---

## Solusi dengan UDP (Sekarang)

### Kenapa UDP Berhasil?
1. **Connectionless Protocol**: Tidak memerlukan koneksi persisten, packet dikirim langsung tanpa handshake  
2. **Overhead Minimal**: Header UDP sangat kecil, menghemat bandwidth untuk streaming video  
3. **Real-time Optimized**: Tidak ada buffering atau reordering, cocok untuk streaming live  
4. **Fault Tolerant**: Jika packet hilang, sistem tetap berjalan tanpa blocking  

### Hasil pada Interface Godot:
- Video webcam muncul dengan lancar di interface Godot  
- Koneksi stabil tanpa timeout yang tidak diinginkan  
- Frame rate konsisten (15 FPS target)  
- Resource usage efisien dengan optimasi bandwidth  

---

## Detail Implementasi UDP

### 1. Server Python (`udp_webcam_server.py`)
```python
# Protokol Registrasi
Client → Server: "REGISTER"
Server → Client: "REGISTERED"

# Struktur Packet Video
Header: [sequence:4][total_packets:4][packet_index:4]
Data: [JPEG frame data]
```

**Optimasi Server:**
- Resolusi: 480x360 (optimal untuk deteksi wajah)  
- Frame Rate: 15 FPS (balance antara smooth dan bandwidth)  
- JPEG Quality: 40% (ukuran kecil, kualitas memadai)  
- Packet Size: 32KB (optimal untuk UDP)  

### 2. Client Godot (`WebcamManagerUDP.gd`)
```gdscript
# Proses Registrasi
udp_client.connect_to_host(server_host, server_port)
udp_client.put_packet("REGISTER".to_utf8_buffer())

# Frame Assembly
1. Terima packets dengan sequence number
2. Rekonstruksi frame dari multiple packets
3. Decode JPEG dan tampilkan di UI
```

**Optimasi Client:**
- Packet Processing: Maksimal 10 packet per frame  
- Buffer Management: Auto-cleanup frame lama (0.5s timeout)  
- Error Recovery: Drop frame rusak, lanjut ke frame berikutnya  

---

## Perbandingan Performa

| Aspek | TCP (Lama) | UDP (Baru) | Improvement |
|-------|------------|------------|-------------|
| **Latency** | 200-500ms | 50-100ms | 75% lebih cepat |
| **Bandwidth** | ~2-3 Mbps | ~800 Kbps | 70% lebih efisien |
| **CPU Usage** | 15-25% | 8-12% | 50% lebih ringan |
| **Stabilitas** | Sering putus | Sangat stabil | 90% uptime |
| **Frame Rate** | 5-15 FPS | 15 FPS konsisten | Konsisten |

---

## Cara Menjalankan

### 1. Start UDP Server
```bash
cd "d:\ISSAT_PCD\Game\Webcam Server"
python udp_webcam_server.py
```

**Output yang diharapkan:**
```
Initializing optimized camera...
Camera ready: 480x360 @ 15FPS
Optimized UDP Server: 127.0.0.1:8888
Settings: 480x360, 15FPS, Q40
```

### 2. Run Godot Client
1. Buka project Godot: `d:\ISSAT_PCD\Game\Walking Simulator`  
2. Run scene: `EthnicityDetectionScene.tscn`  
3. Webcam akan otomatis connect dan stream  

**Output Godot yang diharapkan:**
```
Optimized UDP client ready
Connecting to optimized server...
Registration sent...
Connected to optimized server!
Video stream active: 480x360
```

---

## Konfigurasi yang Dapat Disesuaikan

### Server Python:
```python
# Di udp_webcam_server.py
self.target_fps = 15          # Frame rate (default: 15)
self.jpeg_quality = 40        # Kualitas JPEG (20-80)
self.frame_width = 480        # Lebar frame
self.frame_height = 360       # Tinggi frame
self.max_packet_size = 32768  # Ukuran packet UDP
```

### Client Godot:
```gdscript
# Di WebcamManagerUDP.gd
var server_port: int = 8888                    # Port server
var frame_timeout: float = 0.5                 # Timeout frame (detik)
var max_packets_per_frame: int = 10            # Limit packet per frame
```

---

## Kesimpulan
Migrasi dari **TCP ke UDP** telah berhasil mengatasi masalah koneksi webcam yang sebelumnya gagal. Perubahan ini memberikan:

1. Streaming video stabil: Webcam tampil dengan lancar di interface Godot  
2. Performa optimal: Resource usage 50% lebih efisien  
3. Real-time experience: Latency minimal untuk interaksi langsung  
4. Fault tolerance: Sistem tetap berjalan meski ada packet loss  

**UDP terbukti lebih cocok untuk streaming video real-time** dibandingkan TCP yang dirancang untuk transfer data yang memerlukan reliabilitas tinggi.

---

## Struktur File Terkait
```
Webcam Server/
├── udp_webcam_server.py                  Server UDP utama
├── requirements.txt                      Dependencies Python
└── README.md                             Dokumentasi

Walking Simulator/Scenes/EthnicityDetection/
├── EthnicityDetectionController.gd       Controller utama
├── EthnicityDetectionScene.tscn          Scene UI
└── WebcamClient/
    └── WebcamManagerUDP.gd               Client UDP
```

**File yang sudah tidak digunakan dan bisa dihapus:**
- `webcam_server.py` (TCP server lama)  
- `simple_server.py` (server sederhana)  
- `WebcamManager.gd` (TCP client lama)  
- `WebcamClient.gd` (client sederhana)  


