import SpriteKit
import PlaygroundSupport
import Combine

public struct Game {
    
    let birdAction: Action?
    var isDebugStatisticsShown = false
    
    public var levels: [Level] = []
    let cancelBag = CancelBag()
    var levelSubject = PassthroughSubject<(Int, Bool), Never>()
    
    
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

public extension Game {
    mutating func runLevels() {
        
        levelSubject
            .print()
            .sink { [levels, weak levelSubject, weak cancelBag] value in
                guard let levelSubject = levelSubject, let cancelBag = cancelBag else { return }
                let (index, result) = value
                print(levels[index].name)
                if (index + 1) < levels.endIndex {
                    levels[index + 1]
                        .run()
                        .sink { [index, weak levelSubject] value in
                            levelSubject?.send((index + 1, value))
                        }
                        .store(in: cancelBag)
                } else {
                    levelSubject.send(completion: .finished)
                }
            }
            .store(in: cancelBag) //
        
        
        levels.first!.run()
            .sink { [levelSubject] value in
                levelSubject.send((0, value))
            }
            .store(in: cancelBag) //
        
    }
    
    
}

public var sharedCancelBag = Set<AnyCancellable>()
