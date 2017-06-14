//
//  GameScene.swift
//  ProjectNoName
//
//  Created by Julio "Jay Palm" Hernandez on 12/15/16.
//  Copyright © 2016 Palm Studios. All rights reserved.
//

import SpriteKit
import GameplayKit
import GameKit

class GameScene: SKScene, SKPhysicsContactDelegate
{
    //member variables
    var platformGenerator: PlatformGenerator!
    var currentPlatform: SKNode?
    var ball: SKShapeNode!
    var border: SKPhysicsBody!
    var joint = SKPhysicsJointFixed()
    var menuButton = SKSpriteNode()
    
    var scoreLabel: ScoreLabel!
    var highScoreLabel: ScoreLabel!
    var gameIsStarted = false
    var gameIsOver = false
    var gameIsPaused = false
    
    override func didMove(to view: SKView)
    {
        backgroundColor = UIColor(colorLiteralRed: 244/255, green: 236/255, blue: 211/255, alpha: 1)

        addPhysicsWorld()
        addBorder()
        addPlatformGenerator()
        platformGenerator.generateStartScreenPlatforms()
        addBall()
        addScoreLabels()
        loadHighscore()
        addTapToStartLabel()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if !gameIsStarted
        {
            start()
        }
        
        //so ball only jumps if its on a platform
        if currentPlatform == nil
        {
            return
        }
        
        scene?.physicsWorld.remove(joint)
        
        // Calculate vector components x and y
        var dx: CGFloat = ball.position.x - (currentPlatform?.position.x)!
        var dy: CGFloat = ball.position.y - (currentPlatform?.position.y)!
        
        // Normalize the components
        let magnitude = sqrt(dx*dx+dy*dy)
        dx /= magnitude
        dy /= magnitude
        let dir = CGVector(dx: dx * BALL_SPEED, dy: dy * BALL_SPEED)
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        ball.physicsBody?.applyImpulse(dir)
        
        currentPlatform = nil
    }
    
