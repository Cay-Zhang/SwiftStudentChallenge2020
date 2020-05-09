import SpriteKit
import PlaygroundSupport

public struct Game {
    
    let birdAction: Action?
    var isDebugStatisticsShown = false
    
    public init(birdAction: Action? = nil) {
        self.birdAction = birdAction
    }
    
    public func showDebugStatistics() -> Game {
        var copy = self
        copy.isDebugStatisticsShown = true
        return copy
    }
    
}

extension Game {
    
    func setup(gameScene: GameScene) {
        gameScene.birdAction = birdAction?.skAction
    }
    
    public func show() {
        let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 640, height: 480))
        sceneView.ignoresSiblingOrder = true
        if self.isDebugStatisticsShown {
            sceneView.showsFPS = true
            sceneView.showsNodeCount = true
        }
        if let scene = GameScene(fileNamed: "GameScene") {
            scene.scaleMode = .aspectFill
            setup(gameScene: scene)
            // values of scene should be set up before presenting the scene
            sceneView.presentScene(scene)
        }
        PlaygroundSupport.PlaygroundPage.current.setLiveView(sceneView)
    }
}
