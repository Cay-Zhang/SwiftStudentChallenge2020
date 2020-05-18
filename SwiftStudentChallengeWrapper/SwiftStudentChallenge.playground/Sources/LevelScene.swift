import Foundation
import SpriteKit
import PlaygroundSupport

public class LevelScene: SKScene, SKPhysicsContactDelegate{
    
    var state: State?
    
    var level: Level!
    
    var bird: SKSpriteNode!
 
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

        
        let textureAnimation = SKAction.animate(with: [birdTexture1, birdTexture2, birdTexture3, birdTexture4], timePerFrame: 0.1).repeatForever().skAction
        
        bird = SKSpriteNode(texture: birdTexture1, size: CGSize(width: 34, height: 24).applying(.init(scaleX: 1.25, y: 1.25)))
        bird.position = CGPoint(x: self.frame.size.width * 0.35, y: self.frame.size.height * 0.6)
        bird.run(textureAnimation)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
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
    lazy var ground: SKSpriteNode = self.childNode(withName: "ground") as! SKSpriteNode
    lazy var groundHeight: CGFloat = self.ground.size.height
    lazy var heightAboveGround: CGFloat = self.size.height - self.groundHeight
    
    // MARK: - Sky
    func setupSky() {
        let skyTexture = SKTexture(image: #imageLiteral(resourceName: "sky.png"))
        let skySize = skyTexture.size().applying(.init(scaleX: 1.072, y: 1.072))
        
        let action =
            MoveBy(x: -skySize.width, y: 0, duration: Double(skySize.width) / 20.0)
                .then(MoveBy(x: skySize.width, y: 0, duration: 0.0))
                .repeatForever()

        for i in 0 ..< 2 + Int(self.size.width / (skySize.width)) {
            let i = CGFloat(i)
            let sprite = SKSpriteNode(texture: skyTexture, color: level.skyTint, size: skySize)
            sprite.colorBlendFactor = 0.3
            sprite.anchorPoint = .init(x: 0, y: 0)
            sprite.zPosition = -20
            sprite.position = CGPoint(x: i * skySize.width, y: 0)
            sprite.run(action)
            movingContent.addChild(sprite)
        }
    }
    
    // MARK: - Audio
    let playHitSoundEffect = PlaySound(fileName: "sfx_hit.wav", waitForCompletion: false).skAction
    
    // MARK: - Touches, Updates & Contacts
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if case .playing = self.state {
            for _ in touches {
                bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 7))
            }
        } else if self.state == .initialized || self.state == .waitingForRestart {
            self.startLevel()
        }
        super.touchesBegan(touches, with: event)
    }
    
    public override func update(_ currentTime: TimeInterval) {
        if let v_y = bird.physicsBody?.velocity.dy {
            bird.zRotation = min(max(-1.0, v_y * (v_y < 0 ? 0.003 : 0.001)), 0.5)
        }
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
            
            // Flash background
            Actions(running: .sequentially) {
                playHitSoundEffect
                Actions(running: .sequentially) {
                    Colorize(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), duration: 0.05, colorBlendFactor: 0.5)
                    Decolorize(duration: 0.05)
                }.repeat(4)
            }.run(on: bird, withKey: "flash")
        }
        
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
