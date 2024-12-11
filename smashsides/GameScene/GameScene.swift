//
//  GameScene.swift
//  smashsides
//
//  Created by Gabriel Medeiros Martins on 29/11/24.
//

import SwiftUI
import SpriteKit
import GameplayKit
import Combine

struct Settings {
    var enemySpawnTickInterval: Int
    var enemyAccelerationTickInterval: Int
    var enemySpeed: CGFloat
    
    static let standard: Settings = .init(
        enemySpawnTickInterval: 20,
        enemyAccelerationTickInterval: 40,
        enemySpeed: 120
    )
}

class GameScene: SKScene, ObservableObject {
    var cameraNode: SKCameraNode = SKCameraNode()
    
    var elapsedTime: TimeInterval = 0
    var elapsedGameTime: TimeInterval = 0
    
    var cancellables: Set<AnyCancellable> = []
    
    var zonesA: Set<SKNode> = []
    var zonesB: Set<SKNode> = []
    var zonesC: Set<SKNode> = []
    
    var enemies: [EnemyNode] = []
    
    @Published var gamemode: GameMode = .Hittable(hits: 1)
    @Published var countdown: Int? = nil
    @Published var hitstaken: Int = 0
    @Published var timetick: Int = 0
    @Published var gametick: Int = 0
    @Published var score: Int = 0
    @Published var hasEnded: Bool = false
    @Published var isScenePaused: Bool = false
    @Published var sequence: Int = 0
    @Published var missedHits: Int = 0
    @Published var enemiesSmashed: Int = 0
    
    @Published var settings: Settings = .standard
    
//    var enemySpawnTickInterval: Int = 20
//    var enemyAccelerationTickInterval: Int = 35
//    var enemySpeed: CGFloat = 95
    
    @Published var canStart: Bool = false
    
    override var isPaused: Bool {
        didSet {
            withAnimation {
                isScenePaused = isPaused
            }
        }
    }
    
    var gamedelegate: (any GameDelegate)? = nil
    
    convenience init(mode: GameMode, delegate: (any GameDelegate)? = nil) {
        self.init()
        self.gamemode = mode
        self.gamedelegate = gamedelegate
    }
    
    override func didMove(to view: SKView) {
        setup(view)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if hasEnded || isPaused { return }
        
        if !canStart {
            elapsedTime = currentTime
            elapsedGameTime = currentTime
            
            return
        }
        
        if currentTime - elapsedGameTime >= 0.05 {
            gametick += 1
            elapsedGameTime += currentTime - elapsedGameTime
        }
        
        if currentTime - elapsedTime >= 1 {
            timetick += 1
            elapsedTime = currentTime
        }
    }
    
    func onSmashButtonClick(side: Side, orientation: Orientation) -> Bool {
        guard let enemyIdx = enemies.firstIndex(where: { $0.side == side }) else { return false }
        
        let enemy = enemies[enemyIdx]
        var isInSmashableArea = false
        
        var zone = Zone.A
        var points = 0
        
        if zonesC.contains(where: { $0.contains(enemy.position) }) {
            zone = .C
            points = 1
            isInSmashableArea = true
        } else if zonesB.contains(where: { $0.contains(enemy.position) }) {
            zone = .B
            points = 5
            isInSmashableArea = true
        } else if zonesA.contains(where: { $0.contains(enemy.position) }) {
            points = 1
            isInSmashableArea = true
        }
        
        let smashed = isInSmashableArea && enemy.orientation == orientation
        
        if smashed {
            enemies.remove(at: enemyIdx)
            enemy.removeAllActions()
            let time: CGFloat = 0.25
            enemy.run(
                .sequence([
                    .group([
                        .scale(to: 0, duration: time),
                        .moveTo(y: enemy.position.y + enemy.frame.height * 4, duration: time),
                        .rotate(byAngle: .pi * 10, duration: time)
                    ]),
                    .removeFromParent()
                ])
            )
                        
            if zone == .B {
                withAnimation {
                    sequence += 1
                }
            } else {
                withAnimation {
                    sequence = 0
                }
            }

            points *= max(sequence, 1)
            withAnimation {
                score += points
                enemiesSmashed += 1
            }
            
            gamedelegate?.smashedEnemy(at: self.convertPoint(toView: enemy.position), points: points, zone: zone)
        } else {
            withAnimation {
                sequence = 0
                missedHits += 1
            }
        }
        
        return smashed
    }
    
    func reset() {
        guard let view else { return }
        setup(view)
    }
    
    private func setup(_ view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = .zero
        
        isPaused = true

        canStart = false

        self.removeAllChildren()
        cancellables.removeAll()
        
        timetick = 0
        gametick = 0
        score = 0
        sequence = 0
        enemiesSmashed = 0
        hitstaken = 0
        settings = .standard
        
        setupGround(view)
        setupPlayer(view)
        setupCamera()
        setupEnemySpawn()
        setupZones(view)
        setupMode()
        setupSequenceCounter()
        
        enemies = []

        hasEnded = false
        isPaused = false
    }
    
