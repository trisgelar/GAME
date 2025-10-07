# Godot 4 Shader Implementation Guide

**Date**: 2025-09-17  
**Status**: ✅ Complete  
**Author**: AI Assistant  

## 🎯 Comprehensive Godot Shader Guide

This document provides detailed guidance on implementing shaders in Godot 4, covering everything from basic concepts to advanced techniques, with specific focus on the Indonesia 3D Map project implementation.

## 🧠 Shader Fundamentals

### **What Are Shaders?**
Shaders are programs that run on the GPU to control how objects are rendered. They operate on vertices (shape) and fragments (pixels) to create visual effects.

### **Godot Shader Types**
```glsl
shader_type spatial;    // 3D objects (our focus)
shader_type canvas_item; // 2D UI elements
shader_type particles;   // Particle systems
shader_type fog;        // Volumetric fog
```

### **Shader Pipeline**
```
3D Model → Vertex Shader → Rasterization → Fragment Shader → Screen
```

## 🌊 Ocean Wave Shader Deep Dive

### **Complete Implementation**
```glsl
shader_type spatial;
render_mode depth_draw_opaque, diffuse_burley, specular_schlick_ggx, cull_back;

// === UNIFORMS (Parameters from GDScript) ===
uniform float wave_speed: hint_range(0.1, 3.0) = 1.0;
uniform float wave_height: hint_range(0.0, 2.0) = 0.3;
uniform float wave_frequency: hint_range(0.1, 5.0) = 1.0;
uniform vec4 shallow_color: source_color = vec4(0.4, 0.8, 1.0, 0.8);
uniform vec4 deep_color: source_color = vec4(0.0, 0.2, 0.6, 1.0);
uniform vec4 foam_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float foam_threshold: hint_range(0.0, 1.0) = 0.6;

// === VARYING (Data passed from vertex to fragment) ===
varying float wave_height_var;
varying vec3 world_position;

// === VERTEX SHADER (Runs per vertex) ===
void vertex() {
    world_position = VERTEX;
    
    // Create multiple wave layers for realism
    vec2 wave_uv = VERTEX.xz * 0.1 * wave_frequency;
    float time_factor = TIME * wave_speed;
    
    // Primary wave (main movement)
    float wave1 = sin(wave_uv.x * 2.0 + time_factor) * wave_height;
    
    // Secondary wave (cross-pattern for complexity)
    float wave2 = cos(wave_uv.y * 1.5 + time_factor * 0.8) * wave_height * 0.7;
    
    // Tertiary wave (fine detail)
    float wave3 = sin((wave_uv.x + wave_uv.y) * 0.8 + time_factor * 1.3) * wave_height * 0.4;
    
    // Combine waves
    float total_wave = wave1 + wave2 + wave3;
    VERTEX.y += total_wave;
    
    // Pass wave height to fragment shader for foam calculation
    wave_height_var = total_wave;
    
    // Calculate surface normal for lighting
    float offset = 0.1;
    float wave_x = sin((wave_uv.x + offset) * 2.0 + time_factor) * wave_height;
    float wave_z = sin(wave_uv.y * 2.0 + time_factor) * wave_height;
    vec3 wave_normal = normalize(vec3(wave_x - total_wave, 1.0, wave_z - total_wave));
    NORMAL = wave_normal;
}

// === FRAGMENT SHADER (Runs per pixel) ===
void fragment() {
    // Simple depth-based color mixing
    float depth_factor = clamp(world_position.y * 0.1, 0.0, 1.0);
    vec3 water_color = mix(deep_color.rgb, shallow_color.rgb, depth_factor);
    
    // Calculate foam based on wave height
    float foam_factor = smoothstep(foam_threshold - 0.1, foam_threshold + 0.1, abs(wave_height_var));
    
    // Apply foam to water color
    vec3 final_color = mix(water_color, foam_color.rgb, foam_factor);
    
    // Output final material properties
    ALBEDO = final_color;
    ROUGHNESS = 0.1;    // Smooth water surface
    METALLIC = 0.0;     // Water is not metallic
    ALPHA = shallow_color.a;
}
```

### **Wave Mathematics Explained**

#### **Sine Wave Basics**
```glsl
// Basic sine wave: sin(position * frequency + time * speed) * amplitude
float wave = sin(VERTEX.x * 2.0 + TIME * 1.0) * 0.5;

// Components:
// VERTEX.x * 2.0    → Wave frequency (higher = more waves)
// TIME * 1.0        → Wave speed (higher = faster movement)  
// * 0.5             → Wave amplitude (higher = taller waves)
```

