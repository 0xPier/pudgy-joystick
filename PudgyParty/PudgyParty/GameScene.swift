import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private let inputState = InputState.shared
    private let settings = Settings.shared
    
    // Player node
    private var player: SKSpriteNode!
    
    // Movement properties for pixel-perfect feel
    private let pixelSize: CGFloat = 4.0  // Size of each "pixel" in points
    private let moveSpeed: CGFloat = 120.0  // Points per second
    private let jumpForce: CGFloat = 400.0
    
    // Debug overlay
    private var debugLabel: SKLabelNode?
    
    // Attack projectiles
    private var projectiles: [SKSpriteNode] = []
    
    override func didMove(to view: SKView) {
        setupScene()
        setupPlayer()
        setupDebugOverlay()
    }
    
    private func setupScene() {
        backgroundColor = SKColor.black
        physicsWorld.gravity = CGVector(dx: 0, dy: -500)
        
        // Create ground
        let ground = SKSpriteNode(color: .green, size: CGSize(width: size.width, height: 50))
        ground.position = CGPoint(x: size.width/2, y: ground.size.height/2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        addChild(ground)
    }
    
    private func setupPlayer() {
        // Create a simple square player for the pixel art aesthetic
        player = SKSpriteNode(color: .red, size: CGSize(width: pixelSize * 8, height: pixelSize * 8))
        player.position = CGPoint(x: size.width/2, y: size.height/2)
        
        // Setup physics
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.friction = 0.8
        player.physicsBody?.linearDamping = 0.1
        
        addChild(player)
    }
    
    private func setupDebugOverlay() {
        #if DEBUG
        if settings.debugOverlayEnabled {
            debugLabel = SKLabelNode(fontNamed: "Courier")
            debugLabel?.fontSize = 16
            debugLabel?.fontColor = .white
            debugLabel?.position = CGPoint(x: 10, y: size.height - 30)
            debugLabel?.horizontalAlignmentMode = .left
            debugLabel?.zPosition = 1000
            if let debugLabel = debugLabel {
                addChild(debugLabel)
            }
        }
        #endif
    }
    
    override func update(_ currentTime: TimeInterval) {
        handleInput()
        updateDebugOverlay()
        updateProjectiles()
        
        // Update previous button states for edge detection
        inputState.updatePreviousStates()
    }
    
    private func handleInput() {
        guard let playerBody = player.physicsBody else { return }
        
        // Handle movement with pixel-perfect feel
        let movement = inputState.getPixelPerfectMovement()
        
        // Apply horizontal movement
        let targetVelocityX = CGFloat(movement.x) * moveSpeed
        let velocityDifferenceX = targetVelocityX - playerBody.velocity.dx
        let forceX = velocityDifferenceX * playerBody.mass * 10  // Adjust multiplier for responsiveness
        
        playerBody.applyForce(CGVector(dx: forceX, dy: 0))
        
        // Handle jump (only when on ground and button just pressed)
        if inputState.isJumpJustPressed() && isPlayerOnGround() {
            playerBody.applyImpulse(CGVector(dx: 0, dy: jumpForce))
        }
        
        // Handle attack (spawn projectile when button just pressed)
        if inputState.isAttackJustPressed() {
            spawnProjectile()
        }
    }
    
    private func isPlayerOnGround() -> Bool {
        // Simple ground detection - check if player is close to ground level
        let groundLevel: CGFloat = 50 + player.size.height/2 + 5  // Ground height + player height/2 + small buffer
        return player.position.y <= groundLevel && abs(player.physicsBody?.velocity.dy ?? 0) < 10
    }
    
    private func spawnProjectile() {
        let projectile = SKSpriteNode(color: .yellow, size: CGSize(width: pixelSize * 2, height: pixelSize * 2))
        projectile.position = CGPoint(
            x: player.position.x + (player.size.width/2 + 10),
            y: player.position.y
        )
        
        // Setup physics for projectile
        projectile.physicsBody = SKPhysicsBody(rectangleOf: projectile.size)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.allowsRotation = false
        projectile.physicsBody?.affectedByGravity = false
        
        // Add projectile to scene and tracking array
        addChild(projectile)
        projectiles.append(projectile)
        
        // Apply velocity
        projectile.physicsBody?.velocity = CGVector(dx: 300, dy: 0)
        
        // Remove projectile after 3 seconds
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.removeFromParent()
        ])
        projectile.run(removeAction)
    }
    
    private func updateProjectiles() {
        // Remove projectiles that are off screen or have been removed
        projectiles.removeAll { projectile in
            guard projectile.parent != nil else { return true }
            
            if projectile.position.x > size.width + 50 {
                projectile.removeFromParent()
                return true
            }
            
            return false
        }
    }
    
    private func updateDebugOverlay() {
        #if DEBUG
        guard let debugLabel = debugLabel, settings.debugOverlayEnabled else { return }
        
        let movement = inputState.getPixelPerfectMovement()
        let velocityX = player.physicsBody?.velocity.dx ?? 0
        let velocityY = player.physicsBody?.velocity.dy ?? 0
        
        debugLabel.text = String(format: """
        Input: dx=%.2f, dy=%.2f
        Pixel Movement: x=%d, y=%d
        Velocity: x=%.1f, y=%.1f
        Jump: %@, Attack: %@
        OnGround: %@
        """,
        inputState.dx, inputState.dy,
        movement.x, movement.y,
        velocityX, velocityY,
        inputState.jumpPressed ? "YES" : "NO",
        inputState.attackPressed ? "YES" : "NO",
        isPlayerOnGround() ? "YES" : "NO"
        )
        #endif
    }
}
