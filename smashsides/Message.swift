//
//  Message 2.swift
//  smashsides
//
//  Created by Gabriel Medeiros Martins on 04/12/24.
//

import Foundation
import SwiftUI

struct Message {
    let id: UUID = .init()
    var point: CGPoint
    var rotation: CGFloat
    var scale: CGFloat
    var text: String
    var color: Color
    var opacity: CGFloat
    
    init(point: CGPoint, rotation: CGFloat, text: String, color: Color) {
        self.point = point
        self.rotation = rotation
        self.scale = 0
        self.text = text
        self.color = color
        self.opacity = 1
    }
}
