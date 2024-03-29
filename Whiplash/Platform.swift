//
//  Platform.swift
//  ProjectNoName
//
//  Created by Cory Lennox on 5/5/17.
//  Copyright © 2017 Palm Studios. All rights reserved.
//

import Foundation
import SpriteKit

class Platform: SKSpriteNode
{
    var isMovingRight: Bool?
    var moveRight: SKAction!
    var moveLeft: SKAction!
    
    var rotationSpeed: CGFloat = 0
    var lateralSpeed: CGFloat = 0
    var downSpeed: CGFloat = 0
    
    init(newRotationSpeed: CGFloat, newLateralSpeed: CGFloat, newDownSpeed: CGFloat, color: String)
    {
        let texture = SKTexture(imageNamed: color)
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        rotationSpeed = newRotationSpeed
        lateralSpeed = newLateralSpeed
        downSpeed = newDownSpeed
        self.setScale(PLATFORM_SCALE)  //scale it to fit platform physicsbody
        loadPhysicsBody()
    }
    
    func loadPhysicsBody()
    {
        physicsBody = SKPhysicsBody(circleOfRadius: PLATFORM_RADIUS)
        physicsBody?.isDynamic = false
        physicsBody?.affectedByGravity = false
        physicsBody?.usesPreciseCollisionDetection = true
        physicsBody?.categoryBitMask = CollisionCategoryBitMask.Platform
        physicsBody?.contactTestBitMask = CollisionCategoryBitMask.Ball
        physicsBody?.collisionBitMask = 0
    }
    
    func startRotation()
    {
        if arc4random_uniform(2) == 0
        {
            run(SKAction.repeatForever(SKAction.rotate(byAngle: rotationSpeed, duration: 1)))
        }
        else
        {
            run(SKAction.repeatForever(SKAction.rotate(byAngle: -rotationSpeed, duration: 1)))
        }
    }
    
    func startMovingLong()
    {
        let moveDown = SKAction.moveBy(x:0, y: -downSpeed, duration: 1)
        run(SKAction.repeatForever(moveDown))
    }
    
    func startMovingLat(toRight: Bool)
    {
        if toRight
        {
            removeAction(forKey: "moveLeft")
            moveRight = SKAction.moveBy(x: lateralSpeed, y: 0, duration: 1)
            run(SKAction.repeatForever(moveRight), withKey: "moveRight")
            isMovingRight = true
        }
        else
        {
            removeAction(forKey: "moveRight")
            moveLeft = SKAction.moveBy(x: -lateralSpeed, y: 0, duration: 1)
            run(SKAction.repeatForever(moveLeft), withKey: "moveLeft")
            isMovingRight = false
        }
    }
    
    func updateDescentSpeed(moveBySpeed: CGFloat)
    {
        let moveDown = SKAction.moveBy(x:0, y: -moveBySpeed, duration: 1)
        run(SKAction.repeatForever(moveDown))
    }
    
    func stopActions()
    {
        removeAllActions()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
