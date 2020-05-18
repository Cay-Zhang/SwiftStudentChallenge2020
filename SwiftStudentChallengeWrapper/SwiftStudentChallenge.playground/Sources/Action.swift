import SpriteKit
import SwiftUI

public protocol Action {
    var skAction: SKAction { get }
    func repeatForever() -> RepeatForever
    func then(_ action: Action) -> Action
    func thenRemove() -> Action
    func cached() -> Action
    func `repeat`(_ count: Int) -> Action
    func run(on node: SKNode) -> Void
    func run(on node: SKNode, onComplete completion: @escaping () -> Void) -> Void
    func run(on node: SKNode, withKey key: String) -> Void
}

public extension Action {
    func repeatForever() -> RepeatForever {
        RepeatForever(self)
    }
    
    func then(_ action: Action) -> Action {
        Actions(running: .sequentially) {
            self
            action
        }
    }
    
    func thenRemove() -> Action {
        Actions(running: .sequentially) {
            self
            Remove()
        }
    }
    
    func cached() -> Action {
        CachedAction(self)
    }
    
    func `repeat`(_ count: Int) -> Action {
        Repeat(count, action: self)
    }
    
    func run(on node: SKNode) -> Void {
        node.run(self)
    }
    
    func run(on node: SKNode, onComplete completion: @escaping () -> Void) -> Void {
        node.run(self, completion: completion)
    }
    
    func run(on node: SKNode, withKey key: String) -> Void {
        node.run(self, withKey: key)
    }
}

public struct MoveBy: Action {
    let deltaX: CGFloat
    let deltaY: CGFloat
    let duration: TimeInterval
    
    public init(x deltaX: CGFloat = 0, y deltaY: CGFloat = 0, duration: TimeInterval) {
        self.deltaX = deltaX
        self.deltaY = deltaY
        self.duration = duration
    }
    
    public var skAction: SKAction {
        SKAction.moveBy(x: deltaX, y: deltaY, duration: duration)
    }
}

public struct Wiggle: Action {
    let amplitudeX: CGFloat
    let amplitudeY: CGFloat
    let duration: TimeInterval
    
    public init(x amplitudeX: CGFloat, y amplitudeY: CGFloat, duration: TimeInterval) {
        self.amplitudeX = amplitudeX
        self.amplitudeY = amplitudeY
        self.duration = duration
    }
    
    public init(x amplitudeX: CGFloat, duration: TimeInterval) {
        self.amplitudeX = amplitudeX
        self.amplitudeY = 0
        self.duration = duration
    }
    
    public init(y amplitudeY: CGFloat, duration: TimeInterval) {
        self.amplitudeX = 0
        self.amplitudeY = amplitudeY
        self.duration = duration
    }
    
    public init(amplitude: CGFloat, duration: TimeInterval) {
        self.amplitudeX = amplitude
        self.amplitudeY = amplitude
        self.duration = duration
    }
    
    public var skAction: SKAction {
        let numberOfShakes = Int(duration / 0.08)
        var actions = [SKAction]()
        for _ in 0..<numberOfShakes {
            let moveX = CGFloat.random(in: -amplitudeX...amplitudeX)
            let moveY = CGFloat.random(in: -amplitudeY...amplitudeY)
            let shakeAction = SKAction.moveBy(x: moveX, y: moveY, duration: 0.02)
            shakeAction.timingMode = SKActionTimingMode.easeOut
            actions.append(shakeAction)
            actions.append(shakeAction.reversed())
        }
        return SKAction.sequence(actions)
    }
    
}

public struct PlaySound: Action {
    let fileName: String
    let waitForCompletion: Bool
    
    public init(fileName: String, waitForCompletion: Bool) {
        self.fileName = fileName
        self.waitForCompletion = waitForCompletion
    }
    
    public var skAction: SKAction {
        .playSoundFileNamed(fileName, waitForCompletion: waitForCompletion)
    }
}

public struct Rotate: Action {
    let angle: Angle
    let duration: TimeInterval
    
    public init(by angle: Angle, duration: TimeInterval) {
        self.angle = angle
        self.duration = duration
    }
    
    public var skAction: SKAction {
        .rotate(byAngle: CGFloat(angle.radians), duration: duration)
    }
}

public struct Scale: Action {
    let scale: CGFloat
    let duration: TimeInterval
    
    public init(to scale: CGFloat, duration: TimeInterval) {
        self.scale = scale
        self.duration = duration
    }
    
    public var skAction: SKAction {
        .scale(to: scale, duration: duration)
    }
}

public struct Fade: Action {
    public enum FadeOption {
        case `in`
        case out
    }
    
    let fadeOption: FadeOption
    let duration: TimeInterval
    
    public init(_ fadeOption: FadeOption, duration: TimeInterval) {
        self.fadeOption = fadeOption
        self.duration = duration
    }
    
