//
//  GameViewController.swift
//  ProjectNoName
//
//  Created by Julio Hernandez on 12/15/16.
//  Copyright © 2016 Palm Studios. All rights reserved.
//

import UIKit
import SpriteKit
import Firebase
import GoogleMobileAds


// let kBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"
let kBannerAdUnitID = "ca-app-pub-5168834967300522/4058151097"

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
        scene.scaleMode = .aspectFit
        
        //present scene
        skView.presentScene(scene)
        
        let adSize = kGADAdSizeBanner
        let bannerView = GADBannerView(adSize:adSize, origin: CGPoint(x: 0.0, y: skView.bounds.size.height - AD_HEIGHT))
        bannerView.adUnitID = kBannerAdUnitID
        bannerView.rootViewController = self
        
        skView.addSubview(bannerView)
        bannerView.load(GADRequest())
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
