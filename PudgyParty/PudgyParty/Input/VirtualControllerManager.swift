import GameController
import UIKit

@MainActor
class VirtualControllerManager: ObservableObject {
    private var virtualController: GCVirtualController?
    private let inputState = InputState.shared
    private let settings = Settings.shared
    
    // MARK: - Initialization
    
    init() {
        setupControllerNotifications()
    }
    
    deinit {
        // Virtual controller cleanup happens automatically
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Interface
    
    func setupVirtualController() {
        guard settings.virtualControllerEnabled else { return }
        
        // Check if we should show virtual controller
        let shouldShow = settings.virtualControllerAlwaysVisible || GCController.controllers().isEmpty
        
        if shouldShow {
            connectVirtualController()
        }
    }
    
    func disconnect() {
        virtualController?.disconnect()
        virtualController = nil
    }
    
    // MARK: - Virtual Controller Setup
    
    private func connectVirtualController() {
        // Create configuration
        let configuration = GCVirtualController.Configuration()
        
        // Add left thumbstick for movement
        configuration.elements = [
            GCInputLeftThumbstick,
            GCInputButtonA,
            GCInputButtonB
        ]
        
        // Create and connect virtual controller
        virtualController = GCVirtualController(configuration: configuration)
        
        guard let virtualController = virtualController else {
            print("Failed to create virtual controller")
            return
        }
        
        // Setup input handlers
        setupInputHandlers(for: virtualController)
        
        // Connect the controller
        virtualController.connect { [weak self] error in
            if let error = error {
                print("Failed to connect virtual controller: \(error)")
            } else {
                print("Virtual controller connected successfully")
                self?.customizeAppearance()
            }
        }
    }
    
    private func setupInputHandlers(for controller: GCVirtualController) {
        guard let gamepad = controller.controller?.extendedGamepad else { return }
        
        // Left thumbstick for movement
        gamepad.leftThumbstick.valueChangedHandler = { [weak self] _, xValue, yValue in
            self?.inputState.updateMovement(dx: xValue, dy: yValue)
        }
        
        // Button A for jump
        gamepad.buttonA.valueChangedHandler = { [weak self] _, value, pressed in
            self?.inputState.updateButtons(
                jump: pressed,
                attack: self?.inputState.attackPressed ?? false
            )
        }
        
        // Button B for attack
        gamepad.buttonB.valueChangedHandler = { [weak self] _, value, pressed in
            self?.inputState.updateButtons(
                jump: self?.inputState.jumpPressed ?? false,
                attack: pressed
            )
        }
    }
    
    private func customizeAppearance() {
        // Hook for customizing virtual controller appearance
        // Can be extended to modify layout, colors, etc.
        print("Virtual controller appearance can be customized here")
    }
    
    // MARK: - Physical Controller Handling
    
    private func setupControllerNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerDidConnect),
            name: .GCControllerDidConnect,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerDidDisconnect),
            name: .GCControllerDidDisconnect,
            object: nil
        )
    }
    
    @objc private func controllerDidConnect(_ notification: Notification) {
        print("Physical controller connected")
        
        // Hide virtual controller unless forced to stay visible
        if !settings.virtualControllerAlwaysVisible {
            disconnect()
        }
        
        // Setup handlers for the physical controller
        if let controller = notification.object as? GCController {
            setupPhysicalControllerHandlers(for: controller)
        }
    }
    
    @objc private func controllerDidDisconnect(_ notification: Notification) {
        print("Physical controller disconnected")
        
        // Show virtual controller if enabled and no other physical controllers
        if settings.virtualControllerEnabled && GCController.controllers().isEmpty {
            connectVirtualController()
        }
    }
    
    private func setupPhysicalControllerHandlers(for controller: GCController) {
        guard let gamepad = controller.extendedGamepad else { return }
        
        // Left thumbstick for movement
        gamepad.leftThumbstick.valueChangedHandler = { [weak self] _, xValue, yValue in
            self?.inputState.updateMovement(dx: xValue, dy: yValue)
        }
        
        // Button A for jump
        gamepad.buttonA.valueChangedHandler = { [weak self] _, value, pressed in
            self?.inputState.updateButtons(
                jump: pressed,
                attack: self?.inputState.attackPressed ?? false
            )
        }
        
        // Button B for attack
        gamepad.buttonB.valueChangedHandler = { [weak self] _, value, pressed in
            self?.inputState.updateButtons(
                jump: self?.inputState.jumpPressed ?? false,
                attack: pressed
            )
        }
    }
}
