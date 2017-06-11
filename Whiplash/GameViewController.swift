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

let kBannerAdUnitID = "ca-app-pub-3940256099942544/4411468910"  //test ID
//let kBannerAdUnitID = "ca-app-pub-8989932856434416/4656694886"  //real ID

class GameViewController: UIViewController, MFMailComposeViewControllerDelegate, GADInterstitialDelegate
{
    var scene: GameScene!
    var myAd: GADInterstitial!
    var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure the view
        skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        //skView.showsPhysics = true;
        skView.preferredFramesPerSecond = 60
        
        // Create and configure the scene
        scene = GameScene(size: skView.bounds.size)
        
        //present scene
        skView.presentScene(scene)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.loadAd), name: NSNotification.Name(rawValue: "loadAd"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.loadAndShowShare), name: NSNotification.Name(rawValue: "loadAndShowRate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.loadAndShowShare), name: NSNotification.Name(rawValue: "loadAndShowShare"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.loadAndShowEmail), name: NSNotification.Name(rawValue: "loadAndShowEmail"), object: nil)

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
    /********* Game Center Stuff *********/
    func loadAndShowGC()
    {
        print("Game Center stuff")
    }
    
    /********* Rate Stuff *********/
    func loadAndShowRate()
    {
        print("rate stuff")
    }
    
    /********* Share Stuff *********/
    func loadAndShowShare()
    {
        //let message = "optional message"
        //let image = UIImage(named: "optional image")
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
        //mailComposerVC.setSubject("Subject")
        //mailComposerVC.setMessageBody("Body", isHTML: false)
        
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
}
