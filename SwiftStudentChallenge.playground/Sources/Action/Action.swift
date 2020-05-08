import SpriteKit

public protocol Action {
    var skAction: SKAction { get }
    func repeatForever() -> RepeatForever
}

public extension Action {
    func repeatForever() -> RepeatForever {
        RepeatForever(self)
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
    
    let actions: [Action]
    let executionMode: ExecutionMode
    
    public init(running executionMode: ExecutionMode, _ actions: [Action]) {
        self.executionMode = executionMode
        self.actions = actions
    }
    
    public init(running executionMode: ExecutionMode, @ActionBuilder _ buildActions: () -> [Action]) {
        self.executionMode = executionMode
        self.actions = buildActions()
    }
    
    public var skAction: SKAction {
        switch executionMode {
        case .sequentially:
            return SKAction.sequence(actions.map { $0.skAction })
        case .parallelly:
            return SKAction.group(actions.map { $0.skAction })
        }
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
}

public extension SKNode {
    func run(_ action: Action, completion block: @escaping () -> Void = { }) {
        run(action.skAction, completion: block)
    }
}
