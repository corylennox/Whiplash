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

let kBannerAdUnitID = "ca-app-pub-5168834967300522/9510438698"

class GameViewController: UIViewController, GADInterstitialDelegate
{
    var scene: GameScene!
    var myAd: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure the view
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        //skView.showsPhysics = true;
        skView.preferredFramesPerSecond = 60
        
        // Create and configure the scene
        scene = GameScene(size: skView.bounds.size)
        
        //present scene
        skView.presentScene(scene)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.loadAndShow), name: NSNotification.Name(rawValue: "loadAndShow"), object: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func loadAndShow()
    {
        myAd = GADInterstitial(adUnitID: kBannerAdUnitID)
        let request = GADRequest()
        myAd.delegate = self
        myAd.load(request)
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial)
    {
        if (self.myAd.isReady)
        {
            myAd.present(fromRootViewController: self)
        }
    }
}
