//
//  MenuScene.swift
//  Whiplash
//
//  Created by Cory Lennox on 6/4/17.
//  Copyright © 2017 Palm Studios. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class MenuScene: SKScene
{
    //member variables
    var purchaseButton: SKSpriteNode!
    var playButton: SKSpriteNode!
    var gameCenterButton: SKSpriteNode!
    var rateButton: SKSpriteNode!
    var shareButton: SKSpriteNode!
    var contactButton: SKSpriteNode!

    override func didMove(to view: SKView)
    {
        backgroundColor = UIColor(colorLiteralRed: 58/255, green: 58/255, blue: 58/255, alpha: 1)
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        getConstants()
        addButtons()
        buttonPulsing()
        addLabels()
    }
    
    func getConstants()
    {
        if SCALE == nil
        {
            SCALE = size.height/736
        }
        SMALL_BUTTON_SIZE = 74 * SCALE
        BIG_BUTTON_SIZE = 90 * SCALE
    }
    
    func addButtons()
    {
        //for even spaced buttons
        let extra = 40 * SCALE
        let xDist = size.width + extra
        let firstRow = size.height * 0.28
        let secondRow = size.height * 0.12
        let firstColumn = (xDist / 4) - extra / 2
        let secondColumn = size.width/2
        let thirdColumn = (xDist * 3 / 4) - extra / 2
        
        let purchaseX = firstColumn
        let purchaseY = firstRow
        let playX = secondColumn
        let playY = firstRow
        let gameCenterX = thirdColumn
        let gameCenterY = firstRow
        let rateX = firstColumn
        let rateY = secondRow
        let shareX = secondColumn
        let shareY = secondRow
        let contactX = thirdColumn
        let contactY = secondRow
        
        //purchase button
        purchaseButton = SKSpriteNode(imageNamed: "PurchaseButton")
        purchaseButton.position = CGPoint(x: purchaseX, y: purchaseY)
        purchaseButton.scale(to: CGSize(width: SMALL_BUTTON_SIZE, height: SMALL_BUTTON_SIZE))
        addChild(purchaseButton)
        
        //play button
        playButton = SKSpriteNode(imageNamed: "PlayButton")
        playButton.position = CGPoint(x: playX, y: playY)
        playButton.scale(to: CGSize(width: BIG_BUTTON_SIZE, height: BIG_BUTTON_SIZE))
        addChild(playButton)
        
        //game center button
        gameCenterButton = SKSpriteNode(imageNamed: "GameCenterButton")
        gameCenterButton.position = CGPoint(x: gameCenterX, y: gameCenterY)
        gameCenterButton.scale(to: CGSize(width: SMALL_BUTTON_SIZE, height: SMALL_BUTTON_SIZE))
        addChild(gameCenterButton)
        
        //rate button
        rateButton = SKSpriteNode(imageNamed: "RateButton")
        rateButton.position = CGPoint(x: rateX, y: rateY)
        rateButton.scale(to: CGSize(width: SMALL_BUTTON_SIZE, height: SMALL_BUTTON_SIZE))
        addChild(rateButton)

        //share button
        shareButton = SKSpriteNode(imageNamed: "ShareButton")
        shareButton.position = CGPoint(x: shareX, y: shareY)
        shareButton.scale(to: CGSize(width: SMALL_BUTTON_SIZE, height: SMALL_BUTTON_SIZE))
        addChild(shareButton)

        //contact button
        contactButton = SKSpriteNode(imageNamed: "ContactButton")
        contactButton.position = CGPoint(x: contactX, y: contactY)
        contactButton.scale(to: CGSize(width: SMALL_BUTTON_SIZE, height: SMALL_BUTTON_SIZE))
        addChild(contactButton)
    }
    
    func addLabels()
    {
        let extra = 40 * SCALE
        let xDist = size.width + extra
        let rowOne = size.height * 0.6
        let rowTwo = size.height * 0.5
        let firstColumn = (xDist / 3) - (extra / 2)
        let secondColumn = (xDist * 2 / 3) - (extra / 2)
        
        //"Best" label
        let bestTextLabel = SKLabelNode()
        bestTextLabel.fontColor = UIColor(colorLiteralRed: 244/255, green: 236/255, blue: 211/255, alpha: 1)
        bestTextLabel.fontName = "Avenir"
        bestTextLabel.fontSize = 35 * SCALE
        bestTextLabel.text = "Best"
        bestTextLabel.position = CGPoint(x: secondColumn, y: rowOne)
        addChild(bestTextLabel)
        
        //"Score" label
        let scoreTextLabel = SKLabelNode()
        scoreTextLabel.fontColor = UIColor(colorLiteralRed: 244/255, green: 236/255, blue: 211/255, alpha: 1)
        scoreTextLabel.fontName = "Avenir"
        scoreTextLabel.fontSize = 35 * SCALE
        scoreTextLabel.text = "Score"
        scoreTextLabel.position = CGPoint(x: firstColumn, y: rowOne)
        addChild(scoreTextLabel)
        
        //high Score
        let bestLabel = SKLabelNode()
        bestLabel.fontColor = UIColor(colorLiteralRed: 244/255, green: 236/255, blue: 211/255, alpha: 1)
        bestLabel.fontName = "Avenir"
        bestLabel.fontSize = 60 * SCALE
        bestLabel.text = "\(UserDefaults.standard.integer(forKey: "highScore"))"
        bestLabel.position = CGPoint(x: secondColumn, y: rowTwo)
        addChild(bestLabel)
        
        //latest Score
        let scoreLabel = SKLabelNode()
        scoreLabel.fontColor = UIColor(colorLiteralRed: 244/255, green: 236/255, blue: 211/255, alpha: 1)
        scoreLabel.fontName = "Avenir"
        scoreLabel.fontSize = 60 * SCALE
        scoreLabel.text = "\(UserDefaults.standard.integer(forKey: "lastScore"))"
        scoreLabel.position = CGPoint(x: firstColumn, y: rowTwo)
        addChild(scoreLabel)
        
        //add "Whiplash" label
        let whiplashLabel = SKLabelNode()
        whiplashLabel.fontColor = UIColor(colorLiteralRed: 244/255, green: 236/255, blue: 211/255, alpha: 1)
        whiplashLabel.fontName = "Avenir"
        whiplashLabel.fontSize = 80 * SCALE
        whiplashLabel.text = "Whiplash"
        whiplashLabel.position = CGPoint(x: size.width/2, y: size.height * 0.8)
        addChild(whiplashLabel)
    }

    func runPurchase()
    {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadAndShowPurchase"), object: nil)
    }
    
    func runPlay()
    {
        let reveal = SKTransition.fade(with: UIColor.black, duration: 1)
        let newScene = GameScene(size: size)
        scene?.view?.presentScene(newScene, transition: reveal)
    }
    
    func runGameCenter()
    {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadAndShowGC"), object: nil)
    }
    
    func runRate()
    {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadAndShowRate"), object: nil)
    }
    
    func runShare()
    {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadAndShowShare"), object: nil)
    }
    
    func runContact()
    {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadAndShowEmail"), object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let touch = touches.first
        {
            let currentPoint = touch.location(in: self)
            let clickedNode = self.atPoint(currentPoint)
            
            if clickedNode == purchaseButton
            {
                runPurchase()
            }
            if clickedNode == playButton
            {
                runPlay()
            }
            if clickedNode == gameCenterButton
            {
                runGameCenter()
            }
            if clickedNode == rateButton
            {
                runRate()
            }
            if clickedNode == shareButton
            {
                runShare()
            }
            if clickedNode == contactButton
            {
                runContact()
            }
        }
    }
    
    func buttonPulsing()
    {
        let inflate = SKAction.scale(by: 1.15, duration: 0.8)
        let deflate = SKAction.scale(by: 1/1.15, duration: 0.8)
        let pulse = SKAction.sequence([inflate, deflate])
        playButton.run(SKAction.repeatForever(pulse))
    }
}
