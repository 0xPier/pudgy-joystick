import Foundation

@MainActor
class Settings: ObservableObject {
    static let shared = Settings()
    
    @Published var virtualControllerEnabled: Bool {
        didSet {
            UserDefaults.standard.set(virtualControllerEnabled, forKey: "virtualControllerEnabled")
        }
    }
    
    @Published var virtualControllerAlwaysVisible: Bool {
        didSet {
            UserDefaults.standard.set(virtualControllerAlwaysVisible, forKey: "virtualControllerAlwaysVisible")
        }
    }
    
    @Published var debugOverlayEnabled: Bool {
        didSet {
            UserDefaults.standard.set(debugOverlayEnabled, forKey: "debugOverlayEnabled")
        }
    }
    
    private init() {
        // Load settings from UserDefaults with default values
        self.virtualControllerEnabled = UserDefaults.standard.object(forKey: "virtualControllerEnabled") as? Bool ?? true
        self.virtualControllerAlwaysVisible = UserDefaults.standard.object(forKey: "virtualControllerAlwaysVisible") as? Bool ?? false
        
        // Debug overlay enabled only in debug builds
        #if DEBUG
        self.debugOverlayEnabled = UserDefaults.standard.object(forKey: "debugOverlayEnabled") as? Bool ?? true
        #else
        self.debugOverlayEnabled = false
        #endif
    }
}
