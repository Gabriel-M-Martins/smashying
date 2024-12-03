//
//  Zone.swift
//  smashsides
//
//  Created by Gabriel Medeiros Martins on 30/11/24.
//


enum Zone {
    case A, B, C
}

extension Zone {
    func message() -> String {
        switch self {
        case .A:
            return "Too late!"
        case .B:
            return "WOW"
        case .C:
            return "A bit soon..."
        }
    }
}
