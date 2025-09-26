import UIKit
import SpriteKit
import GameController

class GameViewController: UIViewController {
    
    private var virtualControllerManager: VirtualControllerManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the GameScene
        if let view = self.view as! SKView? {
            let scene = GameScene(size: view.bounds.size)
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            #if DEBUG
            view.showsFPS = Settings.shared.debugOverlayEnabled
            view.showsNodeCount = Settings.shared.debugOverlayEnabled
            #endif
        }
        
        // Initialize virtual controller manager
        setupVirtualController()
    }
    
    private func setupVirtualController() {
        virtualControllerManager = VirtualControllerManager()
        virtualControllerManager?.setupVirtualController()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        virtualControllerManager?.disconnect()
    }
}
