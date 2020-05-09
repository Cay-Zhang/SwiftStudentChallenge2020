import SpriteKit
import Combine

public struct Level {
    
    public init(name: String) {
        self.name = name
    }
    public var name = ""
    
    public func run() -> Future<Bool, Never> {
        Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                promise(.success(true))
            }
        }
    }
    
}
