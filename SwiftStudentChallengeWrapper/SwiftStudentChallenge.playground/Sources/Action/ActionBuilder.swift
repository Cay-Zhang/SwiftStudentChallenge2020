import SwiftUI
import SpriteKit

/// A custom parameter attribute that constructs paths from closures.
@_functionBuilder
public struct ActionBuilder {
    public static func buildBlock(_ actions: Action?...) -> [Action] {
        return actions.compactMap { $0 }
    }
    
    public static func buildBlock(_ actions: Action...) -> [Action] {
        return actions
    }
}