    //contact between two PhysicsBodys occurred
    func didBegin(_ contact: SKPhysicsContact)
    {
        let nodeA = contact.bodyA.categoryBitMask
        
        if nodeA == CollisionCategoryBitMask.Border
        {
            gameOver()
        }
        
        if nodeA == CollisionCategoryBitMask.Platform
        {
            if currentPlatform != contact.bodyA
            {
                let a = ball.position.x - contact.bodyA.node!.position.x
                let b = ball.position.y - contact.bodyA.node!.position.y
                let c = sqrt(a*a+b*b)
                
                let magnitude: CGFloat = ANCHOR_DISTANCE/c
                
                //print("orig dist from center of platform: ",(c), " new: ",(sqrt(a*a*magnitude*magnitude+b*b*magnitude*magnitude)))
                
                let anchor = CGPoint(x: (contact.bodyA.node?.position.x)! + a*magnitude,
                                     y: (contact.bodyA.node?.position.y)! + b*magnitude)
                ball.position = anchor
                
                joinPhysicsBodies(bodyA: contact.bodyA, bodyB: contact.bodyB, point:anchor)
                currentPlatform = contact.bodyA.node
                
                scoreLabel.increment()
                scoreLabel.scoreChanged = true
                
                if highScoreLabel.number < scoreLabel.number
                {
                    highScoreLabel.setTo(scoreLabel.number)
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        let bottomPlatform = platformGenerator.platforms.first
        
        //delete and generate new plat
        if (bottomPlatform?.position.y)! + ANCHOR_DISTANCE < 0
        {
            platformGenerator.removeBottomPlatform()
            platformGenerator.generateNextPlatform(movingLong: true, movingLat: true, rotating: true)
        }
        
        //send plat other direction
        for platform in platformGenerator.platforms
        {
            if platform.position.x < PLATFORM_TURN_POINT && platform.isMovingRight == false
            {
                platform.startMovingLat(toRight: true)
            }
            
            if platform.position.x > size.width - PLATFORM_TURN_POINT &&
                platform.isMovingRight == true
            {
                platform.startMovingLat(toRight: false)
            }
        }
        
        //runs every time score increases
        if scoreLabel.number < 75 && scoreLabel.scoreChanged == true
        {
            platformGenerator.updateRotationSpeed(score: scoreLabel.number)
            platformGenerator.updateLateralSpeed(score: scoreLabel.number)
            platformGenerator.updateDistanceApart(score: scoreLabel.number)
            
            scoreLabel.scoreChanged = false;
        }
    }

    func addPhysicsWorld()
    {
        physicsWorld.contactDelegate = self
    }
    
    func addBorder()
    {
        let borderWithExtraHeight = CGRect(x: 0, y: 0, width: size.width, height: size.height + 2 * PLATFORM_RADIUS)
        border = SKPhysicsBody(edgeLoopFrom: borderWithExtraHeight)
        border.categoryBitMask = CollisionCategoryBitMask.Border
        border.contactTestBitMask = CollisionCategoryBitMask.Ball
        border.collisionBitMask = 0
        self.physicsBody = border
    }
    
    func addPlatformGenerator()
    {
        platformGenerator = PlatformGenerator(color: UIColor.clear, size: size)
        addChild(platformGenerator)
    }
    
    func addBall()
    {
        ball = SKShapeNode(circleOfRadius: BALL_RADIUS)
        ball.fillColor = UIColor(colorLiteralRed: 58/256, green: 58/255, blue: 58/255, alpha: 1)
        ball.strokeColor = UIColor(colorLiteralRed: 58/256, green: 58/255, blue: 58/255, alpha: 1)
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: BALL_RADIUS)
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.usesPreciseCollisionDetection = true
        ball.physicsBody?.categoryBitMask = CollisionCategoryBitMask.Ball
        ball.physicsBody?.contactTestBitMask = CollisionCategoryBitMask.Platform
        ball.physicsBody?.collisionBitMask = 0
        ball.physicsBody?.affectedByGravity = false
        ball.physicsBody?.mass = BALL_MASS
        
        let startingPlat: Platform = platformGenerator.platforms[0]
        
        let x: CGFloat = size.width / 2
        let y: CGFloat = startingPlat.position.y + ANCHOR_DISTANCE
        let anchor = CGPoint(x: x, y: y)
        
        ball.position = anchor
        
        addChild(ball)
        
        joinPhysicsBodies(bodyA: ball.physicsBody!, bodyB: startingPlat.physicsBody!, point: anchor)
        currentPlatform = startingPlat
    }
    
    func addScoreLabels()
    {
        //current score
        scoreLabel = ScoreLabel(num: 0)
        scoreLabel.position = CGPoint(x: 35.0 * SCALE, y: size.height - 35 * SCALE)
        scoreLabel.name = "scoreLabel"
        addChild(scoreLabel)
        
        //high score
        highScoreLabel = ScoreLabel(num: 0)
        highScoreLabel.name = "highScoreLabel"
        highScoreLabel.position = CGPoint(x: size.width - 35 * SCALE, y: size.height - 35 * SCALE)
        addChild(highScoreLabel)
        
        let highScoreTextLabel = SKLabelNode(text: "Best")
        highScoreTextLabel.fontName = "Avenir"
        highScoreTextLabel.fontColor = UIColor.black
        highScoreTextLabel.fontSize = 18.0 * SCALE
        highScoreTextLabel.position = CGPoint(x: size.width - 35 * SCALE, y: size.height - 52 * SCALE)
        addChild(highScoreTextLabel)
    }
    
    func loadHighscore() {
        let defaults = UserDefaults.standard
        
        let highScoreLabel = childNode(withName: "highScoreLabel") as! ScoreLabel
        highScoreLabel.setTo(defaults.integer(forKey: "highScore"))
    }

    func addTapToStartLabel()
    {
        let tapToStartLabel = SKLabelNode(text: "tap to jump")
        tapToStartLabel.name = "tapToStartLabel"
        tapToStartLabel.position.x = size.width/2
        tapToStartLabel.position.y = size.height * 0.65
        tapToStartLabel.fontName = "Avenir"
        tapToStartLabel.fontColor = UIColor(colorLiteralRed: 58/256, green: 58/255, blue: 58/255, alpha: 1)
        tapToStartLabel.fontSize = 40.0 * SCALE
        addChild(tapToStartLabel)
        tapToStartLabel.run(blinkAnimation())
    }
    
    func start()
    {
        gameIsStarted = true
        let tapToStartLabel = childNode(withName: "tapToStartLabel")
        tapToStartLabel?.removeFromParent()
        
        for platform in platformGenerator.platforms
        {
            platform.startMovingLong()
        }
    }
    
    func gameOver()
    {
        // stop everything
        self.isPaused = true
        
        gameIsOver = true
        GAMES_PLAYED += 1
        
        let defaults = UserDefaults.standard
        let oldHighScore = defaults.integer(forKey: "highScore")
    
        //uncomment to reset highscore defaults.set(0, forKey: "highScore")
        
        if oldHighScore < highScoreLabel.number
        {
            //set new high score
            defaults.set(highScoreLabel.number, forKey: "highScore")
            
            //set new hs in gamecenter
            let leaderboardID = "com.palmtech.leaderboard"
            let sScore = GKScore(leaderboardIdentifier: leaderboardID)
            sScore.value = Int64(highScoreLabel.number)
            
            GKScore.report([sScore], withCompletionHandler: { (error: NSError?) -> Void in
                if error != nil
                {
                    print(error!.localizedDescription)
                }
                else
                {
                    print("Score submitted")
                }
            } as? (Error?) -> Void)
        }
        
        defaults.set(scoreLabel.number, forKey: "lastScore")
        
        //present next scene
        let reveal = SKTransition.fade(with: UIColor.black, duration: 1)
        if GAMES_PLAYED % SHOW_AD_EVERY_X_GAMES == 0
        {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadAd"), object: nil)
            let newScene = WaitScene(size: size)
            scene?.view?.presentScene(newScene, transition: reveal)
        }
        else
        {
            let newScene = MenuScene(size: size)
            scene?.view?.presentScene(newScene, transition: reveal)
        }
    }
    
    func blinkAnimation() -> SKAction {
        let duration = 0.8
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: duration)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: duration)
        let blink = SKAction.sequence([fadeOut, fadeIn])
        return SKAction.repeatForever(blink)
    }
    
    //function to attach nodes on contact
    func joinPhysicsBodies(bodyA:SKPhysicsBody, bodyB:SKPhysicsBody, point:CGPoint)
    {
        joint = SKPhysicsJointFixed.joint(withBodyA: bodyA, bodyB: bodyB, anchor: point)
        self.physicsWorld.add(joint)
    }
}
