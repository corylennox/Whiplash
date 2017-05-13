//
//  GameViewController.swift
//  ProjectNoName
//
//  Created by Julio Hernandez on 12/15/16.
//  Copyright © 2016 Palm Studios. All rights reserved.
//

import Firebase
import UIKit
import SpriteKit


let kBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"

class GameViewController: UIViewController, GADInterstitialDelegate
{
    var scene: GameScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        skView.showsPhysics = true;
        skView.preferredFramesPerSecond = 60

        // Create and configure the scene
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        //present scene
        skView.presentScene(scene)
        
        
        let bannerView = GADBannerView(adSize:kGADAdSizeBanner,origin: CGPoint(x: 0.0, y: 300))
        bannerView.adUnitID = kBannerAdUnitID
        bannerView.rootViewController = self
        //bannerView.load(GADRequest())
        
        skView.addSubview(bannerView)
        bannerView.load(GADRequest())
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
