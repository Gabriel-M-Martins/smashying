//
//  EnemyA.swift
//  smashsides
//
//  Created by Gabriel Medeiros Martins on 30/11/24.
//

import Foundation
import SpriteKit

enum Orientation {
    case Up, Down
    
    static func random() -> Self {
        [.Up, .Down].randomElement()!
    }
    
    private static var textures: [Orientation : SKTexture] = [:]
    
    func texture() -> SKTexture {
        if let texture = Self.textures[self] {
            return texture
        }
        
        switch self {
        case .Up:
            let texture = SKTexture.init(imageNamed: "UP")
            Self.textures[.Up] = texture
            return texture
        case .Down:
            let texture = SKTexture.init(imageNamed: "DOWN")
            Self.textures[.Down] = texture
            return texture
        }
    }
}

class EnemyNode: SKSpriteNode {
    static let moveAnimationKey: String = "move"
    
    let side: Side
    let orientation: Orientation
    
    init(side: Side, orientation: Orientation, view: CGSize) {
        self.side = side
        self.orientation = orientation
        
        let targetSize = view.height * 0.075
        let texture = orientation.texture()
        
        let textureSize = texture.size()
        let scale = targetSize / textureSize.width
        
        let width = textureSize.width * scale
        let height = textureSize.height * scale
        
        super.init(texture: texture, color: .red, size: .init(width: width, height: height))
        
        let pb = SKPhysicsBody(rectangleOf: .init(width: width, height: height))
        pb.allowsRotation = false
        pb.affectedByGravity = false
        
        pb.categoryBitMask = PhysicsCategory.enemies
        pb.contactTestBitMask = PhysicsCategory.zoneA + PhysicsCategory.zoneB + PhysicsCategory.zoneC
        pb.collisionBitMask = PhysicsCategory.player + PhysicsCategory.enemies

        self.physicsBody = pb

        self.position.y += height
        self.zPosition = Layers.enemies
        
        let sideCorrector: CGFloat = side == .Left ? -1 : 1
        self.position.x += (width + view.width/2) * sideCorrector
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
