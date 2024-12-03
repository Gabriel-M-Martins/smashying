//
//  GS+Physics.swift
//  smashsides
//
//  Created by Gabriel Medeiros Martins on 30/11/24.
//

import Foundation
import SpriteKit

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        let contactMask = bodyA.categoryBitMask | bodyB.categoryBitMask
        
        if contactMask == (PhysicsCategory.enemies | PhysicsCategory.player) {
            guard let enemy = (bodyA.node as? EnemyNode) ?? (bodyB.node as? EnemyNode) else { return }
            
            if let idx = enemies.firstIndex(of: enemy) {
                enemies.remove(at: idx)
            }
            
            enemy.physicsBody = nil
            
            enemy.removeAllActions()
            enemy.run(
                .sequence([
                    .group([
                        .move(by: .init(dx: enemy.size.width/2 * (enemy.side == .Left ? -1 : 1), dy: 0), duration: 0.3),
                        .scale(to: 1.5, duration: 0.3),
                        .fadeOut(withDuration: 0.3)
                    ]),
                    .removeFromParent()
                ])
            )
            
            hitstaken += 1
        }
    }
}