    public var skAction: SKAction {
        switch fadeOption {
        case .in:
            return SKAction.fadeIn(withDuration: duration)
        case .out:
            return SKAction.fadeOut(withDuration: duration)
        }
    }
}

public struct Decolorize: Action {
    let duration: TimeInterval
    
    public init(duration: TimeInterval) {
        self.duration = duration
    }
    
    public var skAction: SKAction {
        .colorize(withColorBlendFactor: 0.0, duration: duration)
    }
}

public struct Colorize: Action {
    let color: UIColor
    let duration: TimeInterval
    let colorBlendFactor: CGFloat
    
    public init(_ color: UIColor, duration: TimeInterval, colorBlendFactor: CGFloat = 0.5) {
        self.color = color
        self.duration = duration
        self.colorBlendFactor = colorBlendFactor
    }
    
    public var skAction: SKAction {
        .colorize(with: color, colorBlendFactor: colorBlendFactor, duration: duration)
    }
}

public struct Wait: Action {
    let durationRange: ClosedRange<TimeInterval>
    
    public init(forDuration duration: TimeInterval) {
        self.durationRange = duration...duration
    }
    
    public init(forRandomDurationIn durationRange: ClosedRange<TimeInterval>) {
        self.durationRange = durationRange
    }
    
    public var skAction: SKAction {
        if durationRange.upperBound == durationRange.lowerBound {
            return SKAction.wait(forDuration: durationRange.upperBound)
        } else {
            let midpoint = (durationRange.upperBound + durationRange.lowerBound) / 2.0
            let range = durationRange.upperBound - durationRange.lowerBound
            return SKAction.wait(forDuration: midpoint, withRange: range)
        }
    }
    
}

public struct Actions: Action {
    
    public enum ExecutionMode {
        case sequentially, parallelly
    }
    
    var actions: [Action]
    let executionMode: ExecutionMode
    
    public init(running executionMode: ExecutionMode = .sequentially, _ actions: [Action]) {
        self.executionMode = executionMode
        self.actions = actions
    }
    
    public init(running executionMode: ExecutionMode, @ActionBuilder _ buildActions: () -> [Action]) {
        self.executionMode = executionMode
        self.actions = buildActions()
    }
    
    public init(running executionMode: ExecutionMode, @ActionBuilder _ buildActions: () -> Action) {
        self.executionMode = executionMode
        self.actions = [buildActions()]
    }
    
    public var skAction: SKAction {
        switch executionMode {
        case .sequentially:
            return SKAction.sequence(actions.map { $0.skAction })
        case .parallelly:
            return SKAction.group(actions.map { $0.skAction })
        }
    }
    
    public func thenRemove() -> Action {
        if executionMode == .sequentially {
            if actions.last is Remove {
                return self
            } else {
                var copy = self
                copy.actions.append(Remove())
                return copy
            }
        } else {
            return Actions(running: .sequentially) {
                self
                Remove()
            }
        }
    }
    
    public func then(_ action: Action) -> Action {
        if executionMode == .sequentially {
            var copy = self
            copy.actions.append(action)
            return copy
        } else {
            return Actions(running: .sequentially) {
                self
                action
            }
        }
    }
}

public struct Repeat: Action {
    var count: Int
    let action: Action
    
    init(_ count: Int, action: Action) {
        self.count = count
        self.action = action
    }
    
    public var skAction: SKAction {
        .repeat(action.skAction, count: count)
    }
    
    public func `repeat`(_ count: Int) -> Action {
        var copy = self
        copy.count *= count
        return copy
    }
}

public struct RepeatForever: Action {
    let action: Action
    public init(_ action: Action) {
        self.action = action
    }
    public var skAction: SKAction {
        SKAction.repeatForever(action.skAction)
    }
    public func repeatForever() -> RepeatForever { self }
    public func `repeat`(_ count: Int) -> Action { self }
    public func then(_ action: Action) -> Action { fatalError("Appending an action after RepeatForever.") }
}

public struct Remove: Action {
    public init() { }
    public var skAction: SKAction {
        SKAction.removeFromParent()
    }
    public func thenRemove() -> Action { self }
}

public struct CachedAction: Action {
    public var skAction: SKAction
    public init(_ action: Action) {
        self.skAction = action.skAction
    }
    public init(_ action: SKAction) {
        self.skAction = action
    }
    public func cached() -> Action { self }
}

extension SKNode {
    func run(_ action: Action, completion block: @escaping () -> Void = { }) {
        run(action.skAction, completion: block)
    }
    
    func run(_ action: SKAction?, completion block: @escaping () -> Void = { }) {
        if let action = action {
            run(action, completion: block)
        }
    }
    
    func run(_ action: SKAction?, withKey key: String) {
        if let action = action {
            run(action, withKey: key)
        }
    }
    
    func run(_ action: Action?, withKey key: String) {
        if let action = action {
            run(action.skAction, withKey: key)
        }
    }
}

extension SKAction: Action {
    public var skAction: SKAction { self }
}