#### **Multi-layered Waves**
```glsl
// Layer 1: Primary movement (X-direction)
float wave1 = sin(uv.x * 2.0 + time) * height;

// Layer 2: Cross-pattern (Y-direction, different frequency)
float wave2 = cos(uv.y * 1.5 + time * 0.8) * height * 0.7;

// Layer 3: Diagonal complexity
float wave3 = sin((uv.x + uv.y) * 0.8 + time * 1.3) * height * 0.4;

// Result: Natural-looking ocean surface
float total = wave1 + wave2 + wave3;
```

## ✨ Interactive Glow Shader Deep Dive

### **Complete Implementation**
```glsl
shader_type spatial;
render_mode depth_draw_opaque, diffuse_burley, specular_schlick_ggx;

// === BASE MATERIAL ===
uniform vec4 base_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D base_texture: source_color;
uniform float roughness_value: hint_range(0.0, 1.0) = 0.3;
uniform float metallic_value: hint_range(0.0, 1.0) = 0.1;

// === GLOW EFFECTS ===
uniform vec4 glow_color: source_color = vec4(1.0, 0.5, 0.0, 1.0);
uniform float glow_intensity: hint_range(0.0, 5.0) = 1.0;
uniform float pulse_speed: hint_range(0.1, 10.0) = 2.0;
uniform bool enable_pulse: hint_default = true;

// === INTERACTION STATES ===
uniform float hover_intensity: hint_range(0.0, 3.0) = 1.5;
uniform float selection_intensity: hint_range(0.0, 5.0) = 2.0;
uniform bool is_hovered: hint_default = false;
uniform bool is_selected: hint_default = false;

// === RIM LIGHTING ===
uniform float rim_power: hint_range(0.1, 10.0) = 2.0;
uniform vec4 rim_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);

varying vec3 world_normal;
varying vec3 view_direction;

void vertex() {
    world_normal = NORMAL;
    // Calculate view direction for rim lighting
    view_direction = (INV_VIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz - VERTEX;
}

void fragment() {
    // Base texture and color
    vec4 tex_color = texture(base_texture, UV);
    vec3 base_albedo = base_color.rgb * tex_color.rgb;
    
    // Pulsing animation
    float pulse = enable_pulse ? sin(TIME * pulse_speed) * 0.3 + 0.7 : 1.0;
    
    // Interaction intensity
    float interaction_factor = 1.0;
    if (is_selected) {
        interaction_factor = selection_intensity;
    } else if (is_hovered) {
        interaction_factor = hover_intensity;
    }
    
    // Rim lighting calculation
    float rim_factor = 1.0 - abs(dot(normalize(view_direction), normalize(world_normal)));
    rim_factor = pow(rim_factor, rim_power);
    
    // Combine all glow effects
    float total_glow = glow_intensity * pulse * interaction_factor;
    vec3 glow_emission = glow_color.rgb * total_glow;
    vec3 rim_emission = rim_color.rgb * rim_factor * total_glow * 0.5;
    
    // Final output
    ALBEDO = base_albedo;
    EMISSION = glow_emission + rim_emission;
    ROUGHNESS = roughness_value;
    METALLIC = metallic_value;
}
```

### **Rim Lighting Mathematics**
```glsl
// Rim lighting creates glow around object edges
float rim_factor = 1.0 - abs(dot(view_direction, surface_normal));

// How it works:
// - When viewing surface straight on: dot product ≈ 1, rim_factor ≈ 0 (no glow)
// - When viewing surface at angle: dot product ≈ 0, rim_factor ≈ 1 (full glow)
// - pow(rim_factor, rim_power) controls glow falloff
```

## 🏔️ Terrain Blend Shader Theory

### **Height-Based Texturing**
```glsl
// Concept: Different textures at different elevations
float height = VERTEX.y / height_scale;  // Normalize height 0-1

// Texture weights based on height
float sand_weight = smoothstep(0.0, 0.2, 1.0 - height);  // Low areas
float grass_weight = smoothstep(0.1, 0.6, height);       // Medium areas  
float rock_weight = smoothstep(0.5, 1.0, height);        // High areas

// Blend textures
vec3 final_color = sand_color * sand_weight + 
                  grass_color * grass_weight + 
                  rock_color * rock_weight;
```

