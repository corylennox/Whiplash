//
//  PlatformGenerator.swift
//  ProjectNoName
//
//  Created by Cory Lennox on 5/5/17.
//  Copyright © 2017 Palm Studios. All rights reserved.
//

import Foundation
import SpriteKit

class PlatformGenerator: SKSpriteNode
{
    var platforms = [Platform]()
    var rotationSpeed = PLATFORM_ROTATION_SPEED * CGFloat.pi
    var lateralSpeed = PLATFORM_LATERAL_SPEED
    var distanceApart = PLATFORM_DISTANCE_APART
    var currentColor = "GreenPlatform"
    
    func calcNumOfPlatsPerScreen() -> Int
    {
        var ret = size.height
        ret -= STARTING_DISTANCE_FROM_BOTTOM
        ret /= PLATFORM_DISTANCE_APART
        ret = ceil(ret)
        ret += 1
        return Int(ret)
    }
    
    
    func generateStartScreenPlatforms()
    {
        generateNextPlatform(movingLong: false, movingLat: false, rotating: false)
        platforms[0].position.x = size.width / 2
        
        generateNextPlatform(movingLong: false, movingLat: false, rotating: true)
        platforms[1].position.x = size.width / 2
        
        for _ in 0 ..< calcNumOfPlatsPerScreen() - 2
        {
            generateNextPlatform(movingLong: false, movingLat: true, rotating: true)
        }
    }
    
    func generateNextPlatform(movingLong: Bool, movingLat: Bool, rotating: Bool)
    {
        let platform = Platform(newRotationSpeed: rotationSpeed, newLateralSpeed: lateralSpeed!, color: getColor())
        
        let w = UInt32(size.width)
        let padding = UInt32(PLATFORM_TURN_POINT)
        let randRange: UInt32 =  w - 2 * padding
        let rand = arc4random_uniform(randRange)
        
        platform.position.x = CGFloat(rand + padding)
        
        //set platform y position
        if platforms.isEmpty
        {
            platform.position.y = STARTING_DISTANCE_FROM_BOTTOM
        }
        else
        {
            platform.position.y = (platforms.last?.position.y)! + distanceApart!
        }
        
        platforms.append(platform)
        addChild(platform)
        
        if movingLong
        {
            platform.startMovingLong()
        }
        
        if movingLat
        {
            var bool = true
            if arc4random_uniform(2) == 0
            {
                bool = false
            }
            
            platform.startMovingLat(toRight: bool)
        }
        
        if rotating
        {
            platform.startRotation()
        }
    }
    
    func getColor() -> String
    {
        if currentColor == "BluePlatform"
        {
            currentColor = "YellowPlatform"
            return currentColor
        }
        else if currentColor == "YellowPlatform"
        {
            currentColor =  "GreenPlatform"
            return currentColor
        }
        else if currentColor == "GreenPlatform"
        {
            currentColor =  "OrangePlatform"
            return currentColor
        }
        else if currentColor == "OrangePlatform"
        {
            currentColor =  "PurplePlatform"
            return currentColor
        }
        else if currentColor == "PurplePlatform"
        {
            currentColor =  "BluePlatform"
            return currentColor
        }
        else //catch case
        {
            currentColor =  "BluePlatform"
            return currentColor
        }
    }
    
    func removeBottomPlatform()
    {
        platforms.first?.removeFromParent()
        platforms.removeFirst()
    }
    
    func updateRotationSpeed(score: Int)
    {
        rotationSpeed = (0.15 * sqrt(CGFloat(score)) + PLATFORM_ROTATION_SPEED) * CGFloat.pi
        
    }
    
    func updateLateralSpeed(score: Int)
    {
        lateralSpeed = 20 * sqrt(CGFloat(score)) + PLATFORM_LATERAL_SPEED
    }
    
    func updateDistanceApart(score: Int)
    {
        distanceApart = 6 * sqrt(CGFloat(score)) + PLATFORM_DISTANCE_APART
    }
}

