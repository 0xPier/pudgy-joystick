# Pudgy Party iOS Game

A pixel-art SpriteKit game with virtual controller support using Apple's GameController framework.

## Features

- **Virtual Controller**: On-screen controls using GCVirtualController
- **Physical Controller Support**: Automatic switching between virtual and physical controllers
- **Pixel-Perfect Movement**: Responsive movement designed for pixel art games
- **Debug Overlay**: Development tools for testing input and game state

## Virtual Controller Implementation

### Controls
- **Left Thumbstick**: Movement (8-directional with pixel-perfect feel)
- **Button A**: Jump (single impulse per press)
- **Button B**: Attack (spawn projectile)

### Settings
- `virtualControllerEnabled` (default: true) - Toggle virtual controller on/off
- `virtualControllerAlwaysVisible` (default: false) - Keep virtual controller visible even with physical controller
- `debugOverlayEnabled` (default: true in DEBUG builds) - Show debug information

## Testing Instructions

### Basic Virtual Controller Test

1. **Launch Test**
   - Build and run the app on iOS device or simulator
   - Virtual controller should appear automatically on screen
   - Verify thumbstick and two buttons (A, B) are visible

2. **Movement Test**
   - Use left thumbstick to move the red square player
   - Movement should feel responsive and pixel-perfect
   - Player should move in 8 directions (up, down, left, right, diagonals)
   - Releasing thumbstick should stop movement smoothly

3. **Jump Test (Button A)**
   - Press Button A while player is on ground
   - Player should jump with upward impulse
   - Multiple rapid presses should only trigger one jump per ground contact
   - No jump should occur when player is already in air

4. **Attack Test (Button B)**
   - Press Button B to spawn yellow projectile
   - Projectile should appear at player's right side
   - Projectile should move horizontally to the right
   - Projectile should disappear after 3 seconds or when off-screen
   - Multiple presses should spawn multiple projectiles

### Physical Controller Test

1. **Controller Connection**
   - Connect a physical MFi controller or use a PlayStation/Xbox controller
   - Virtual controller should automatically hide (unless `virtualControllerAlwaysVisible` is true)
   - Physical controller should control movement, jump, and attack
   - Same responsiveness as virtual controller

2. **Controller Disconnection**
   - Disconnect the physical controller
   - Virtual controller should automatically reappear (if `virtualControllerEnabled` is true)
   - Controls should continue working seamlessly

### Settings Test

1. **Disable Virtual Controller**
   - Set `Settings.shared.virtualControllerEnabled = false` in code
   - Relaunch app
   - Virtual controller should not appear
   - Connect physical controller - should work normally

2. **Always Visible Override**
   - Set `Settings.shared.virtualControllerAlwaysVisible = true` in code
   - Connect physical controller
   - Virtual controller should remain visible
   - Both controllers should work simultaneously

### Debug Features Test

1. **Debug Overlay** (DEBUG builds only)
   - Verify debug text appears in top-left corner
   - Should show: input values, pixel movement, velocity, button states, ground detection
   - Values should update in real-time during gameplay

## QA Checklist

### ✅ Core Functionality
- [ ] Virtual controller appears on app launch
- [ ] Left thumbstick moves player smoothly
- [ ] Movement feels pixel-perfect and responsive
- [ ] Button A triggers jump (one impulse per press)
- [ ] Button B spawns attack projectile
- [ ] Player can only jump when on ground
- [ ] Projectiles move correctly and disappear appropriately

### ✅ Physical Controller Integration
- [ ] Virtual controller hides when physical controller connects
- [ ] Virtual controller reappears when physical controller disconnects
- [ ] Physical controller provides same functionality as virtual controller
- [ ] No input lag or conflicts between controller types

### ✅ Settings & Configuration
- [ ] `virtualControllerEnabled = false` prevents virtual controller from appearing
- [ ] `virtualControllerAlwaysVisible = true` keeps virtual controller visible with physical controller
- [ ] Settings persist between app launches
- [ ] Debug overlay can be toggled on/off

### ✅ Edge Cases
- [ ] App handles multiple physical controllers gracefully
- [ ] No crashes when rapidly connecting/disconnecting controllers
- [ ] Performance remains smooth during intense input
- [ ] Memory usage stays stable during extended play

### ✅ UX & Polish
- [ ] Controls feel responsive and intuitive
- [ ] No visual glitches with controller UI
- [ ] Smooth transitions between virtual/physical controller modes
- [ ] Debug overlay doesn't interfere with gameplay (when enabled)

## Technical Architecture

```
GameViewController
├── VirtualControllerManager (manages GCVirtualController lifecycle)
├── InputState (thread-safe input storage)
└── GameScene (reads InputState, applies game logic)
```

### Key Components

- **VirtualControllerManager**: Handles GCVirtualController setup, physical controller detection
- **InputState**: Thread-safe actor storing current input state with edge detection
- **Settings**: User preferences for controller behavior
- **GameScene**: Main game loop that reads input and applies movement/actions

## Development Notes

- Target: iOS 15+, Swift 5+, Xcode 15+
- Engine: SpriteKit with custom pixel-perfect movement system
- Thread Safety: Uses `@MainActor` for UI-related state management
- Performance: Optimized for 60 FPS gameplay with minimal input latency

## Commit Message

```
feat(input): add GCVirtualController virtual input for Pudgy Party

- Implement virtual controller with left thumbstick + A/B buttons
- Add automatic physical controller detection and switching
- Create pixel-perfect movement system for pixel art aesthetic
- Add debug overlay for development testing
- Support user settings for controller behavior customization
- Ensure thread-safe input handling with edge detection
