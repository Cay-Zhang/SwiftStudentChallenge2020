import SpriteKit
import Combine
import PlaygroundSupport

public struct Level {
    
    public typealias Result = Bool
    
    public init(name: String, mapGenerators: [MapGenerating]) {
        self.name = name
        self.mapGenerators = mapGenerators
    }
    
    public var name = "Level"
    public var skyColor: UIColor = #colorLiteral(red: 0.3176470588, green: 0.7529411765, blue: 0.7882352941, alpha: 1)
    public var birdAction: Action? = nil
    public var mapGenerators: [MapGenerating]
    
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

// Generating a part of a map.
public protocol MapGenerating {
    func action(in scene: LevelScene) -> Action
}

public struct Pipes: MapGenerating {
    
    let topPipeTexture: SKTexture
    let bottomPipeTexture: SKTexture
    let pipeScale: CGFloat
    let pipeWidth: CGFloat
    let verticalPipeGap: CGFloat
    let count: Int
    
    public init(_ count: Int, topPipe: UIImage, bottomPipe: UIImage, verticalPipeGap: CGFloat = 150, pipeScale: CGFloat = 2.0) {
        // Setting up textures
        self.topPipeTexture = SKTexture(image: topPipe)
        self.topPipeTexture.filteringMode = .nearest
        self.bottomPipeTexture = SKTexture(image: bottomPipe)
        self.bottomPipeTexture.filteringMode = .nearest
        // Calculating pipe width
        self.pipeScale = pipeScale
        let topPipeWidth = topPipeTexture.size().width * pipeScale
        let bottomPipeWidth = bottomPipeTexture.size().width * pipeScale
        self.pipeWidth = max(bottomPipeWidth, topPipeWidth)
        // Setting other properties
        self.count = count
        self.verticalPipeGap = verticalPipeGap
    }
    
    func pipePair(in scene: LevelScene) -> SKNode {
        let pipeGapCenterY = scene.groundHeight + CGFloat.random(in: scene.heightAboveGround * 0.5 ... scene.heightAboveGround * 0.7)
        
        let pipePair = SKNode()
        pipePair.position = CGPoint(x: scene.size.width + pipeWidth / 2.0, y: pipeGapCenterY)
        pipePair.zPosition = -10
        
        let topPipe = SKSpriteNode(texture: topPipeTexture)
        topPipe.setScale(pipeScale)
        topPipe.position = CGPoint(x: 0.0, y: verticalPipeGap / 2.0 + topPipe.size.height / 2.0)
        
        topPipe.physicsBody = SKPhysicsBody(rectangleOf: topPipe.size)
        topPipe.physicsBody?.isDynamic = false
        topPipe.physicsBody?.categoryBitMask = scene.pipeCategory
        topPipe.physicsBody?.contactTestBitMask = scene.birdCategory
        pipePair.addChild(topPipe)
        
        let bottomPipe = SKSpriteNode(texture: bottomPipeTexture)
        bottomPipe.setScale(pipeScale)
        bottomPipe.position = CGPoint(x: 0.0, y: -verticalPipeGap / 2.0 - bottomPipe.size.height / 2.0)
        
        bottomPipe.physicsBody = SKPhysicsBody(rectangleOf: bottomPipe.size)
        bottomPipe.physicsBody?.isDynamic = false
        bottomPipe.physicsBody?.categoryBitMask = scene.pipeCategory
        bottomPipe.physicsBody?.contactTestBitMask = scene.birdCategory
        pipePair.addChild(bottomPipe)
        
        let contactNode = SKSpriteNode(color: #colorLiteral(red: 0.8421792727, green: 0.1722931956, blue: 0.08535384427, alpha: 0.2963934075), size: CGSize(width: pipeWidth, height: scene.size.height))
        contactNode.position = CGPoint(x: pipeWidth + scene.bird.size.width / 2, y: 0.0)
        contactNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeWidth, height: scene.size.height))
        contactNode.physicsBody?.isDynamic = false
        contactNode.physicsBody?.categoryBitMask = scene.scoreCategory
        contactNode.physicsBody?.contactTestBitMask = scene.birdCategory
        pipePair.addChild(contactNode)
        
        return pipePair
    }
    
    public func action(in scene: LevelScene) -> Action {
        // Create the pipes movement actions
        let movement =
            MoveBy(x: -scene.size.width - pipeWidth, y: 0.0, duration: TimeInterval(0.005 * (scene.size.width + pipeWidth)))
                .thenRemove()
                .skAction
        
        // repeatedly spawn the pipes
        return SKAction.run { [self, weak scene, movement] in
            guard let scene = scene else { return }
            let pipePair = self.pipePair(in: scene)
            scene.moving.addChild(pipePair)
            pipePair.run(movement)
        }.then(Wait(forDuration: 1))
        .repeat(self.count)
        
    }
}
