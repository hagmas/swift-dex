import Foundation

extension Character {
    init(int: Int) {
        self = Character(Unicode.Scalar(UInt8(65 + int % 26)))
    }
}
