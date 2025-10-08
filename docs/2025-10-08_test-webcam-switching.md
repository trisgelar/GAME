# Webcam Switching Test Procedure

## Current Issue
- Only one server works at a time
- Second scene shows "UDP webcam terhubung" but FPS: 0.0
- Camera resource not properly released between scenes

## Test Steps

### Step 1: Restart Both Servers
1. **Stop all servers:**
   ```bash
   taskkill /F /IM python.exe
   ```

2. **Start both servers fresh:**
   ```bash
   start_both_servers.bat
   ```

### Step 2: Test Topeng Scene First
1. **Open Topeng scene in Godot**
2. **Check console output for:**
   ```
   ✅ Created WebcamManagerUDP instance and added to scene tree
   ✅ Topeng server port set to: 8889
   ⏳ Waiting 1.0 seconds for previous camera to be released...
   🔄 Attempting to connect to Topeng server (port 8889)...
   🔄 Connecting to webcam server on port 8889...
   ✅ UDP connection established to 127.0.0.1:8889
   ```

3. **Check Topeng server console for:**
   ```
   ✅ Client: ('127.0.0.1', [port]) (Total: 1)
   ▶️  Client(s) connected (1) - camera resumed
   ```

4. **Expected result:** Webcam feed with mask overlay

### Step 3: Test Ethnicity Scene
1. **Exit Topeng scene to menu**
2. **Check console output for:**
   ```
   🔄 Disconnecting from webcam server...
   📤 Sent RELEASE_CAMERA command
   📤 Sent UNREGISTER command
   ```

3. **Check Topeng server console for:**
   ```
   📹 Camera release requested by ('127.0.0.1', [port])
   ✅ Camera released
   ✅ Camera reinitialized
   ❌ Client left: ('127.0.0.1', [port])
   ⏸️  No clients connected - camera paused
   ```

4. **Open Ethnicity scene**
5. **Check console output for:**
   ```
   ✅ Created WebcamManagerUDP instance and added to scene tree
   ✅ ML server port set to: 8888
   ⏳ Waiting 1.0 seconds for previous camera to be released...
   🔄 Attempting to connect to ML server (port 8888)...
   🔄 Connecting to webcam server on port 8888...
   ✅ UDP connection established to 127.0.0.1:8888
   ```

6. **Check ML server console for:**
   ```
   ✅ Client: ('127.0.0.1', [port]) (Total: 1)
   ▶️  Client(s) connected (1) - camera resumed
   ```

7. **Expected result:** Webcam feed with ML detection

### Step 4: Test Multiple Switches
1. **Switch back to Topeng**
2. **Switch back to Ethnicity**
3. **Repeat several times**
4. **Each switch should work without FPS: 0.0**

## Debugging Information

### If FPS: 0.0 persists:
1. **Check server logs** for camera release/reinit messages
2. **Check Godot console** for connection success messages
3. **Verify both servers are running** on correct ports
4. **Try restarting servers** if camera gets stuck

### Expected Server Logs:
**Topeng Server (8889):**
```
✅ Client: ('127.0.0.1', 58693) (Total: 1)
▶️  Client(s) connected (1) - camera resumed
📹 Camera release requested by ('127.0.0.1', 58693)
✅ Camera released
✅ Camera reinitialized
❌ Client left: ('127.0.0.1', 58693)
⏸️  No clients connected - camera paused
```

**ML Server (8888):**
```
✅ Client: ('127.0.0.1', 58694) (Total: 1)
▶️  Client(s) connected (1) - camera resumed
📹 Camera release requested by ('127.0.0.1', 58694)
✅ Camera released
✅ Camera reinitialized
❌ Client left: ('127.0.0.1', 58694)
⏸️  No clients connected - camera paused
```

## Troubleshooting

### If camera still gets stuck:
1. **Restart both servers** completely
2. **Check for other applications** using the camera
3. **Verify camera permissions** in Windows
4. **Try different camera index** if available

### If connection fails:
1. **Check firewall settings**
2. **Verify ports 8888 and 8889** are not blocked
3. **Check server startup logs** for errors
4. **Verify Python dependencies** are installed correctly