### **Slope-Based Texturing**
```glsl
// Concept: Steep slopes get rocky textures
float slope = 1.0 - abs(dot(NORMAL, vec3(0.0, 1.0, 0.0)));

// Apply rock texture to steep areas
float slope_rock = smoothstep(slope_threshold, slope_threshold + 0.2, slope);
rock_weight = max(rock_weight, slope_rock);
```

## 🎮 GDScript Integration

### **Shader Parameter Management**
```gdscript
# Setting shader parameters from GDScript
var material = mesh_instance.material_override as ShaderMaterial

# Float parameters
material.set_shader_parameter("wave_speed", 2.0)

# Color parameters  
material.set_shader_parameter("glow_color", Color.RED)

# Boolean parameters
material.set_shader_parameter("enable_pulse", true)

# Texture parameters
var texture = load("res://texture.png")
material.set_shader_parameter("base_texture", texture)
```

### **Dynamic Shader Updates**
```gdscript
# Update shader parameters in real-time
func _process(delta):
    var current_time = Time.get_time_dict_from_system()
    var time_factor = current_time.hour / 24.0
    
    # Change ocean color based on time of day
    var day_color = Color(0.4, 0.8, 1.0)
    var night_color = Color(0.0, 0.1, 0.3)
    var ocean_color = day_color.lerp(night_color, time_factor)
    
    ocean_material.set_shader_parameter("shallow_color", ocean_color)
```

### **Interaction State Management**
```gdscript
# Update shader based on user interaction
func _on_placeholder_mouse_entered(placeholder: Node3D):
    var material = placeholder.material_override as ShaderMaterial
    material.set_shader_parameter("is_hovered", true)
    material.set_shader_parameter("hover_intensity", 2.0)

func _on_placeholder_mouse_exited(placeholder: Node3D):
    var material = placeholder.material_override as ShaderMaterial  
    material.set_shader_parameter("is_hovered", false)
```

## 🔧 Godot 4 Shader Changes

### **Property Differences from Godot 3.x**

#### **Material Properties**
```gdscript
// Godot 3.x (REMOVED)
material.specular = 0.5        // ❌ No longer exists
material.flags_transparent = true  // ❌ Changed

// Godot 4.x (CURRENT)
material.roughness = 0.6       // ✅ Controls specular through PBR
material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA  // ✅ New system
```

#### **Shader Hints**
```glsl
// Godot 3.x
uniform float value : hint_range(0.0, 1.0);  // ❌ Old syntax

// Godot 4.x  
uniform float value: hint_range(0.0, 1.0);   // ✅ Colon instead of space
```

#### **Built-in Variables**
```glsl
// Some built-ins changed names or behavior
SCREEN_TEXTURE  // May have different access patterns
DEPTH_TEXTURE   // New depth buffer access
TIME           // Still available, same usage
```

### **Migration Checklist**
- [ ] Replace `specular` with `roughness` control
- [ ] Update transparency mode syntax
- [ ] Fix uniform hint syntax (colon not space)
- [ ] Test depth texture access patterns
- [ ] Verify built-in variable availability

## 🎨 Visual Effect Techniques

### **Wave Animation Techniques**

#### **Basic Sine Waves**
```glsl
// Simple up-down motion
VERTEX.y += sin(VERTEX.x + TIME) * amplitude;
```

#### **Traveling Waves**
```glsl
// Waves that move across surface
VERTEX.y += sin(VERTEX.x * frequency + TIME * speed) * amplitude;
```

#### **Realistic Ocean Waves**
```glsl
// Multiple overlapping waves with different properties
float wave1 = sin(uv.x * 2.0 + time) * height;           // Primary
float wave2 = cos(uv.y * 1.5 + time * 0.8) * height * 0.7;  // Secondary
float wave3 = sin((uv.x + uv.y) * 0.8 + time * 1.3) * height * 0.4;  // Detail
VERTEX.y += wave1 + wave2 + wave3;
```

### **Glow and Emission Techniques**

#### **Static Glow**
```glsl
EMISSION = glow_color.rgb * glow_intensity;
```

#### **Pulsing Glow**
```glsl
float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;  // 0.0 to 1.0
EMISSION = glow_color.rgb * glow_intensity * pulse;
```

#### **Rim Lighting Glow**
```glsl
// Glow around edges when viewed at angle
float rim = 1.0 - dot(view_direction, surface_normal);
rim = pow(rim, rim_power);  // Control falloff
EMISSION += rim_color.rgb * rim * rim_intensity;
```

### **Texture Blending Techniques**

