import SwiftUI
import SpriteKit

// Generating a part of a map.
public protocol MapComponent {
    func action(in scene: LevelScene) -> Action
}

public struct Pipes: MapComponent {
    
    let topPipeTexture: SKTexture
    let bottomPipeTexture: SKTexture
    let pipeScale: CGFloat
    let pipeHeightScale: CGFloat
    let pipeWidth: CGFloat
    let count: Int
    
    var pipeActions: (_ pipeNumber: Int) -> Action? = { _ in nil }
    public var intervals: (_ pipeNumber: Int) -> TimeInterval
    var pipeGaps: (_ pipeNumber: Int) -> CGFloat
    
    public init(_ count: Int, constantInterval: TimeInterval = 1.0, constantPipeGap: CGFloat = 150, topPipe: UIImage = #imageLiteral(resourceName: "PipeDown.png"), bottomPipe: UIImage = #imageLiteral(resourceName: "PipeUp.png"), pipeScale: CGFloat = 2.0, pipeHeightScale: CGFloat = 2.0) {
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
        self.pipeHeightScale = pipeHeightScale
        self.count = count
        self.intervals = { _ in constantInterval }
        self.pipeGaps = { _ in constantPipeGap }
    }
    
    func pipePair(in scene: LevelScene, pipeNumber: Int) -> SKNode {
        let verticalPipeGap = pipeGaps(pipeNumber)
        let pipeGapCenterY = scene.groundHeight + CGFloat.random(in: scene.heightAboveGround * 0.5 ... scene.heightAboveGround * 0.7)
        
        let pipePair = SKNode()
        pipePair.position = CGPoint(x: scene.size.width + pipeWidth / 2.0, y: pipeGapCenterY)
        pipePair.zPosition = -10
        
        let topPipe = SKSpriteNode(texture: topPipeTexture)
        topPipe.centerRect = CGRect(x: 0.3, y: 0.3, width: 0.4, height: 0.6)
        topPipe.setScale(pipeScale)
        topPipe.yScale *= pipeHeightScale
        topPipe.position = CGPoint(x: 0.0, y: verticalPipeGap / 2.0 + topPipe.size.height / 2.0)
        
        topPipe.physicsBody = SKPhysicsBody(rectangleOf: topPipe.size)
        topPipe.physicsBody?.isDynamic = false
        topPipe.physicsBody?.categoryBitMask = scene.fatalLevelContentCategory
        topPipe.physicsBody?.contactTestBitMask = scene.birdCategory
        pipePair.addChild(topPipe)
        
        let bottomPipe = SKSpriteNode(texture: bottomPipeTexture)
        bottomPipe.centerRect = CGRect(x: 0.3, y: 0.1, width: 0.4, height: 0.6)
        bottomPipe.setScale(pipeScale)
        bottomPipe.yScale *= pipeHeightScale
        bottomPipe.position = CGPoint(x: 0.0, y: -verticalPipeGap / 2.0 - bottomPipe.size.height / 2.0)
        
        bottomPipe.physicsBody = SKPhysicsBody(rectangleOf: bottomPipe.size)
        bottomPipe.physicsBody?.isDynamic = false
        bottomPipe.physicsBody?.categoryBitMask = scene.fatalLevelContentCategory
        bottomPipe.physicsBody?.contactTestBitMask = scene.birdCategory
        pipePair.addChild(bottomPipe)
        
        return pipePair
    }
    
    public func spawnPipePairAction(in scene: LevelScene, pipeNumber: Int, pipeMovementAction: Action) -> Action {
        let pipeAction = Actions(running: .parallelly) {
            pipeMovementAction
            pipeActions(pipeNumber)
        }.skAction
        
        return SKAction.run { [self, weak scene, pipeAction, pipeNumber] in
            guard let scene = scene else { return }
            let pipePair = self.pipePair(in: scene, pipeNumber: pipeNumber)
            scene.levelContent.addChild(pipePair)
            pipePair.run(pipeAction)
        }
    }
    
    public func action(in scene: LevelScene) -> Action {
        // Create the pipes movement action
        let pipeMovementAction = MoveBy(x: -scene.size.width - pipeWidth, y: 0.0, duration: TimeInterval(0.005 * (scene.size.width + pipeWidth))).thenRemove()
        
        let actions = (1...count).lazy
            .flatMap { (pipeNumber: Int) -> [Action] in
                [self.spawnPipePairAction(in: scene, pipeNumber: pipeNumber, pipeMovementAction: pipeMovementAction),
                 Wait(forDuration: self.intervals(pipeNumber))]
            }
        return Actions(running: .sequentially, Array(actions))
    }
}


