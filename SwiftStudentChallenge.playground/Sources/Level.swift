import SpriteKit
import Combine
import PlaygroundSupport

public struct Level {
    
    public typealias Result = Bool
    
    public init(name: String, birdAction: Action? = nil) {
        self.name = name
        self.birdAction = birdAction
    }
    
    public var name = "Level"
    public var skyColor: UIColor = #colorLiteral(red: 0.3176470588, green: 0.7529411765, blue: 0.7882352941, alpha: 1)
    
    var birdAction: Action?
    
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
    
    public func skyColor(_ color: UIColor) -> Level {
        modifying(\.skyColor, color)
    }
    
}

extension Level {
    func modifying<T>(_ keyPath: WritableKeyPath<Level, T>, _ value: T) -> Level {
        var copy = self
        copy[keyPath: keyPath] = value
        return copy
    }
}
