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
                self.spawnEnemy()
                return
            }
            
            if tick % enemySpawnTickInterval == 0 {
                self.spawnEnemy()
            }
            
            if tick % (enemyAccelerationTickInterval * (enemySpawnTickInterval >= enemyAccelerationTickInterval/2 ? 1 : 2)) == 0 && .random() {
                if enemySpawnTickInterval >= 8  && .random(){
                    enemySpawnTickInterval -= 1
                }

                enemySpeed += .random(in: 1...5)
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
        .store(in: &cancellables)
    }
    
    func spawnEnemy() {
        guard let view = self.view else { return }
        
        let orientation = Orientation.random()
        
        if Int.random(in: 1...10) <= 4 && gametick >= 60 {
            let enemy = EnemyNode(side: .random(), orientation: orientation, view: view.frame.size)
            
            let path = CGMutablePath()
            path.move(to: enemy.position)
            path.addLine(to: .init(x: 0, y: enemy.position.y))
            
            enemy.run(
                .follow(path, asOffset: false, orientToPath: false, speed: enemySpeed)
            )
            
            enemies.append(enemy)
            addChild(enemy)
        }
        
        let enemy = EnemyNode(side: .random(), orientation: orientation, view: view.frame.size)
        
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
