import Combine
import Foundation

class EventDispatcher: ObservableObject {
    let forward: PassthroughSubject<Void, Never> = .init()
}
