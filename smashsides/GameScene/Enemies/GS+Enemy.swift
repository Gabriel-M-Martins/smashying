//
//  GameScene+EnemyA.swift
//  smashsides
//
//  Created by Gabriel Medeiros Martins on 30/11/24.
//

import Foundation
import SpriteKit

extension GameScene {
    func setupEnemySpawn() {
        $tick.sink { [weak self] tick in
            // TODO: Rules for spawning enemies
//            if tick > 2 && tick % 2 == 0 {
//            }
            self?.spawnEnemies()
        }
        .store(in: &cancellables)
    }
    
    func spawnEnemies() {
        guard let view = self.view else { return }
        let enemy = EnemyNode(side: .random(), view: view.frame.size)
        
        enemy.run(
            .sequence([
                .moveTo(x: 0, duration: 5),
                .run { [weak self] in
                    guard let idx = self?.enemies.firstIndex(of: enemy) else { return }
                    self?.enemies.remove(at: idx)
                },
                .removeFromParent()
            ])//,
//            withKey: Self.moveAnimationKey
        )
        
        enemies.append(enemy)
        addChild(enemy)
    }
}
