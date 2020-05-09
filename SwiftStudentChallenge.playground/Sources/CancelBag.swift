import Combine

public class CancelBag {
    public var cancellables = Set<AnyCancellable>()
    public init() { }
}

extension AnyCancellable {
    public func store(in cancelBag: CancelBag) {
        self.store(in: &cancelBag.cancellables)
    }
}
