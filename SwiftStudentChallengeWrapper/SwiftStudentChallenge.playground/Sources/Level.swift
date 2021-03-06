import SpriteKit
import Combine
import PlaygroundSupport

public struct Level {
    
    public typealias Result = Bool
    
    public init(name: String, @MapBuilder _ buildMapComponents: () -> [MapComponent]) {
        self.name = name
        self.mapComponents = buildMapComponents()
    }
    
    public init(name: String, @MapBuilder _ buildMapComponents: () -> MapComponent) {
        self.name = name
        self.mapComponents = [buildMapComponents()]
    }
    
    public var name = "Level"
    public var skyTint: UIColor = #colorLiteral(red: 0.3176470588, green: 0.7529411765, blue: 0.7882352941, alpha: 1)
    public var birdAction: Action? = nil
    public var mapComponents: [MapComponent]
    public var isCheatModeOn: Bool = false
    
    public func run(in view: SKView) -> Future<Level.Result, Never> {
        Future { [self] promise in
            if let scene = LevelScene(fileNamed: "LevelScene") {
                scene.scaleMode = .aspectFill
                scene.finish = promise
                
                // Setup Level Scene
                scene.level = self
                
                // values of scene should be set up before presenting the scene
                view.presentScene(scene)
                PlaygroundSupport.PlaygroundPage.current.setLiveView(view)
            } else {
                fatalError()
            }
        }
    }
    
    public func birdAction(_ action: Action) -> Level {
        modifying(\.birdAction, action)
    }
    
    public func birdAction(_ buildAction: () -> Action) -> Level {
        modifying(\.birdAction, buildAction())
    }
    
    public func skyTint(_ tint: UIColor) -> Level {
        modifying(\.skyTint, tint)
    }
    
    public func cheat(_ isCheatModeOn: Bool = true) -> Level {
        modifying(\.isCheatModeOn, isCheatModeOn)
    }
    
}

extension Level {
    func modifying<T>(_ keyPath: WritableKeyPath<Level, T>, _ value: T) -> Level {
        var copy = self
        copy[keyPath: keyPath] = value
        return copy
    }
}
