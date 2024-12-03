//
//  Physics.swift
//  smashsides
//
//  Created by Gabriel Medeiros Martins on 30/11/24.
//

import Foundation

enum PhysicsCategory {
    static let none: UInt32 = 0x1 << 0
    static let all: UInt32 = .max
    static let player: UInt32 = 0x1 << 1
    static let enemies: UInt32 = 0x1 << 2
    static let zoneA: UInt32 = 0x1 << 3
    static let zoneB: UInt32 = 0x1 << 4
    static let zoneC: UInt32 = 0x1 << 5
}