    private func setupSequenceCounter() {
        $hitstaken.sink { [weak self] hit in
            if hit != 0 {
                self?.sequence = 0
            }
        }
        .store(in: &cancellables)
    }
    
    private func setupMode() {
        switch gamemode {
        case .Timed(let seconds):
            countdown = seconds
            $timetick.sink { [weak self] tick in
                if tick == 0 { return }
                guard let self, var countdown else { return }
                countdown -= 1
                self.countdown = countdown
                
                if countdown <= 0 {
                    self.isPaused = true
                    self.hasEnded = true
                }
            }
            .store(in: &cancellables)
        case .Hittable(let hits):
            $hitstaken.sink { hit in
                if hit >= hits {
                    self.isPaused = true
                    self.hasEnded = true
                }
            }
            .store(in: &cancellables)
        }
    }
    
    private func setupZones(_ view: SKView) {
        let multiplier: CGFloat = 3
        
        let zoneAWidth = view.frame.width * 0.04 * multiplier
        let zoneBWidth = view.frame.height * 0.05 * multiplier
        let zoneCWidth = view.frame.width * 0.02 * multiplier
        
        let opacity: CGFloat = 0.05
        let glowWidth: CGFloat = 1
        let lineWidth: CGFloat = 0.1
        
        // MARK: Left zones
        let zoneAL = SKShapeNode(rectOf: .init(width: zoneAWidth, height: view.frame.height))
        zoneAL.position.x -= zoneAL.frame.width/2 + view.frame.height * 0.025
        zoneAL.strokeColor = .clear
        
        zoneAL.physicsBody = .init()
        zoneAL.physicsBody?.categoryBitMask = PhysicsCategory.zoneA
        zoneAL.physicsBody?.contactTestBitMask = PhysicsCategory.enemies
        zoneAL.physicsBody?.collisionBitMask = PhysicsCategory.none
        zoneAL.physicsBody?.affectedByGravity = false
        
        self.addChild(zoneAL)
        
        let zoneBL = SKShapeNode(rectOf: .init(width: zoneBWidth, height: view.frame.height * 2))
        zoneBL.position.x -= zoneBL.frame.width/2 + zoneAL.frame.width * 0.95 + view.frame.height * 0.025
        zoneBL.strokeColor = .green
        zoneBL.fillColor = .green.withAlphaComponent(opacity)
        zoneBL.glowWidth = glowWidth
        zoneBL.lineWidth = lineWidth
        
        let indicatorL = SKShapeNode(rectOf: .init(width: zoneBWidth, height: view.frame.height * 0.1))
        indicatorL.position.x = zoneBL.position.x
        indicatorL.position.y = -indicatorL.frame.height/2
        indicatorL.zPosition = Layers.indicators
        
        indicatorL.fillColor = .green
        indicatorL.strokeColor = .green
        
        self.addChild(indicatorL)
        
        zoneBL.physicsBody = .init()
        zoneBL.physicsBody?.categoryBitMask = PhysicsCategory.zoneB
        zoneBL.physicsBody?.contactTestBitMask = PhysicsCategory.enemies
        zoneBL.physicsBody?.collisionBitMask = PhysicsCategory.none
        zoneBL.physicsBody?.affectedByGravity = false
        
        self.addChild(zoneBL)
        
        let zoneCL = SKShapeNode(rectOf: .init(width: zoneCWidth, height: view.frame.height))
        zoneCL.position.x -= zoneCL.frame.width/2 + zoneBL.frame.width * 0.95 + zoneAL.frame.width * 0.95 + view.frame.height * 0.025
        zoneCL.strokeColor = .clear
        
        zoneCL.physicsBody = .init()
        zoneCL.physicsBody?.categoryBitMask = PhysicsCategory.zoneC
        zoneCL.physicsBody?.contactTestBitMask = PhysicsCategory.enemies
        zoneCL.physicsBody?.collisionBitMask = PhysicsCategory.none
        zoneCL.physicsBody?.affectedByGravity = false
        
        self.addChild(zoneCL)
        
        // MARK: Right zones
        let zoneAR = SKShapeNode(rectOf: .init(width: zoneAWidth, height: view.frame.height))
        zoneAR.position.x += zoneAR.frame.width/2 + view.frame.height * 0.025
        zoneAR.strokeColor = .clear
        
        zoneAR.physicsBody = .init()
        zoneAR.physicsBody?.categoryBitMask = PhysicsCategory.zoneA
        zoneAR.physicsBody?.contactTestBitMask = PhysicsCategory.enemies
        zoneAR.physicsBody?.collisionBitMask = PhysicsCategory.none
        zoneAR.physicsBody?.affectedByGravity = false
        
        self.addChild(zoneAR)
        
        let zoneBR = SKShapeNode(rectOf: .init(width: zoneBWidth, height: view.frame.height * 2))
        zoneBR.position.x += zoneBR.frame.width/2 + zoneAR.frame.width * 0.95 + view.frame.height * 0.025
        zoneBR.strokeColor = .green
        zoneBR.fillColor = .green.withAlphaComponent(opacity)
        zoneBR.glowWidth = glowWidth
        zoneBR.lineWidth = lineWidth
        
        let indicatorR = SKShapeNode(rectOf: .init(width: zoneBWidth, height: view.frame.height * 0.1))
        indicatorR.position.x = zoneBR.position.x
        indicatorR.position.y = -indicatorR.frame.height/2
        indicatorR.zPosition = Layers.indicators
        
        indicatorR.fillColor = .green
        indicatorR.strokeColor = .green
        
        self.addChild(indicatorR)
        
        zoneBR.physicsBody = .init()
        zoneBR.physicsBody?.categoryBitMask = PhysicsCategory.zoneB
        zoneBR.physicsBody?.contactTestBitMask = PhysicsCategory.enemies
        zoneBR.physicsBody?.collisionBitMask = PhysicsCategory.none
        zoneBR.physicsBody?.affectedByGravity = false
        zoneBR.physicsBody?.affectedByGravity = false
        
        self.addChild(zoneBR)
        
        let zoneCR = SKShapeNode(rectOf: .init(width: zoneCWidth, height: view.frame.height))
        zoneCR.position.x += zoneCR.frame.width/2 + zoneBR.frame.width * 0.95 + zoneAR.frame.width * 0.95 + view.frame.height * 0.025
        zoneCR.strokeColor = .clear
        
        zoneCR.physicsBody = .init()
        zoneCR.physicsBody?.categoryBitMask = PhysicsCategory.zoneC
        zoneCR.physicsBody?.contactTestBitMask = PhysicsCategory.enemies
        zoneCR.physicsBody?.collisionBitMask = PhysicsCategory.none
        zoneCR.physicsBody?.affectedByGravity = false
        
        self.addChild(zoneCR)
        
        zonesA = [zoneAL, zoneAR]
        zonesB = [zoneBL, zoneBR]
        zonesC = [zoneCL, zoneCR]
        
//        gamedelegate?.spawnZonesIndicators([
//            (Zone.A, self.convertPoint(toView: zoneAL.position), zoneAL.frame.width),
//            (Zone.A, self.convertPoint(toView: zoneAR.position), zoneAR.frame.width),
//            (Zone.B, self.convertPoint(toView: zoneBL.position), zoneBL.frame.width),
//            (Zone.B, self.convertPoint(toView: zoneBR.position), zoneBR.frame.width),
//            (Zone.C, self.convertPoint(toView: zoneCL.position), zoneCL.frame.width),
//            (Zone.C, self.convertPoint(toView: zoneCR.position), zoneCR.frame.width),
//        ])
    }
    
