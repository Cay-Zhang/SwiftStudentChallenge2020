import SpriteKit
import PlaygroundSupport
import Combine

public struct Game {
    
    let _sceneView: SKView = SKView(frame: CGRect(x:0 , y:0, width: 640, height: 480))
    
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
    
    func setup(levelScene: LevelScene) {
        levelScene.birdAction = birdAction?.skAction
    }
    
    func setupSceneView() {
        _sceneView.ignoresSiblingOrder = true
        if self.isDebugStatisticsShown {
            _sceneView.showsFPS = true
            _sceneView.showsNodeCount = true
        }
    }
    
}

public extension Game {
    func runLevels() {
        
        setupSceneView()
        
        levelSubject
//            .print()
            .sink { [levels, weak levelSubject, weak cancelBag, weak _sceneView] value in
                guard let levelSubject = levelSubject, let cancelBag = cancelBag, let sceneView = _sceneView else { return }
                let (index, result) = value
                if (index + 1) < levels.endIndex {
                    
                    // 10 references before removing actions
                    print(CFGetRetainCount(sceneView.scene))
                    sceneView.scene?.removeAllActions()
                    print(CFGetRetainCount(sceneView.scene))
                    //  6 references after removing actions
                    
                    
                    
                    
                    levels[index + 1]
                        .run(in: self)
                        .sink { [index, weak levelSubject] value in
                            levelSubject?.send((index + 1, value))
                        }
                        .store(in: cancelBag)
                } else {
                    levelSubject.send(completion: .finished)
                }
            }
            .store(in: cancelBag)
        
        
        levels.first!.run(in: self)
            .sink { [levelSubject] value in
                levelSubject.send((0, value))
            }
            .store(in: cancelBag)
        
        
        
    }
    
    
}

public var sharedCancelBag = Set<AnyCancellable>()
