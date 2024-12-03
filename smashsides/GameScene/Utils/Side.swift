//
//  Origin.swift
//  smashsides
//
//  Created by Gabriel Medeiros Martins on 30/11/24.
//

import Foundation

enum Side {
    case Left, Right
    
    static func random() -> Self {
        [Self.Left, Self.Right].randomElement()!
    }
}
