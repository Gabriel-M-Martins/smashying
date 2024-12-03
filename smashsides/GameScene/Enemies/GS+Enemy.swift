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
        $gametick.sink { [weak self] tick in
            if tick == 0 { return }
            guard let self else { return }
            
            if tick == 1 {
                self.spawnEnemies()
                return
            }
            
            if tick % enemySpawnTickInterval == 0 {
                self.spawnEnemies()
            }
            
            if tick % enemyAccelerationTickInterval == 0 && enemySpawnTickInterval >= 5 {
                enemySpawnTickInterval -= 1
                enemyAccelerationTickInterval -= 1
                if enemySpeed < 250 {
                    enemySpeed += 2
                    
                    enemies.forEach { [weak self] enemy in
                        guard let self else { return }
                        
                        let path = CGMutablePath()
                        path.move(to: enemy.position)
                        path.addLine(to: .init(x: 0, y: enemy.position.y))
                        
                        enemy.run(
                            .follow(path, asOffset: false, orientToPath: false, speed: enemySpeed)
                        )
                    }
                }
            }
        }
        .store(in: &cancellables)
    }
    
    func spawnEnemies() {
        guard let view = self.view else { return }
        let enemy = EnemyNode(side: .random(), view: view.frame.size)
        
        let path = CGMutablePath()
        path.move(to: enemy.position)
        path.addLine(to: .init(x: 0, y: enemy.position.y))
        
        enemy.run(
            .follow(path, asOffset: false, orientToPath: false, speed: enemySpeed)
        )
        
        enemies.append(enemy)
        addChild(enemy)
    }
}