#### **Height-Based Blending**
```glsl
// Different textures at different elevations
float height_factor = VERTEX.y / max_height;
vec3 low_texture = texture(sand_tex, UV).rgb;
vec3 high_texture = texture(rock_tex, UV).rgb;
vec3 blended = mix(low_texture, high_texture, height_factor);
```

#### **Smooth Transitions**
```glsl
// Avoid hard edges with smoothstep
float sand_blend = smoothstep(0.0, 0.2, height);      // Fade in from 0.0 to 0.2
float grass_blend = smoothstep(0.1, 0.6, height);     // Fade in from 0.1 to 0.6
float rock_blend = smoothstep(0.5, 1.0, height);      // Fade in from 0.5 to 1.0
```

#### **Multi-texture Blending**
```glsl
// Combine multiple textures with normalized weights
float total_weight = sand_weight + grass_weight + rock_weight;
sand_weight /= total_weight;
grass_weight /= total_weight;  
rock_weight /= total_weight;

vec3 final_color = sand_color * sand_weight + 
                  grass_color * grass_weight + 
                  rock_color * rock_weight;
```

## 🔄 Shader Parameter Control

### **Parameter Types and Usage**

#### **Float Parameters**
```gdscript
# GDScript
material.set_shader_parameter("wave_speed", 2.0)

# Shader
uniform float wave_speed: hint_range(0.1, 5.0) = 1.0;
```

#### **Color Parameters**
```gdscript
# GDScript
material.set_shader_parameter("glow_color", Color.RED)

# Shader
uniform vec4 glow_color: source_color = vec4(1.0, 0.0, 0.0, 1.0);
```

#### **Texture Parameters**
```gdscript
# GDScript
var texture = load("res://texture.png")
material.set_shader_parameter("base_texture", texture)

# Shader
uniform sampler2D base_texture: source_color, hint_default_white;
```

#### **Boolean Parameters**
```gdscript
# GDScript
material.set_shader_parameter("enable_effect", true)

# Shader
uniform bool enable_effect: hint_default = false;
```

### **Real-time Parameter Animation**
```gdscript
# Animate shader parameters over time
func _process(delta):
    var wave_intensity = sin(Time.get_time_from_start() * 0.5) * 0.5 + 1.0
    ocean_material.set_shader_parameter("wave_height", wave_intensity)
    
    var glow_pulse = cos(Time.get_time_from_start() * 2.0) * 0.3 + 0.7
    placeholder_material.set_shader_parameter("glow_intensity", glow_pulse)
```

## 🏗️ Shader System Architecture

### **Component Relationships**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Scene Controller │    │ Shader Applier  │    │ Shader Manager  │
│                 │───▶│                 │───▶│                 │
│ - User input    │    │ - Node discovery│    │ - Resource mgmt │
│ - Scene lifecycle│    │ - Config mgmt   │    │ - Caching       │
│ - State mgmt    │    │ - Scene-specific│    │ - Material creation│
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   UI Elements   │    │   3D Objects    │    │  Shader Files   │
│                 │    │                 │    │                 │
│ - Buttons       │    │ - Sea plane     │    │ - Ocean waves   │
│ - Labels        │    │ - Placeholders  │    │ - Glow effects  │
│ - Panels        │    │ - Island mesh   │    │ - Terrain blend │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### **Data Flow Patterns**
```gdscript
# 1. Configuration-driven setup
config.ocean_settings → shader_applier.apply_ocean_shader() → shader_manager.create_material()

# 2. User interaction updates
user_hover_event → controller.on_hover() → applier.update_interaction() → manager.update_parameters()

# 3. Runtime parameter changes
time_update → controller._process() → applier.animate_effects() → manager.set_parameters()
```

## 🧪 Testing and Debugging Shaders

### **Shader Debugging Techniques**

#### **Visual Debugging**
```glsl
// Output intermediate values as colors for debugging
void fragment() {
    // Debug wave height as red intensity
    ALBEDO = vec3(abs(wave_height_var), 0.0, 0.0);
    
    // Debug UV coordinates as red/green
    ALBEDO = vec3(UV.x, UV.y, 0.0);
    
    // Debug normals as RGB
    ALBEDO = NORMAL * 0.5 + 0.5;
}
```

#### **Parameter Validation**
```gdscript
# Validate parameter ranges in GDScript
func set_wave_speed(speed: float):
    speed = clamp(speed, 0.1, 5.0)  # Ensure valid range
    material.set_shader_parameter("wave_speed", speed)
    GameLogger.info("Wave speed set to: " + str(speed))
```