    private func setupCamera() {
        self.addChild(cameraNode)
        self.camera = cameraNode
        setupCameraShake()
    }
    
    private func setupCameraShake() {
        $hitstaken.sink { [weak self] hit in
            if hit == 0 { return }
            
            guard let self else { return }
            
            var shakeActions: [SKAction] = []
            for _ in 0..<Int.random(in: 5...10) {
                let randX = cameraNode.position.x + .random(in: -5...5)
                let randY = cameraNode.position.y + .random(in: -5...5)
                
                shakeActions.append(.move(to: .init(x: randX, y: randY), duration: 0.05))
            }
            
            shakeActions.append(.move(to: cameraNode.position, duration: 0.05))
            cameraNode.run(.sequence(shakeActions))
        }
        .store(in: &cancellables)
        
        $missedHits.sink { [weak self] hit in
            if hit <= 0 { return }
            
            guard let self else { return }
            
            var shakeActions: [SKAction] = []
            for _ in 0..<Int.random(in: 5...10) {
                let randX = cameraNode.position.x + .random(in: -5...5)
                let randY = cameraNode.position.y + .random(in: -5...5)
                
                shakeActions.append(.move(to: .init(x: randX, y: randY), duration: 0.05))
            }
            
            shakeActions.append(.move(to: cameraNode.position, duration: 0.05))
            cameraNode.run(.sequence(shakeActions))
        }
        .store(in: &cancellables)
    }
    
    private func setupPlayer(_ view: SKView) {
        let size = view.frame.height * 0.05
        let player = SKShapeNode(rectOf: .init(width: size, height: size * 2))
        
        player.strokeColor = .black
        player.fillColor = .black
        
        player.position.y += player.frame.height * 0.4
        player.zPosition = Layers.player
        
        let pb = SKPhysicsBody(rectangleOf: player.frame.size)
        pb.categoryBitMask = PhysicsCategory.player
        pb.contactTestBitMask = PhysicsCategory.enemies
        pb.collisionBitMask = PhysicsCategory.enemies
        pb.affectedByGravity = false
        pb.isDynamic = false
        
        player.physicsBody = pb
        
        self.addChild(player)
    }
    
    private func setupGround(_ view: SKView) {
        let ground = SKShapeNode(rectOf: .init(width: view.frame.width * 1.5, height: view.frame.height))
        
        ground.fillColor = .black
        ground.strokeColor = .black
        
        ground.position.y -= ground.frame.height/2
        ground.zPosition = Layers.ground
        
        self.addChild(ground)
    }
}
