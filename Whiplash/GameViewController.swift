//
//  GameViewController.swift
//  ProjectNoName
//
//  Created by Julio Hernandez on 12/15/16.
//  Copyright © 2016 Palm Studios. All rights reserved.
//

import UIKit
import StoreKit
import SpriteKit
import Firebase
import GoogleMobileAds
import MessageUI
import GameKit

//let kBannerAdUnitID = "ca-app-pub-3940256099942544/4411468910"  //test ID
let kBannerAdUnitID = "ca-app-pub-8989932856434416/4656694886"  //real ID

class GameViewController: UIViewController, GKGameCenterControllerDelegate, MFMailComposeViewControllerDelegate, GADInterstitialDelegate,  SKProductsRequestDelegate, SKPaymentTransactionObserver
{
    var scene: GameScene!
    var myAd: GADInterstitial!
    var list = [SKProduct]()
    var p = SKProduct()
    var skView: SKView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if(SKPaymentQueue.canMakePayments()) {
            print("IAP is enabled, loading")
            let productID: NSSet = NSSet(objects: "com.palmtech.remove_ads")
            let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            request.delegate = self
            request.start()
            SKPaymentQueue.default().add(self)
        }
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.restorePurchases), name: NSNotification.Name(rawValue: "restorePurchases"), object: nil)
        
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
    @objc func loadAd()
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
    @objc func loadAndShowGC()
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
    
    /********* Rate Stuff *********/
    @objc func loadAndShowRate()
    {
        let appID = "1247181092"
        let url = URL(string : "itms-apps://itunes.apple.com/app/" + appID)
        UIApplication.shared.open((url)!, options: [:], completionHandler: nil)
    }
    
    func completion(_ completed: Bool)
    {
    }
    
    /********* Share Stuff *********/
    @objc func loadAndShowShare()
    {
        if let link = NSURL(string: "https://itunes.apple.com/app/1247181092.com")
        {
            let activityVC = UIActivityViewController(activityItems: [link], applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    /********* Contact Stuff *********/
    @objc func loadAndShowEmail()
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
    
    /*********** Purchase Stuff ***********/
    @objc func restorePurchases()
    {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    @objc func loadAndShowPurchase()
    {
        if(!SKPaymentQueue.canMakePayments())
        {
            //alert that IAP is disabled
            let sendIAPErrorAlert = UIAlertController(title: "Could Not Process Request", message: "Please enable In-App Purchases for this application.", preferredStyle: UIAlertControllerStyle.alert)
            sendIAPErrorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(sendIAPErrorAlert, animated: true, completion: nil)
            return
        }
        
        for product in list {
            let prodID = product.productIdentifier
            if(prodID == "com.palmtech.remove_ads") {
                p = product
                buyProduct()
            }
        }
    }
    
    func buyProduct() {
        print("buy " + p.productIdentifier)
        let pay = SKPayment(product: p)
        SKPaymentQueue.default().add(pay as SKPayment)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("add payment")
        
        for transaction: AnyObject in transactions {
            let trans = transaction as! SKPaymentTransaction
            
            switch trans.transactionState {
            case .purchased:
                print(p.productIdentifier)
                
                let prodID = p.productIdentifier
                switch prodID {
                case "com.palmtech.remove_ads":
                    removeAds()
                default:
                    print("IAP not found")
                }
                queue.finishTransaction(trans)
            case .failed:
                print("buy error")
                queue.finishTransaction(trans)
                break
            default:
                print("Default")
                break
            }
        }
    }
    
    func removeAds() {
        print("removing ads...")
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "ads")
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("product request")
        let myProduct = response.products
        for product in myProduct {
            print("product added")
            print(product.productIdentifier)
            print(product.localizedTitle)
            print(product.localizedDescription)
            print(product.price)
            
            list.append(product)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error)
    {
        //show IAP restore error alert
        let sendPurchaseAlert = UIAlertController(title: "In-App Purchases", message: "There was a problem restoring your in-app purchases.", preferredStyle: UIAlertControllerStyle.alert)
        sendPurchaseAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(sendPurchaseAlert, animated: true, completion: nil)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        var purchasedSomething: Bool = false
        for transaction in queue.transactions
        {
            let t: SKPaymentTransaction = transaction
            let prodID = t.payment.productIdentifier as String
            
            switch prodID {
            case "com.palmtech.remove_ads":
                purchasedSomething = true
                removeAds()
            default:
                print("IAP not found")
            }
        }
        
        if purchasedSomething == true
        {
            //show IAP restored alert
            let sendPurchaseAlert = UIAlertController(title: "In-App Purchases", message: "Your in-app purchases have been restored.", preferredStyle: UIAlertControllerStyle.alert)
            sendPurchaseAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(sendPurchaseAlert, animated: true, completion: nil)
        }
        else
        {
            //show no IAP restored alert
            let sendPurchaseAlert = UIAlertController(title: "In-App Purchases", message: "No in-app purchases found for this account.", preferredStyle: UIAlertControllerStyle.alert)
            sendPurchaseAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(sendPurchaseAlert, animated: true, completion: nil)
        }
        
        print("transactions restored")
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
