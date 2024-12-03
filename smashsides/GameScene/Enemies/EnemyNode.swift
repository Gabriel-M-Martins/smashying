//
//  EnemyA.swift
//  smashsides
//
//  Created by Gabriel Medeiros Martins on 30/11/24.
//

import Foundation
import SpriteKit

class EnemyNode: SKSpriteNode {
    static let moveAnimationKey: String = "move"
    
    let side: Side
    
    init(side: Side, view: CGSize) {
        self.side = side
        let size = view.height * 0.05
        super.init(texture: nil, color: .red, size: .init(width: size, height: size))
        
        let pb = SKPhysicsBody(rectangleOf: .init(width: size, height: size))
        pb.allowsRotation = false
        pb.affectedByGravity = false
        
        pb.categoryBitMask = PhysicsCategory.enemies
        pb.contactTestBitMask = PhysicsCategory.zoneA + PhysicsCategory.zoneB + PhysicsCategory.zoneC
        pb.collisionBitMask = PhysicsCategory.player + PhysicsCategory.enemies

        self.physicsBody = pb

        self.position.y += size * 0.4
        self.zPosition = Layers.enemies
        
        let sideCorrector: CGFloat = side == .Left ? -1 : 1
        self.position.x += (size + view.width/2) * sideCorrector
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
