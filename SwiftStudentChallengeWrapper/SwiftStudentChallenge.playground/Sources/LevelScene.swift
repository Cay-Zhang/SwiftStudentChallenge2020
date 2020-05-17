import Foundation
import SpriteKit
import PlaygroundSupport

public class LevelScene: SKScene, SKPhysicsContactDelegate{
    
    var state: State?
    
    var level: Level!
    
    var bird: SKSpriteNode!
    
    var movePipesAndRemove: Action!
 
    let birdCategory: UInt32 = 1 << 0
    let boundaryCategory: UInt32 = 1 << 1
    let fatalLevelContentCategory: UInt32 = 1 << 2
    let levelEndCategory: UInt32 = 1 << 3
    let fieldCategory: UInt32 = 1 << 4
    
    var finish: (Result<Level.Result, Never>) -> Void = { _ in
        print("finish promise isn't assigned.")
    }
    
    lazy var movingContent: SKNode = {
        let node = SKNode()
        self.addChild(node)
        return node
    }()
    
    lazy var levelContent: SKNode = {
        let node = SKNode()
        self.movingContent.addChild(node)
        return node
    }()
    
    public override func didMove(to view: SKView) {
        // setup physics
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = boundaryCategory
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        self.physicsWorld.contactDelegate = self
        
        // setup background color
        self.backgroundColor = level.skyColor
        
        setupGround()
        
        setupSky()
        
        // setup bird
        let birdTexture1 = SKTexture(image: #imageLiteral(resourceName: "bird1.png"))
        birdTexture1.filteringMode = .nearest
        let birdTexture2 = SKTexture(image: #imageLiteral(resourceName: "bird2.png"))
        birdTexture2.filteringMode = .nearest
        let birdTexture3 = SKTexture(image: #imageLiteral(resourceName: "bird3.png"))
        birdTexture3.filteringMode = .nearest
        let birdTexture4 = SKTexture(image: #imageLiteral(resourceName: "bird4.png"))
        birdTexture4.filteringMode = .nearest

        
        let anim = SKAction.animate(with: [birdTexture1, birdTexture2, birdTexture3, birdTexture4], timePerFrame: 0.1)
        let flap = SKAction.repeatForever(anim)
        
        bird = SKSpriteNode(texture: birdTexture1, size: CGSize(width: 34, height: 24).applying(.init(scaleX: 1.3, y: 1.3)))
        bird.setScale(1.0)
        bird.position = CGPoint(x: self.frame.size.width * 0.35, y: self.frame.size.height * 0.6)
        bird.run(flap)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
//        print(bird.physicsBody?.mass)
        bird.physicsBody?.mass = 0.02
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.allowsRotation = false
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.contactTestBitMask = fatalLevelContentCategory
        bird.physicsBody?.fieldBitMask = fieldCategory
        
        self.addChild(bird)
        
        bird.speed = 0.0
        movingContent.speed = 0
        
        mainLabel.run(showAndHideMainLabel, withKey: showAndHideMainLabelActionKey)
        
        self.state = .initialized
        
    }
    
    /// Start/Restart the level.
    func startLevel(){
        self.state = .playing
        // Remove current level content
        levelContent.removeAllChildren()
        // Move bird to original position and reset velocity
        bird.position = CGPoint(x: self.frame.size.width * 0.35, y: self.frame.size.height * 0.6)
        bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        bird.physicsBody?.collisionBitMask = fatalLevelContentCategory | boundaryCategory
        bird.speed = 1.0
        bird.zRotation = 0.0
        bird.run(level.birdAction, withKey: "bird")
        // Start Gravity
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.0)
        // Run level content
        runMap()
        // Restart animation
        movingContent.speed = 1
        // Show level name
        showLevelName()
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
                self.levelContent.addChild(levelEndNode)
                MoveBy(x: -self.size.width - 20.0, y: 0.0, duration: TimeInterval(0.005 * (self.size.width + 20.0)))
                    .thenRemove()
                    .run(on: levelEndNode)
            })
            .run(on: self, withKey: "map")
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
            movingContent.addChild(sprite)
        }
        
        // create the ground
        let ground = SKNode()
        ground.position = CGPoint(x: 0, y: groundTexture.size().height)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: groundTexture.size().height * 2.0))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = fatalLevelContentCategory
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
            movingContent.addChild(sprite)
        }
    }
    
    // MARK: - Audio
    let playScoreSoundEffect = PlaySound(fileName: "sfx_point.wav", waitForCompletion: false).skAction
    let playHitSoundEffect = PlaySound(fileName: "sfx_hit.wav", waitForCompletion: false).skAction
    let playFlapSoundEffect = PlaySound(fileName: "sfx_wing.wav", waitForCompletion: false).skAction
    
    // MARK: - Touches
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if case .playing = self.state {
            for _ in touches {
                bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 7))
            }
            playFlapSoundEffect.run(on: self)
        } else if self.state == .initialized || self.state == .waitingForRestart {
            self.startLevel()
        }
        super.touchesBegan(touches, with: event)
    }
    
    public override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        let value = bird.physicsBody!.velocity.dy * ( bird.physicsBody!.velocity.dy < 0 ? 0.003 : 0.001 )
        bird.zRotation = min( max(-1, value), 0.5 )
    }
    
    public func didBegin(_ contact: SKPhysicsContact) {
        guard self.state == .playing else { return }
        
        if (contact.bodyA.categoryBitMask & levelEndCategory) == levelEndCategory || (contact.bodyB.categoryBitMask & levelEndCategory) == levelEndCategory {
            self.state = .finished
            // Finished!
            Actions(running: .sequentially) {
                Fade(.out, duration: 0.1)
                SKAction.run { [weak self] in
                    self?.mainLabel.text = "Congratulations! 👍"
                }
                Actions(running: .parallelly) {
                    Fade(.in, duration: 0.1)
                    Scale(to: 1.5, duration: 0.1)
                }
                Scale(to: 1.0, duration: 0.1)
                Scale(to: 1.5, duration: 0.1)
                Scale(to: 1.0, duration: 0.1)
                Wait(forDuration: 1)
                SKAction.run { [weak self] in
                    self?.finish(.success(true))
                }
            }.run(on: mainLabel)
        } else {
            // Dead
            self.state = .waitingForRestart
            
            Actions(running: .sequentially) {
                Fade(.out, duration: 0.1)
                SKAction.run { [weak self] in
                    guard let self = self, self.state == .waitingForRestart else { return }
                    self.mainLabel.text = "Click to Restart"
                    self.mainLabel.run(self.showAndHideMainLabel, withKey: self.showAndHideMainLabelActionKey)
                }
            }.run(on: mainLabel)
            
            movingContent.speed = 0
            self.removeAction(forKey: "map")
            
            bird.run(Rotate(by: .degrees(Double(bird.position.y) * 2), duration: 1)) { [weak self] in
                if case .waitingForRestart = self?.state {
                    self?.bird.speed = 0
                }
            }
            
            // Flash background if contact is detected
            Actions(running: .sequentially) {
                playHitSoundEffect
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
            }.run(on: self, withKey: "flash")
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
    
    // MARK: - Main Label
    lazy var mainLabel: SKLabelNode = {
        if let node = self.childNode(withName: "mainLabel") as? SKLabelNode {
            return node
        } else {
            print("mainLabel not found")
            fatalError()
        }
    }()
    
    let showAndHideMainLabel: Action = Actions(running: .sequentially) {
        Fade(.in, duration: 0.5)
        Wait(forDuration: 0.5)
        Fade(.out, duration: 0.5)
        Wait(forDuration: 0.5)
    }.repeatForever().skAction
    
    let showAndHideMainLabelActionKey = "showAndHide"
    
    func showLevelName() {
        mainLabel.removeAction(forKey: showAndHideMainLabelActionKey)
        Actions(running: .sequentially) {
            Fade(.out, duration: 0.2)
            SKAction.run { [weak mainLabel = self.mainLabel, levelName = self.level.name] in
                mainLabel?.text = levelName
            }
            Fade(.in, duration: 0.3)
            Wait(forDuration: 2)
            Fade(.out, duration: 0.7)
        }.run(on: mainLabel)
    }
    
    deinit {
        // Uncomment to debug
        // print("LevelScene: deinit")
    }
    
    
}

extension LevelScene {
    enum State {
        /// The state where the scene was moved to a view but is not yet started.
        case initialized
        case playing
        case waitingForRestart
        case finished
    }
}