#### **Performance Monitoring**
```gdscript
# Monitor shader performance
func _ready():
    var start_time = Time.get_time_from_start()
    apply_all_shaders()
    var end_time = Time.get_time_from_start()
    GameLogger.info("Shader setup took: " + str(end_time - start_time) + "s")
```

### **Common Shader Bugs**

#### **Division by Zero**
```glsl
// ❌ DANGEROUS
float result = value / other_value;  // other_value might be 0

// ✅ SAFE
float result = value / max(other_value, 0.001);  // Prevent division by zero
```

#### **UV Coordinate Issues**
```glsl
// ❌ PROBLEM: UV outside 0-1 range
vec3 color = texture(tex, UV * 10.0).rgb;  // May sample outside texture

// ✅ SOLUTION: Wrap or clamp UV coordinates
vec3 color = texture(tex, fract(UV * 10.0)).rgb;  // Wrap with fract()
```

#### **Performance Issues**
```glsl
// ❌ EXPENSIVE: Complex calculations in fragment shader
void fragment() {
    for(int i = 0; i < 100; i++) {  // Avoid loops in fragment shader
        // expensive calculation
    }
}

// ✅ OPTIMIZED: Move calculations to vertex shader when possible
void vertex() {
    // Do heavy calculations once per vertex
    COLOR = expensive_calculation();
}

void fragment() {
    // Use pre-calculated values
    ALBEDO = COLOR.rgb;
}
```

## 📊 Performance Optimization

### **Shader Optimization Strategies**

#### **Vertex vs Fragment Shader Usage**
```glsl
// ✅ VERTEX SHADER: Use for calculations that vary per vertex
void vertex() {
    // Wave calculations (once per vertex)
    float wave = sin(VERTEX.x + TIME);
    VERTEX.y += wave;
    COLOR.r = wave;  // Pass to fragment
}

// ✅ FRAGMENT SHADER: Use for calculations that vary per pixel
void fragment() {
    // Texture sampling (once per pixel)
    vec3 tex_color = texture(base_texture, UV).rgb;
    ALBEDO = tex_color * COLOR.r;  // Use vertex data
}
```

#### **Uniform vs Varying Usage**
```glsl
// ✅ UNIFORM: Values that are the same for entire object
uniform float global_time;
uniform vec4 global_color;

// ✅ VARYING: Values that change across the surface
varying float vertex_height;
varying vec3 world_position;
```

#### **Texture Optimization**
```glsl
// ✅ EFFICIENT: Appropriate texture filtering
uniform sampler2D base_texture: source_color, filter_linear;

// ✅ EFFICIENT: Texture atlasing
uniform sampler2D texture_atlas: source_color;
vec2 sand_uv = UV * 0.25;  // Use quarter of atlas for sand
vec2 grass_uv = UV * 0.25 + vec2(0.25, 0.0);  // Next quarter for grass
```

## 🔮 Advanced Shader Techniques

### **Procedural Generation**
```glsl
// Generate patterns without textures
float noise = fract(sin(dot(UV, vec2(12.9898, 78.233))) * 43758.5453);
float pattern = step(0.5, noise);  // Random black/white pattern
```

### **Animation Techniques**
```glsl
// Scrolling textures
vec2 scrolling_uv = UV + vec2(TIME * scroll_speed, 0.0);
vec3 color = texture(scrolling_texture, scrolling_uv).rgb;

// Rotating effects
float angle = TIME * rotation_speed;
vec2 rotated_uv = vec2(
    UV.x * cos(angle) - UV.y * sin(angle),
    UV.x * sin(angle) + UV.y * cos(angle)
);
```

### **Lighting Integration**
```glsl
// Custom lighting calculations
void light() {
    // Custom light response
    float NdotL = dot(NORMAL, LIGHT);
    DIFFUSE_LIGHT += NdotL * LIGHT_COLOR * ATTENUATION;
}
```

## 📚 Learning Resources

### **Godot Shader Documentation**
- Official Godot 4 Shader Documentation
- GDScript Shader Integration Guide
- Godot Spatial Shader Reference

### **Shader Mathematics**
- Vector mathematics for 3D graphics
- Trigonometry for wave animations
- Linear algebra for transformations

### **Performance Optimization**
- GPU architecture basics
- Shader profiling techniques
- Optimization best practices

---

**Conclusion**: The shader system provides a powerful, flexible foundation for creating stunning visual effects while maintaining excellent code architecture. The SOLID principles ensure the system remains maintainable and extensible as visual requirements evolve.
