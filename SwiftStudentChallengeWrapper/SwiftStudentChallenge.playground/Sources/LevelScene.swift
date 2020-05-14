import Foundation
import SpriteKit
import PlaygroundSupport

public class LevelScene: SKScene, SKPhysicsContactDelegate{
    
    var level: Level!
    
    var bird: SKSpriteNode!
    
    var movePipesAndRemove: Action!
    var moving: SKNode!
    var canRestart = Bool()
    var scoreLabelNode: SKLabelNode!
    var score = NSInteger()
 
    let birdCategory: UInt32 = 1 << 0
    let worldCategory: UInt32 = 1 << 1
    let pipeCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    let levelEndCategory: UInt32 = 1 << 4
    let fieldCategory: UInt32 = 1 << 5
    
    var finish: (Result<Level.Result, Never>) -> Void = { _ in
        print("finish promise isn't assigned.")
    }
    
    
    
    public override func didMove(to view: SKView) {
        
        canRestart = true
        
        // setup physics
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.0)
        self.physicsWorld.contactDelegate = self
        
        // setup background color
        self.backgroundColor = level.skyColor
        
        moving = SKNode()
        self.addChild(moving)
        
        setupGround()
        
        setupSky()
        
        
        // setup bird
        let birdTexture1 = SKTexture(image: #imageLiteral(resourceName: "bird-01.png"))
        birdTexture1.filteringMode = .nearest
        let birdTexture2 = SKTexture(image: #imageLiteral(resourceName: "bird-02.png"))
        birdTexture2.filteringMode = .nearest
        
        let anim = SKAction.animate(with: [birdTexture1, birdTexture2], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(anim)
        
        bird = SKSpriteNode(texture: birdTexture1)
        bird.setScale(1.0)
        bird.position = CGPoint(x: self.frame.size.width * 0.35, y: self.frame.size.height * 0.6)
        bird.run(flap)
        
        bird.run(level.birdAction, withKey: "bird")
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.allowsRotation = false
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = worldCategory | pipeCategory
        bird.physicsBody?.contactTestBitMask = worldCategory | pipeCategory
        bird.physicsBody?.fieldBitMask = fieldCategory
        
        self.addChild(bird)
        
        
        
        // Initialize label and create a label which holds the score
        score = 0
        scoreLabelNode = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        scoreLabelNode.position = CGPoint( x: self.frame.midX, y: 3 * self.frame.size.height / 4 )
        scoreLabelNode.zPosition = 100
        scoreLabelNode.text = String(score)
        self.addChild(scoreLabelNode)
        
        setupLevelNameLabel()
        
        runMap()
        
    }
    
    // MARK: - Map
    func runMap() {
        let actions = level.mapComponents.map { $0.action(in: self) }
        Actions(running: .sequentially, actions)
            .then(SKAction.run { [weak self] in
                guard let self = self else { return }
                let levelEndNode = SKSpriteNode(color: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 0.5), size: CGSize(width: 20, height: self.size.height))
                levelEndNode.position = CGPoint(x: self.size.width, y: self.size.height / 2.0)
                levelEndNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 20, height: self.size.height))
                levelEndNode.physicsBody?.isDynamic = false
                levelEndNode.physicsBody?.categoryBitMask = self.levelEndCategory
                levelEndNode.physicsBody?.contactTestBitMask = self.birdCategory
                self.moving.addChild(levelEndNode)
                MoveBy(x: -self.size.width - 20.0, y: 0.0, duration: TimeInterval(0.005 * (self.size.width + 20.0)))
                    .thenRemove()
                    .run(on: levelEndNode)
            })
            .run(on: self)
    }
    
    
    // MARK: - Ground
    var groundTexture: SKTexture = {
        let texture = SKTexture(image: #imageLiteral(resourceName: "land.png"))
        texture.filteringMode = .nearest
        return texture
    }()
    lazy var groundHeight: CGFloat = self.groundTexture.size().height * 2.0  // ground is scaled to 2x
    lazy var heightAboveGround: CGFloat = self.size.height - self.groundHeight
    
    func setupGround() {
        let moveGroundSpritesForever = Actions(running: .sequentially) {
            MoveBy(x: -groundTexture.size().width * 2.0, y: 0, duration: TimeInterval(0.02 * groundTexture.size().width * 2.0))
            MoveBy(x: groundTexture.size().width * 2.0, y: 0, duration: 0.0)
        }.repeatForever()
        
        for i in 0 ..< 2 + Int(self.frame.size.width / ( groundTexture.size().width * 2 )) {
            let i = CGFloat(i)
            let sprite = SKSpriteNode(texture: groundTexture)
            sprite.setScale(2.0)
            sprite.position = CGPoint(x: i * sprite.size.width, y: sprite.size.height / 2.0)
            sprite.run(moveGroundSpritesForever)
            moving.addChild(sprite)
        }
        
        // create the ground
        let ground = SKNode()
        ground.position = CGPoint(x: 0, y: groundTexture.size().height)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: groundTexture.size().height * 2.0))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = worldCategory
        self.addChild(ground)
    }
    
    // MARK: - Sky
    func setupSky() {
        let skyTexture = SKTexture(image: #imageLiteral(resourceName: "sky.png"))

        skyTexture.filteringMode = .nearest

        let moveSkySpritesForever =
            MoveBy(x: -skyTexture.size().width * 2.0, y: 0, duration: TimeInterval(0.1 * skyTexture.size().width * 2.0))
                .then(MoveBy(x: skyTexture.size().width * 2.0, y: 0, duration: 0.0))
                .repeatForever()

        for i in 0 ..< 2 + Int(self.frame.size.width / ( skyTexture.size().width * 2 )) {
            let i = CGFloat(i)
            let sprite = SKSpriteNode(texture: skyTexture)
            sprite.setScale(2.0)
            sprite.zPosition = -20
            sprite.position = CGPoint(x: i * sprite.size.width, y: sprite.size.height / 2.0 + skyTexture.size().height * 2.0) //
            sprite.run(moveSkySpritesForever)
            moving.addChild(sprite)
        }
    }
    
    
    
    func resetScene (){
        // Move bird to original position and reset velocity
        bird.position = CGPoint(x: self.frame.size.width / 2.5, y: self.frame.midY)
        bird.physicsBody?.velocity = CGVector( dx: 0, dy: 0 )
        bird.physicsBody?.collisionBitMask = worldCategory | pipeCategory
        bird.speed = 1.0
        bird.zRotation = 0.0
        
        bird.run(level.birdAction, withKey: "bird")
        
        // Remove all existing pipes
        moving.removeAllChildren()
        
        // Reset _canRestart
        canRestart = false
        
        // Reset score
        score = 0
        scoreLabelNode.text = String(score)
        
        // Restart animation
        moving.speed = 1
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if moving.speed > 0  {
            for _ in touches { // do we need all touches?
                bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 7))
            }
        } else if canRestart {
            self.resetScene()
        }
        super.touchesBegan(touches, with: event)
    }
    
    public override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        let value = bird.physicsBody!.velocity.dy * ( bird.physicsBody!.velocity.dy < 0 ? 0.003 : 0.001 )
        bird.zRotation = min( max(-1, value), 0.5 )
    }
    
    public func didBegin(_ contact: SKPhysicsContact) {
        if moving.speed > 0 {
            if ( contact.bodyA.categoryBitMask & scoreCategory ) == scoreCategory || ( contact.bodyB.categoryBitMask & scoreCategory ) == scoreCategory {
                // Bird has contact with score entity
                score += 1
                scoreLabelNode.text = String(score)
                    
                // Add a little visual feedback for the score increment
                Actions(running: .sequentially) {
                    Scale(to: 1.5, duration: 0.1)
                    Scale(to: 1.0, duration: 0.1)
                }.run(on: scoreLabelNode)
                
            } else if (contact.bodyA.categoryBitMask & levelEndCategory) == levelEndCategory || (contact.bodyB.categoryBitMask & levelEndCategory) == levelEndCategory {
                // Level End
                scoreLabelNode.text = "Congratulations!"
                Actions(running: .sequentially) {
                    Scale(to: 1.5, duration: 0.1)
                    Scale(to: 1.0, duration: 0.1)
                    Scale(to: 1.5, duration: 0.1)
                    Scale(to: 1.0, duration: 0.1)
                    Wait(forDuration: 1)
                }.run(on: scoreLabelNode) /*onComplete:*/ { [weak self] in
                    self?.finish(.success(true))
                }
            } else {
                
                moving.speed = 0
                
                bird.physicsBody?.collisionBitMask = worldCategory
                bird.run(Rotate(by: .degrees(Double(bird.position.y) * 2), duration: 1)) { [weak self] in
                    self?.bird.speed = 0
                }
                
                // Flash background if contact is detected
                Actions(running: .sequentially) {
                    Actions(running: .sequentially) {
                        SKAction.run { [weak self] in
                            self?.backgroundColor = SKColor(red: 1, green: 0, blue: 0, alpha: 1.0)
                        }
                        Wait(forDuration: 0.05)
                        SKAction.run { [weak self, skyColor = self.level.skyColor] in
                            self?.backgroundColor = skyColor
                        }
                        Wait(forDuration: 0.05)
                    }.repeat(4)
                    
                    SKAction.run { [weak self] in
                        self?.canRestart = true
                    }
                }.run(on: self, withKey: "flash")
                
//                contact.bodyA.applyAngularImpulse(100)
                
//                if let node = contact.bodyA.node as? SKSpriteNode {
//                    print(node)
//                    let pulsedRed = SKAction.sequence([
//                        SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.15),
//                        SKAction.wait(forDuration: 0.1),
//                        SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.15)
//                    ])
//
//                    node.run(pulsedRed, withKey: "red")
//                }
                
                
                finish(.success(true))
            }
        }
    }
    
    public override func willMove(from view: SKView) {
        super.willMove(from: view)
        // uncomment to debug memory issues
//        for child in children {
//            child.removeAllActions()
//            child.removeFromParent()
//        }
//        self.removeAllActions()
    }
    
    // MARK: - Level Name
    var levelNameLabel: SKLabelNode!
    
    func setupLevelNameLabel() {
        levelNameLabel = childNode(withName: "levelNameLabel") as? SKLabelNode
        levelNameLabel.text = level.name
        
        Actions(running: .sequentially) {
            Wait(forDuration: 2)
            Fade(.out, duration: 0.7)
            Remove()
        }.run(on: levelNameLabel)
    }
    
    deinit {
        print("LevelScene: deinit")
    }
    
    
}
