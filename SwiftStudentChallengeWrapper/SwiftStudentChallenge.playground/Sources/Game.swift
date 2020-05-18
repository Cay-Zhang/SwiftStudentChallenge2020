import SpriteKit
import PlaygroundSupport
import Combine

public struct Game {
    
    let _sceneView: SKView = SKView(frame: CGRect(x: 0 , y: 0, width: 768, height: 768))
    
    
    var isDebugStatisticsShown = false
    
    public var levels: [Level]
    let cancelBag = CancelBag()
    var levelSubject = PassthroughSubject<(Int, Bool), Never>()
    
    
    public init(levels: [Level] = []) {
        self.levels = levels
    }
    
    public init(@GameBuilder _ buildLevels: () -> [Level]){
        self.levels = buildLevels()
    }
    
    public init(@GameBuilder _ buildLevels: () -> Level){
        self.levels = [buildLevels()]
    }
    
    public func showDebugStatistics() -> Game {
        var copy = self
        copy.isDebugStatisticsShown = true
        return copy
    }
    
    public func appendingLevel(_ level: Level) -> Game {
        var copy = self
        copy.levels.append(level)
        return copy
    }
    
    public func appendingLevel(_ buildLevel: () -> Level) -> Game {
        var copy = self
        copy.levels.append(buildLevel())
        return copy
    }
    
}

extension Game {
    
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
        
        guard let firstLevel = levels.first else {
            print("There's no level in this game.")
            fatalError()
        }
        
        setupSceneView()
        
        levelSubject
//            .print()
            .sink { [levels, weak levelSubject, weak cancelBag, weak _sceneView] value in
                guard let levelSubject = levelSubject, let cancelBag = cancelBag, let sceneView = _sceneView else { return }
                let (index, _) = value
                if (index + 1) < levels.endIndex {
                    levels[index + 1]
                        .run(in: sceneView)
                        .sink { [index, weak levelSubject] value in
                            levelSubject?.send((index + 1, value))
                        }
                        .store(in: cancelBag)
                } else {
                    levelSubject.send(completion: .finished)
                }
            }
            .store(in: cancelBag)
        
        
        firstLevel.run(in: _sceneView)
            .sink { [weak levelSubject] value in
                levelSubject?.send((0, value))
            }
            .store(in: cancelBag)

        
        
        
        
    }
    
    
}

@_functionBuilder
public struct GameBuilder {
    public static func buildBlock(_ levels: Level?...) -> [Level] {
        return levels.compactMap { $0 }
    }
    
    public static func buildBlock(_ levels: Level...) -> [Level] {
        return levels
    }
}
