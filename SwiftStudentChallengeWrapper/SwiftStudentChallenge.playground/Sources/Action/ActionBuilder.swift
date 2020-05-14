import SwiftUI
import SpriteKit

/// A custom parameter attribute that constructs paths from closures.
@_functionBuilder
public struct ActionBuilder {
    
    public static func buildBlock(_ action: Action) -> [Action] {
        return [action]
    }

    public static func buildBlock(_ action: Action?) -> [Action] {
        return action.map { [$0] } ?? []
    }

    public static func buildBlock(_ actions: Action?...) -> [Action] {
        return actions.compactMap { $0 }
    }
    
    public static func buildBlock(_ actions: Action...) -> [Action] {
        return actions
    }
    
    /// Provides support for “if” statements in multi-statement closures, producing an optional path component that is added only when the condition evaluates to true.
    public static func buildIf(_ action: Action?) -> Action? {
        return action
    }
    
    public static func buildOptional(_ action: Action?) -> Action? {
        return action
    }
    
    public static func buildEither(first: Action) -> Action {
        return first
    }

    public static func buildEither(second: Action) -> Action {
        return second
    }
}
