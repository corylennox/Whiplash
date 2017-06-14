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
import MessageUI
import GameKit
import StoreKit

//let kBannerAdUnitID = "ca-app-pub-3940256099942544/4411468910"  //test ID
let kBannerAdUnitID = "ca-app-pub-8989932856434416/4656694886"  //real ID

class GameViewController: UIViewController, GKGameCenterControllerDelegate, MFMailComposeViewControllerDelegate, GADInterstitialDelegate
{
    var scene: GameScene!
    var myAd: GADInterstitial!
    var skView: SKView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Configure the view
        skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        //skView.showsPhysics = true;
        skView.preferredFramesPerSecond = 60
        
        initConstants(size: skView.bounds.size)
        
        // Create and configure the scene
        scene = GameScene(size: skView.bounds.size)
        
        //present scene
        skView.presentScene(scene)
        
        //NS Observers
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.loadAd), name: NSNotification.Name(rawValue: "loadAd"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.loadAndShowPurchase), name: NSNotification.Name(rawValue: "loadAndShowPurchase"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.loadAndShowGC), name: NSNotification.Name(rawValue: "loadAndShowGC"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.loadAndShowRate), name: NSNotification.Name(rawValue: "loadAndShowRate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.loadAndShowShare), name: NSNotification.Name(rawValue: "loadAndShowShare"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.loadAndShowEmail), name: NSNotification.Name(rawValue: "loadAndShowEmail"), object: nil)

    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        authenticatePlayer() //log in to gamecenter
    }
    
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    /*********** Ad Stuff ***********/
    func loadAd()
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
    
    /*********** Purchase Stuff ***********/
    func loadAndShowPurchase()
    {
        
    }
    
    /********* Game Center Stuff *********/
    func loadAndShowGC()
    {
        showLeaderboard()
    }
    
    func authenticatePlayer()
    {
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler =
        {
            (view, error) in
            
            if view != nil
            {
                self.present(view!, animated: true, completion: nil)
            }
        }
    }
    
    func showLeaderboard()
    {
        let gcViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        gcViewController.viewState = GKGameCenterViewControllerState.leaderboards
        gcViewController.leaderboardIdentifier = "com.palmtech.leaderboard"
        
        self.present(gcViewController, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(_ gcViewController: GKGameCenterViewController)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    /********* Rate Stuff *********/
    func loadAndShowRate()
    {
        let appID = "1247181092"
        let url = URL(string : "itms-apps://itunes.apple.com/app/" + appID)
        UIApplication.shared.open((url)!, options: [:], completionHandler: nil)
    }
    
    func completion(_ completed: Bool)
    {
    }
    
    /********* Share Stuff *********/
    func loadAndShowShare()
    {
        if let link = NSURL(string: "https://itunes.apple.com/app/1247181092.com")
        {
            let activityVC = UIActivityViewController(activityItems: [link], applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    /********* Contact Stuff *********/
    func loadAndShowEmail()
    {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail()
        {
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
        else
        {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController
    {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["contact.palm.tech@gmail.com"])
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert()
    {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Please check your e-mail configuration and try again.", preferredStyle: UIAlertControllerStyle.alert)
        sendMailErrorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(_: MFMailComposeViewController, didFinishWith: MFMailComposeResult, error: Error?)
    {
        dismiss(animated: true, completion: nil)
    }
    
    /********* initialize constants *********/
    func initConstants(size: CGSize)
    {
        //ONLY CHANGE THESE VALUES
        let platformRad: CGFloat = 62
        let distFromBottom: CGFloat = 100
        let descentSpeed: CGFloat = 100
        let rotateSpeed: CGFloat = 0.4
        let lateralSpeed: CGFloat = 20
        let distApart: CGFloat = 270
        let ballRad: CGFloat  = 0.26 * platformRad
        let ballSpeed: CGFloat  = 10
        
        /**** LEAVE ALONE ****/
        SCALE = size.height/736
        
        BALL_MASS = 0.02
        BALL_RADIUS = ballRad * SCALE
        BALL_SPEED = ballSpeed * SCALE
        
        PLATFORM_RADIUS = platformRad * SCALE
        PLATFORM_SCALE = (platformRad / 110.7) * SCALE //110.7 = radius of the platform png
        PLATFORM_TURN_POINT = PLATFORM_RADIUS + 2 * BALL_RADIUS + (5 * SCALE)
        STARTING_DISTANCE_FROM_BOTTOM = distFromBottom * SCALE
        PLATFORM_DESCENT_SPEED = descentSpeed * SCALE
        PLATFORM_ROTATION_SPEED = rotateSpeed
        PLATFORM_LATERAL_SPEED = lateralSpeed * SCALE
        PLATFORM_DISTANCE_APART = distApart * SCALE
        
        ANCHOR_DISTANCE = BALL_RADIUS + PLATFORM_RADIUS
    }
}
