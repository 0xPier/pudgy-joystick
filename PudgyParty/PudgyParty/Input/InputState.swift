import Foundation

@MainActor
class InputState: ObservableObject {
    static let shared = InputState()
    
    // Movement input (normalized -1.0 to 1.0)
    @Published var dx: Float = 0.0
    @Published var dy: Float = 0.0
    
    // Button states
    @Published var jumpPressed: Bool = false
    @Published var attackPressed: Bool = false
    
    // Previous frame button states for edge detection
    private var previousJumpPressed: Bool = false
    private var previousAttackPressed: Bool = false
    
    private init() {}
    
    // MARK: - Input Updates
    
    func updateMovement(dx: Float, dy: Float) {
        self.dx = dx
        self.dy = dy
    }
    
    func updateButtons(jump: Bool, attack: Bool) {
        self.jumpPressed = jump
        self.attackPressed = attack
    }
    
    // MARK: - Edge Detection
    
    func isJumpJustPressed() -> Bool {
        let result = jumpPressed && !previousJumpPressed
        return result
    }
    
    func isAttackJustPressed() -> Bool {
        let result = attackPressed && !previousAttackPressed
        return result
    }
    
    func updatePreviousStates() {
        previousJumpPressed = jumpPressed
        previousAttackPressed = attackPressed
    }
    
    // MARK: - Utility
    
    func reset() {
        dx = 0.0
        dy = 0.0
        jumpPressed = false
        attackPressed = false
        previousJumpPressed = false
        previousAttackPressed = false
    }
    
    // For pixel-perfect movement, convert to discrete directions
    func getPixelPerfectMovement() -> (x: Int, y: Int) {
        let threshold: Float = 0.3
        
        let x: Int
        if dx > threshold {
            x = 1
        } else if dx < -threshold {
            x = -1
        } else {
            x = 0
        }
        
        let y: Int
        if dy > threshold {
            y = 1
        } else if dy < -threshold {
            y = -1
        } else {
            y = 0
        }
        
        return (x: x, y: y)
    }
}
