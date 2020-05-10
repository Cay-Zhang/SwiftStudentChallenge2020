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
    
    var birdAction: Action?
    
    public func run(in view: SKView) -> Future<Level.Result, Never> {
        Future { [self] promise in
            if let scene = LevelScene(fileNamed: "LevelScene") {
                scene.scaleMode = .aspectFill
                scene.finish = promise
                
                // Setup Level Scene
                scene.birdAction = self.birdAction?.skAction
                scene.levelName = self.name
                
                // values of scene should be set up before presenting the scene
                view.presentScene(scene)
                PlaygroundSupport.PlaygroundPage.current.setLiveView(view)
            } else {
                fatalError()
            }
        }
    }
    
}
