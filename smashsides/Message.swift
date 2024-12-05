//
//  Message 2.swift
//  smashsides
//
//  Created by Gabriel Medeiros Martins on 04/12/24.
//

import Foundation
import SwiftUI

struct Message {
    enum Intensity {
        case Ok, WoW, Amazing, Excellent, Error
        
        func stars() -> Int {
            switch self {
            case .Ok:
                return 0
            case .WoW:
                return 1
            case .Amazing:
                return 2
            case .Excellent:
                return 3
            case .Error:
                return 0
            }
        }
        
        func gradient() -> Gradient {
            switch self {
            case .Ok, .WoW, .Amazing:
                return .init(colors: [.init("Stars/YELLOW_1"), .init("Stars/YELLOW_2")])
            case .Excellent:
                return .init(colors: [.init("Stars/PURPLE_1"), .init("Stars/PURPLE_2")])
            case .Error:
                return .init(colors: [])
            }
        }
        
        func glow() -> Color {
            switch self {
            case .Ok, .WoW, .Amazing:
                return .init("Stars/PURPLE_1")
            case .Excellent:
                return .init("Stars/YELLOW_1")
            case .Error:
                return .init("")
            }
        }
    }
    
    let id: UUID = .init()
    var point: CGPoint
    var rotation: CGFloat
    var scale: CGFloat
    var text: String
    var color: Color
    var opacity: CGFloat
    var intensity: Intensity
    
    init(point: CGPoint, rotation: CGFloat, text: String, color: Color, intensity: Intensity) {
        self.point = point
        self.rotation = rotation
        self.scale = 0
        self.text = text
        self.color = color
        self.opacity = 1
        self.intensity = intensity
    }
}
