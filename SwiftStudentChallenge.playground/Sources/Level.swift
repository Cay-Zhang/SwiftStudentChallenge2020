import SpriteKit
import Combine
import PlaygroundSupport

public struct Level {
    
    public typealias Result = Bool
    
    public init(name: String) {
        self.name = name
    }
    public var name = ""
    
    public func run(in game: Game) -> Future<Level.Result, Never> {
        Future { promise in
            if let scene = LevelScene(fileNamed: "LevelScene") {
                scene.scaleMode = .aspectFill
                scene.finish = promise
                // values of scene should be set up before presenting the scene
                game._sceneView.presentScene(scene)
                PlaygroundSupport.PlaygroundPage.current.setLiveView(game._sceneView)
            } else {
                fatalError()
            }
        }
    }
    
}