public extension Pipes {
    func customIntervals(_ intervals: @escaping (_ pipeNumber: Int) -> TimeInterval) -> Self {
        var copy = self
        copy.intervals = intervals
        return copy
    }
    func progressiveIntervals(from fromInterval: TimeInterval, to toInterval: TimeInterval) -> Self {
        let step = (toInterval - fromInterval) / Double(self.count - 1)
        var copy = self
        copy.intervals = { [fromInterval, step] pipeNumber in
            fromInterval + step * Double(pipeNumber - 1)
        }
        return copy
    }
    func customPipeActions(_ pipeActions: @escaping (_ pipeNumber: Int) -> Action) -> Self {
        var copy = self
        copy.pipeActions = pipeActions
        return copy
    }
    func customPipeGaps(_ pipeGaps: @escaping (_ pipeNumber: Int) -> CGFloat) -> Self {
        var copy = self
        copy.pipeGaps = pipeGaps
        return copy
    }
    func progressivePipeGaps(from fromPipeGap: CGFloat, to toPipeGap: CGFloat) -> Self {
        let step = (toPipeGap - fromPipeGap) / CGFloat(self.count - 1)
        var copy = self
        copy.pipeGaps = { [fromPipeGap, step] pipeNumber in
            fromPipeGap + step * CGFloat(pipeNumber - 1)
        }
        return copy
    }
}

public struct Missiles: MapComponent {
    let texture = SKTexture(image: #imageLiteral(resourceName: "missile.png"))
    let count: Int
    let scale: CGFloat = 1.5
    
    public init(_ count: Int) {
        self.count = count
    }
    
    public func action(in scene: LevelScene) -> Action {
        let size = texture.size().applying(CGAffineTransform(scaleX: scale, y: scale))
        
        return Actions(running: .sequentially) {
            SKAction.run { [weak scene, self, size] in
                guard let scene = scene else { return }
                let node = SKSpriteNode(texture: self.texture)
                node.setScale(self.scale)
                node.zRotation = CGFloat.pi
                node.zPosition = 50
                node.physicsBody = SKPhysicsBody(rectangleOf: size)
                node.physicsBody?.isDynamic = false
                node.physicsBody?.categoryBitMask = scene.fatalLevelContentCategory
                node.physicsBody?.contactTestBitMask = scene.birdCategory
                node.position.x = scene.size.width + size.width / 2.0
                node.position.y = scene.groundHeight + CGFloat.random(in: 0.0 ... scene.heightAboveGround)
                scene.addChild(node)
                
                let moveDistance = scene.size.width + size.width
                MoveBy(x: -moveDistance, duration: Double(moveDistance) / 400.0).run(on: node)
            }
            Wait(forDuration: 0.1)
        }.repeat(count)
    }
}

public protocol Field: MapComponent {
    var width: CGFloat { get }
    var strength: Float { get }
    var particleEffectsFileName: String? { get set }
    var fieldNode: SKFieldNode { get }
    func applyingParticleEffects(fileNamed fileName: String) -> Self
}

extension Field {
    public func action(in scene: LevelScene) -> Action {
        SKAction.run { [self, weak scene] in
            guard let scene = scene else { return }
            let fieldNode = self.fieldNode
            fieldNode.categoryBitMask = scene.fieldCategory
            fieldNode.strength = self.strength
            fieldNode.position.x = scene.size.width + self.width / 2.0
            fieldNode.position.y = scene.size.height / 2.0
            fieldNode.region = SKRegion(size: CGSize(width: self.width, height: scene.size.height))
            // Applying particle effects if needed
            if let fileName = self.particleEffectsFileName, let emitterNode = SKEmitterNode(fileNamed: fileName) {
                emitterNode.particlePositionRange = CGVector(dx: self.width, dy: scene.size.height)
                fieldNode.addChild(emitterNode)
            }
            scene.levelContent.addChild(fieldNode)
            
            MoveBy(x: -scene.size.width - self.width, duration: TimeInterval(0.005 * (scene.size.width + self.width)))
                .thenRemove()
                .run(on: fieldNode)
        }
    }
    public func applyingParticleEffects(fileNamed fileName: String) -> Self {
        var copy = self
        copy.particleEffectsFileName = fileName
        return copy
    }
}

public struct GravityField: Field {
    
    public let width: CGFloat
    public let strength: Float
    public var particleEffectsFileName: String?
    
    public init(width: CGFloat, strength: Float = 6) {
        self.width = width
        self.strength = strength
        self.particleEffectsFileName = "GravityField"
    }
    
    public var fieldNode: SKFieldNode {
        SKFieldNode.linearGravityField(withVector: [0, -1, 0])
    }
}

public struct NoiseField: Field {
    public let width: CGFloat
    public let strength: Float
    public var particleEffectsFileName: String?
    
    public init(width: CGFloat, strength: Float = 0.07) {
        self.width = width
        self.strength = strength
        self.particleEffectsFileName = "NoiseField"
    }
    
    public var fieldNode: SKFieldNode {
        SKFieldNode.noiseField(withSmoothness: 0.8, animationSpeed: 0.5)
    }
}

extension Wait: MapComponent {
    public func action(in scene: LevelScene) -> Action {
        self
    }
}

@_functionBuilder
public struct MapBuilder {
    
    public static func buildBlock(_ mapComponent: MapComponent) -> [MapComponent] {
        return [mapComponent]
    }

    public static func buildBlock(_ mapComponent: MapComponent?) -> [MapComponent] {
        return mapComponent.map { [$0] } ?? []
    }

    public static func buildBlock(_ mapComponents: MapComponent?...) -> [MapComponent] {
        return mapComponents.compactMap { $0 }
    }
    
    public static func buildBlock(_ mapComponents: MapComponent...) -> [MapComponent] {
        return mapComponents
    }
}
