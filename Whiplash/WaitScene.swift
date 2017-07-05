//
//  WaitScene.swift
//  Whiplash
//
//  Created by Cory Lennox on 6/7/17.
//  Copyright © 2017 Palm Studios. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import GoogleMobileAds

class WaitScene: SKScene
{
    //member variables
    var purchaseButton: SKSpriteNode!
    var playButton: SKSpriteNode!
    var gamecenterButton: SKSpriteNode!
    var rateButton: SKSpriteNode!
    var shareButton: SKSpriteNode!
    var contactButton: SKSpriteNode!
    
    override func didMove(to view: SKView)
    {
        backgroundColor = UIColor.black
        
        let delayInSeconds = 4.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds)
        {
            let reveal = SKTransition.fade(with: UIColor.black, duration: 1)
            let newScene = MenuScene(size: self.size)
            self.scene?.view?.presentScene(newScene, transition: reveal)
        }
    }
}
