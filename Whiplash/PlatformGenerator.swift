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
    
    var rotationSpeed = Range(lower: PLATFORM_ROTATION_SPEED, upper: PLATFORM_ROTATION_SPEED)
    var lateralSpeed = Range(lower: PLATFORM_LATERAL_SPEED ,upper: PLATFORM_LATERAL_SPEED)
    var distanceApart = Range(lower: PLATFORM_DISTANCE_APART, upper: PLATFORM_DISTANCE_APART)
    
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
        let randRotationSpeed = CGFloat(arc4random_uniform(UInt32(100*rotationSpeed.upper-100*rotationSpeed.lower)) + UInt32(100*rotationSpeed.lower)) / 100
        let randLateralSpeed = CGFloat(arc4random_uniform(UInt32(lateralSpeed.upper-lateralSpeed.lower)) + UInt32(lateralSpeed.lower))
        let platform = Platform(newRotationSpeed: randRotationSpeed, newLateralSpeed: randLateralSpeed)
        
        let w = UInt32(size.width)
        let padding = UInt32(PLATFORM_TURN_POINT)
        let randRange: UInt32 =  w - 2 * padding
        let rand = arc4random_uniform(randRange)
        
        platform.position.x = CGFloat(rand + padding)
        
        //set platform y position
        let randDistanceApart = CGFloat(arc4random_uniform(UInt32(distanceApart.upper-distanceApart.lower))) + distanceApart.lower

        if platforms.isEmpty
        {
            platform.position.y = STARTING_DISTANCE_FROM_BOTTOM
        }
        else
        {
            platform.position.y = (platforms.last?.position.y)! + randDistanceApart
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
        
        /*
        print("New Platform:")
        print("\tRanges:")
        print("\t\tRotation: ", rotationSpeed.lower, " - " ,rotationSpeed.upper)
        print("\t\tLateral: ", lateralSpeed.lower, " - " ,lateralSpeed.upper)
        print("\t\tDistanceApart: ", distanceApart.lower, " - " ,distanceApart.upper)
        print("\tGenerated Values:")
        print("\t\tRotation: ", randRotationSpeed)
        print("\t\tLateral: ", randLateralSpeed)
        print("\t\tDistanceApart: ", randDistanceApart)
        print("\n")
         */
    }
    
    func removeBottomPlatform()
    {
        platforms.first?.removeFromParent()
        platforms.removeFirst()
    }
    
    func calcNewRotationSpeed(score: Int) -> Range
    {
        let lower = (0.12 * sqrt(CGFloat(score)) + 0.7) * CGFloat.pi
        let upper = (0.17 * sqrt(CGFloat(score)) + 0.7) * CGFloat.pi
        let ret = Range(lower: CGFloat(lower), upper: CGFloat(upper))
        
        //print("rotation speed lower: ", ret.lower / CGFloat.pi, " upper: ", ret.upper / CGFloat.pi)
        
        return ret
    }
    
    func calcNewLateralSpeed(score: Int) -> Range
    {
        let lower = 17 * sqrt(CGFloat(score)) + 38
        let upper = 22.5 * sqrt(CGFloat(score)) + 38
        let ret = Range(lower: CGFloat(lower), upper: CGFloat(upper))
        
        //print("lateral speed lower: ", ret.lower, " upper: ", ret.upper)
        
        return ret
    }
    
    func calcNewDistanceApart(score: Int) -> Range
    {
        let lower = 3 * sqrt(CGFloat(score)) + 260
        let upper = 10 * sqrt(CGFloat(score)) + 260
        let ret = Range(lower: CGFloat(lower), upper: CGFloat(upper))
        
        //print("distance apart lower: ", ret.lower, " upper: ", ret.upper)
        
        return ret
    }
}

