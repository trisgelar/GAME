# NPC Interaction System Guide

## Overview
The NPC interaction system provides a user-friendly way to interact with NPCs in the Indonesian Cultural Heritage Exhibition Walking Simulator. This guide explains how the system works and how to use it effectively.

## 🎮 How NPC Interaction Works

### Visual Feedback System

#### 1. **Interaction Prompts**
When you approach an NPC, you'll see a clear visual prompt on screen:
- **Location**: Center of the screen, below the crosshair
- **Text**: `[E] Talk to [NPC Name]`
- **Color**: Yellow when available, Green when pressed, White normally
- **Font**: Large, easy-to-read text with shadow for visibility

#### 2. **NPC Visual Feedback**
- **Range Indicator**: NPCs glow slightly yellow when you're in interaction range
- **Interaction Feedback**: NPCs flash green briefly when you interact with them
- **Distance Check**: Interaction only works when you're within 3 meters of the NPC

### Step-by-Step Interaction Process

#### Step 1: Approach the NPC
1. **Walk towards any NPC** in the scene
2. **Look at the NPC** (the interaction system uses a raycast from your camera)
3. **Get within 3 meters** of the NPC

#### Step 2: See the Interaction Prompt
1. **Yellow prompt appears** on screen: `[E] Talk to [NPC Name]`
2. **NPC glows slightly** to indicate they're interactable
3. **Console shows**: "Near interactable: [NPC Name] - [E] Talk to [NPC Name]"

#### Step 3: Press E to Interact
1. **Press the E key** to start the conversation
2. **Prompt flashes green** briefly for feedback
3. **Dialogue UI appears** with the NPC's greeting
4. **Console shows**: "Interacted with: [NPC Name]"

#### Step 4: Choose Dialogue Options
1. **Read the NPC's message** in the dialogue panel
2. **Click on dialogue options** to continue the conversation
3. **Learn cultural information** as you progress through dialogue
4. **Press the close button** or choose "Goodbye" to end conversation

## 🎯 NPC Locations by Scene

### PasarScene (Indonesia Barat)
- **MarketGuide** (center of market)
- **FoodVendor** (near food stall 1)
- **CraftVendor** (near craft stall 2)
- **Historian** (near historical area)

### TamboraScene (Indonesia Tengah)
- **Historian** (center, near mountain)
- **Geologist** (near mountain path)
- **LocalGuide** (near historical markers)

### PapuaScene (Indonesia Timur)
- **CulturalGuide** (center of megalithic site)
- **Archaeologist** (near stone circle)
- **TribalElder** (near traditional area)
- **Artisan** (near cultural artifacts)

## 🔧 Technical Implementation

### Interaction Range
- **Default Range**: 3 meters from NPC
- **Detection Method**: Raycast from player camera
- **Visual Feedback**: Area3D collision detection
- **State Management**: Automatic enter/exit detection

### Visual Prompts
- **Position**: Screen center, below crosshair
- **Styling**: Large white text with black shadow
- **Colors**: 
  - Yellow: Available for interaction
  - Green: Interaction pressed
  - White: Normal state
- **Animation**: Smooth color transitions

### NPC States
- **Idle**: Normal state, waiting for player
- **Interacting**: In conversation with player
- **Visual Feedback**: Glow effects and color changes

## 🎮 Controls Summary

### Primary Controls
- **Movement**: WASD keys
- **Look Around**: Mouse movement
- **Interact with NPC**: E key (when prompt is visible)
- **Jump**: Spacebar
- **Sprint**: Shift key
- **Inventory**: I key

### Dialogue Controls
- **Select Option**: Click on dialogue buttons
- **Close Dialogue**: Click close button or choose "Goodbye"
- **Mouse Capture**: Escape key to toggle

## 🐛 Troubleshooting

### Common Issues

#### "No interaction prompt appears"
- **Check**: Are you looking directly at the NPC?
- **Check**: Are you within 3 meters of the NPC?
- **Check**: Is the NPC properly set up in the scene?

#### "Can't interact with NPC"
- **Check**: Is the E key working for other interactions?
- **Check**: Are you pressing E when the prompt is yellow?
- **Check**: Is the dialogue UI already open?

#### "NPC doesn't respond"
- **Check**: Console for error messages
- **Check**: NPC dialogue data is properly loaded
- **Check**: Event Bus is working correctly

### Debug Information
The system provides extensive debug output:
- Player entering/exiting interaction range
- Interaction attempts and results
- NPC state changes
- Event Bus communication

## 🎨 Visual Design

### Prompt Design
- **Font Size**: 24px for good readability
- **Color Scheme**: High contrast for visibility
- **Position**: Centered, non-intrusive
- **Animation**: Smooth transitions for feedback

### NPC Visual Feedback
- **Range Indicator**: Subtle yellow glow
- **Interaction Feedback**: Brief green flash
- **State Changes**: Color modulation for different states

## 🚀 Future Enhancements

### Planned Improvements
1. **Audio Cues**: Sound effects for interaction
2. **Particle Effects**: More visual feedback
3. **Hover Effects**: Enhanced NPC highlighting
4. **Accessibility**: Support for different input methods
5. **Localization**: Support for multiple languages

### Customization Options
- Adjustable interaction range
- Customizable prompt styling
- Different interaction types
- Advanced NPC behaviors

## 📝 Best Practices

### For Players
1. **Look directly at NPCs** for best detection
2. **Wait for the yellow prompt** before pressing E
3. **Read dialogue carefully** to learn cultural information
4. **Explore all dialogue options** for complete experience

### For Developers
1. **Test interaction ranges** thoroughly
2. **Provide clear visual feedback**
3. **Use consistent prompt styling**
4. **Include debug information**
5. **Handle edge cases** gracefully

## 🎯 Quick Reference

### Interaction Flow
```
Approach NPC → See Yellow Prompt → Press E → Choose Dialogue → Learn Culture
```

### Key Controls
- **E**: Interact with NPC
- **Mouse**: Look at NPC
- **WASD**: Move to NPC
- **Click**: Select dialogue options

### Visual Indicators
- **Yellow Prompt**: Ready to interact
- **Green Flash**: Interaction successful
- **NPC Glow**: In interaction range
- **Dialogue Panel**: Conversation active

This system provides an intuitive and engaging way to interact with NPCs and learn about Indonesian cultural heritage!
