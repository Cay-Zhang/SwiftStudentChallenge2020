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
    let pipeWidth: CGFloat
    let verticalPipeGap: CGFloat
    let count: Int
    let interval: TimeInterval
    
    public init(_ count: Int, interval: TimeInterval = 1.0, topPipe: UIImage = #imageLiteral(resourceName: "PipeDown.png"), bottomPipe: UIImage = #imageLiteral(resourceName: "PipeUp.png"), verticalPipeGap: CGFloat = 150, pipeScale: CGFloat = 2.0) {
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
        self.interval = interval
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
        
        let scoreNode = SKSpriteNode(color: #colorLiteral(red: 0.8421792727, green: 0.1722931956, blue: 0.08535384427, alpha: 0), size: CGSize(width: pipeWidth, height: scene.size.height))
        scoreNode.position = CGPoint(x: pipeWidth + scene.bird.size.width / 2, y: 0.0)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeWidth, height: scene.size.height))
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = scene.scoreCategory
        scoreNode.physicsBody?.contactTestBitMask = scene.birdCategory
        pipePair.addChild(scoreNode)
        
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
        }.then(Wait(forDuration: self.interval))
        .repeat(self.count)
        
    }
}


/// A custom parameter attribute that constructs paths from closures.
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
    
    /// Provides support for “if” statements in multi-statement closures, producing an optional path component that is added only when the condition evaluates to true.
    public static func buildIf(_ mapComponent: MapComponent?) -> MapComponent? {
        return mapComponent
    }
    
    public static func buildOptional(_ mapComponent: MapComponent?) -> MapComponent? {
        return mapComponent
    }
    
    public static func buildEither(first: MapComponent) -> MapComponent {
        return first
    }

    public static func buildEither(second: MapComponent) -> MapComponent {
        return second
    }
}
