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
            
            if tick % settings.enemySpawnTickInterval == 0 {
                self.spawnEnemy()
            }
            
            if tick % settings.enemyAccelerationTickInterval == 0 && .random() {
                if settings.enemySpawnTickInterval >= 9  && .random(){
                    settings.enemySpawnTickInterval -= 1
                    if .random() {
                        settings.enemySpawnTickInterval -= 1
                    }
                }

                settings.enemySpeed += .random(in: 3...6)
                enemies.forEach { [weak self] enemy in
                    guard let self else { return }
                    
                    let path = CGMutablePath()
                    path.move(to: enemy.position)
                    path.addLine(to: .init(x: 0, y: enemy.position.y))
                    
                    enemy.run(
                        .follow(path, asOffset: false, orientToPath: false, speed: settings.enemySpeed)
                    )
                }
            }
        }
        .store(in: &cancellables)
    }
    
    func spawnEnemy() {
        guard let view = self.view else { return }
        
        let orientation = Orientation.random()
        let side = Side.random()
        
        if Float.random(in: 0...1) <= 0.4 && timetick >= 20 {
            let side2 = Side.random()
            let enemy = EnemyNode(side: side2, orientation: side2 == side ? orientation : .random(), view: view.frame.size)
            
            let path = CGMutablePath()
            path.move(to: enemy.position)
            path.addLine(to: .init(x: 0, y: enemy.position.y))
            
            enemy.run(
                .follow(path, asOffset: false, orientToPath: false, speed: settings.enemySpeed)
            )
            
            enemies.append(enemy)
            addChild(enemy)
        }
        
        let enemy = EnemyNode(side: side, orientation: orientation, view: view.frame.size)
        
        let path = CGMutablePath()
        path.move(to: enemy.position)
        path.addLine(to: .init(x: 0, y: enemy.position.y))
        
        enemy.run(
            .follow(path, asOffset: false, orientToPath: false, speed: settings.enemySpeed)
        )
        
        enemies.append(enemy)
        addChild(enemy)
    }
}
