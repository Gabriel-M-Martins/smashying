import Foundation

enum Origin {
    case Left, Right
    
    static func random() -> Self {
        [Self.Left, Self.Right].randomElement()!
    }
}
