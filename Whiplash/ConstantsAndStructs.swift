//
//  Constants.swift
//  ProjectNoName
//
//  Created by Cory Lennox on 5/9/17.
//  Copyright © 2017 Palm Studios. All rights reserved.
//
import Foundation
import UIKit

let AD_HEIGHT: CGFloat = 50 //350x50


let ANCHOR_RADIUS: CGFloat = 58

//Ball
let BALL_RADIUS: CGFloat = 12.9
let BALL_SPEED: CGFloat = 10

//Platforms
let PLATFORM_DIAMETER: CGFloat = 2 * ANCHOR_RADIUS - 2 * BALL_RADIUS //90
let BORDER_PLATFORM_PADDING: CGFloat = PLATFORM_DIAMETER + 2 * BALL_RADIUS + 5
let PLATFORM_TURN_POINT = BORDER_PLATFORM_PADDING - PLATFORM_DIAMETER/2
let STARTING_DISTANCE_FROM_BOTTOM: CGFloat = 50 + AD_HEIGHT
let PLATFORM_DESCENT_SPEED: CGFloat = 120

//Base platform variables:
let PLATFORM_ROTATION_SPEED: CGFloat = CGFloat.pi * 0.7
let PLATFORM_LATERAL_SPEED: CGFloat = 38
let PLATFORM_DISTANCE_APART: CGFloat = 260

struct Range {
    var lower: CGFloat
    var upper: CGFloat
}

struct CollisionCategoryBitMask {
    
    static let Ball: UInt32 = 0x1 << 0
    static let Platform: UInt32 = 0x1 << 1
    static let Border: UInt32 = 0x1 << 2
    static let PlatformThreshold: UInt32 = 0x1 << 3
}




