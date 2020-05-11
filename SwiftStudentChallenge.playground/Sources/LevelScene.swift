import Foundation
import SpriteKit
import PlaygroundSupport

class LevelScene: SKScene, SKPhysicsContactDelegate{
    let verticalPipeGap = 150.0
    
    var bird:SKSpriteNode!
    var skyColor: UIColor = #colorLiteral(red: 0.3176470588, green: 0.7529411765, blue: 0.7882352941, alpha: 1)
    
    var movePipesAndRemove: Action!
    var moving:SKNode!
    var pipes: SKNode!
    var canRestart = Bool()
    var scoreLabelNode:SKLabelNode!
    var score = NSInteger()
    
    // key: bird
    var birdAction: Action?
 
    let birdCategory: UInt32 = 1 << 0
    let worldCategory: UInt32 = 1 << 1
    let pipeCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    
    var finish: (Result<Level.Result, Never>) -> Void = { _ in
        print("finish promise isn't assigned.")
    }
    
    
    
    public override func didMove(to view: SKView) {
        
        canRestart = true
        
        // setup physics
        self.physicsWorld.gravity = CGVector( dx: 0.0, dy: -6.0 )
        self.physicsWorld.contactDelegate = self
        
        // setup background color
        self.backgroundColor = skyColor
        
        moving = SKNode()
        self.addChild(moving)
        
        setupPipes()
        
        
        // ground
        let groundTexture = SKTexture(image: #imageLiteral(resourceName: "land.png"))
        
        groundTexture.filteringMode = .nearest // shorter form for SKTextureFilteringMode.Nearest
        
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
        
        // skyline
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
            sprite.position = CGPoint(x: i * sprite.size.width, y: sprite.size.height / 2.0 + groundTexture.size().height * 2.0)
            sprite.run(moveSkySpritesForever)
            moving.addChild(sprite)
        }
        
        
        // setup our bird
        let birdTexture1 = SKTexture(image: #imageLiteral(resourceName: "bird-01.png"))
        birdTexture1.filteringMode = .nearest
        let birdTexture2 = SKTexture(image: #imageLiteral(resourceName: "bird-02.png"))
        birdTexture2.filteringMode = .nearest
        
        let anim = SKAction.animate(with: [birdTexture1, birdTexture2], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(anim)
        
        bird = SKSpriteNode(texture: birdTexture1)
        bird.setScale(1.0)
        bird.position = CGPoint(x: self.frame.size.width * 0.35, y:self.frame.size.height * 0.6)
        bird.run(flap)
        
        bird.run(birdAction, withKey: "bird")
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.allowsRotation = false
        
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = worldCategory | pipeCategory
        bird.physicsBody?.contactTestBitMask = worldCategory | pipeCategory
        
        self.addChild(bird)
        
        // create the ground
        let ground = SKNode()
        ground.position = CGPoint(x: 0, y: groundTexture.size().height)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: groundTexture.size().height * 2.0))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = worldCategory
        self.addChild(ground)
        
        // Initialize label and create a label which holds the score
        score = 0
        scoreLabelNode = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        scoreLabelNode.position = CGPoint( x: self.frame.midX, y: 3 * self.frame.size.height / 4 )
        scoreLabelNode.zPosition = 100
        scoreLabelNode.text = String(score)
        self.addChild(scoreLabelNode)
        
        setupLevelNameLabel()
        
    }
    
    // MARK: - Pipes
    var bottomPipeTexture: SKTexture!
    var topPipeTexture: SKTexture!
    let pipeScale: CGFloat = 2.0
    var pipeWidth: CGFloat!
    
    func setupPipes() {
        pipes = SKNode()
        moving.addChild(pipes)
        
        // setup the pipes textures
        bottomPipeTexture = SKTexture(image: #imageLiteral(resourceName: "PipeUp.png"))
        bottomPipeTexture.filteringMode = .nearest
        topPipeTexture = SKTexture(image: #imageLiteral(resourceName: "PipeDown.png"))
        topPipeTexture.filteringMode = .nearest
        
        // getting actual sizes for pipes taking scale into account
        let bottomPipeWidth = bottomPipeTexture.size().width * pipeScale
        let topPipeWidth = topPipeTexture.size().width * pipeScale
        pipeWidth = max(bottomPipeWidth, topPipeWidth)
        
        // create the pipes movement actions
        let distanceToMove = CGFloat(self.size.width + pipeWidth)
        movePipesAndRemove =
            MoveBy(x: -distanceToMove, y: 0.0, duration: TimeInterval(0.005 * distanceToMove))
                .thenRemove()
                .skAction
        
        // spawn the pipes
        let spawn = SKAction.run { [weak self] in
            self?.spawnPipes()
        }
        let delay = SKAction.wait(forDuration: TimeInterval(1.0))
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatForever(spawnThenDelay)
        self.run(spawnThenDelayForever)
    }
    
    func spawnPipes() {
        let pipePair = SKNode()
        pipePair.position = CGPoint(x: self.size.width + pipeWidth / 2.0, y: 0)
        pipePair.zPosition = -10
        
        let height = UInt32(self.size.height / 4)
        let bottomPipeCenterY = Double(arc4random_uniform(height) + height)
        
        let topPipe = SKSpriteNode(texture: topPipeTexture)
        topPipe.setScale(pipeScale)
        topPipe.position = CGPoint(x: 0.0, y: bottomPipeCenterY + Double(topPipe.size.height) + verticalPipeGap)
        
        topPipe.physicsBody = SKPhysicsBody(rectangleOf: topPipe.size)
        topPipe.physicsBody?.isDynamic = false
        topPipe.physicsBody?.categoryBitMask = pipeCategory
        topPipe.physicsBody?.contactTestBitMask = birdCategory
        pipePair.addChild(topPipe)
        
        let bottomPipe = SKSpriteNode(texture: bottomPipeTexture)
        bottomPipe.setScale(pipeScale)
        bottomPipe.position = CGPoint(x: 0.0, y: bottomPipeCenterY)
        
        bottomPipe.physicsBody = SKPhysicsBody(rectangleOf: bottomPipe.size)
        bottomPipe.physicsBody?.isDynamic = false
        bottomPipe.physicsBody?.categoryBitMask = pipeCategory
        bottomPipe.physicsBody?.contactTestBitMask = birdCategory
        pipePair.addChild(bottomPipe)
        
        let contactNode = SKNode()
        contactNode.position = CGPoint(x: topPipe.size.width + bird.size.width / 2, y: self.frame.midY)
        contactNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize( width: bottomPipe.size.width, height: self.frame.size.height ))
        contactNode.physicsBody?.isDynamic = false
        contactNode.physicsBody?.categoryBitMask = scoreCategory
        contactNode.physicsBody?.contactTestBitMask = birdCategory
        pipePair.addChild(contactNode)
        
        pipePair.run(movePipesAndRemove)
        pipes.addChild(pipePair)
        
    }
    
    func resetScene (){
        // Move bird to original position and reset velocity
        bird.position = CGPoint(x: self.frame.size.width / 2.5, y: self.frame.midY)
        bird.physicsBody?.velocity = CGVector( dx: 0, dy: 0 )
        bird.physicsBody?.collisionBitMask = worldCategory | pipeCategory
        bird.speed = 1.0
        bird.zRotation = 0.0
        
        bird.run(birdAction, withKey: "bird")
        
        // Remove all existing pipes
        pipes.removeAllChildren()
        
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
                        SKAction.run { [weak self, skyColor = self.skyColor] in
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
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        // uncomment to debug memory issues
//        for child in children {
//            child.removeAllActions()
//            child.removeFromParent()
//        }
//        self.removeAllActions()
    }
    
    // MAKR: - Level Name
    var levelName: String = "Level name not set."
    var levelNameLabel: SKLabelNode!
    
    func setupLevelNameLabel() {
        levelNameLabel = childNode(withName: "levelNameLabel") as? SKLabelNode
        levelNameLabel.text = levelName
    }
    
    deinit {
        print("LevelScene: deinit")
    }
    
    
}
