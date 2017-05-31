//
//  Constants.swift
//  ProjectNoName
//
//  Created by Cory Lennox on 5/9/17.
//  Copyright © 2017 Palm Studios. All rights reserved.
//
import Foundation
import UIKit

var ANCHOR_DISTANCE: CGFloat!

var SCALE: CGFloat!

//Ball
var BALL_MASS: CGFloat!
var BALL_RADIUS: CGFloat!
var BALL_SPEED: CGFloat!

//Platforms
var PLATFORM_RADIUS: CGFloat!
var BORDER_PLATFORM_PADDING: CGFloat!
var PLATFORM_TURN_POINT: CGFloat!
var STARTING_DISTANCE_FROM_BOTTOM: CGFloat!
var PLATFORM_DESCENT_SPEED: CGFloat!

//Base platform variables:
var PLATFORM_ROTATION_SPEED: CGFloat!
var PLATFORM_LATERAL_SPEED: CGFloat!
var PLATFORM_DISTANCE_APART: CGFloat!

struct CollisionCategoryBitMask
{
    static let Ball: UInt32 = 0x1 << 0
    static let Platform: UInt32 = 0x1 << 1
    static let Border: UInt32 = 0x1 << 2
    static let PlatformThreshold: UInt32 = 0x1 << 3
}
