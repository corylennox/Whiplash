//
//  GameScene.swift
//  ProjectNoName
//
//  Created by Julio "Jay Palm" Hernandez on 12/15/16.
//  Copyright © 2016 Palm Studios. All rights reserved.
//

import SpriteKit
import GameplayKit
import GoogleMobileAds

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

        getConstants()
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
        if let touch = touches.first
        {
            let pos = touch.location(in: self)
            let node = self.atPoint(pos)
            
            if node == menuButton
            {
                restart()
            }
        }
        if !gameIsStarted
        {
            start()
        }
        
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
        if scoreLabel.scoreChanged == true && scoreLabel.number < 80
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
        border = SKPhysicsBody(edgeLoopFrom: self.frame)
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
        scoreLabel.position = CGPoint(x: 35.0 * SCALE, y: view!.frame.size.height - 35 * SCALE)
        scoreLabel.name = "scoreLabel"
        addChild(scoreLabel)
        
        //high score
        highScoreLabel = ScoreLabel(num: 0)
        highScoreLabel.name = "highScoreLabel"
        highScoreLabel.position = CGPoint(x: view!.frame.size.width - 35 * SCALE, y: view!.frame.size.height - 35 * SCALE)
        addChild(highScoreLabel)
        
        let highscoreTextLabel = SKLabelNode(text: "High")
        highscoreTextLabel.fontColor = UIColor.black
        highscoreTextLabel.fontSize = 14.0
        highscoreTextLabel.fontName = "Helvetica"
        highscoreTextLabel.position = CGPoint(x: 0, y: -20)
        highScoreLabel.addChild(highscoreTextLabel)
    }
    
    func loadHighscore() {
        let defaults = UserDefaults.standard
        
        let highScoreLabel = childNode(withName: "highScoreLabel") as! ScoreLabel
        highScoreLabel.setTo(defaults.integer(forKey: "highscore"))
    }

    func addTapToStartLabel()
    {
        let tapToStartLabel = SKLabelNode(text: "Tap to start!")
        tapToStartLabel.name = "tapToStartLabel"
        tapToStartLabel.position.x = view!.center.x
        tapToStartLabel.position.y = view!.center.y + 40
        tapToStartLabel.fontName = "Helvetica"
        tapToStartLabel.fontColor = UIColor.white
        tapToStartLabel.fontSize = 35.0
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
    
    func restart()
    {
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadAndShow"), object: nil)
        let newScene = GameScene(size: size)
        newScene.scaleMode = .aspectFill
        view!.presentScene(newScene)
    }
    
    func gameOver()
    {
        // stop everything
        self.isPaused = true
        
        gameIsOver = true
        
        // create game over label
        let gameOverLabel = SKLabelNode(text: "Game Over!")
        gameOverLabel.fontColor = UIColor.white
        gameOverLabel.fontName = "Helvetica"
        gameOverLabel.position.x = view!.center.x
        gameOverLabel.position.y = view!.center.y + 40
        gameOverLabel.fontSize = 35.0
        addChild(gameOverLabel)
        gameOverLabel.run(blinkAnimation())
        
        let defaults = UserDefaults.standard
        let oldHighScore = defaults.integer(forKey: "highscore")
        
        if oldHighScore < highScoreLabel.number
        {
            defaults.set(highScoreLabel.number, forKey: "highscore")
        }
        
        addMenu()
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
    
    func addMenu()
    {
        let texture = SKTexture(imageNamed: "platform1")
        let sizeTexture = CGSize(width: texture.size().width, height: texture.size().width)
        menuButton = SKSpriteNode(texture: texture, color: UIColor.clear, size: sizeTexture)
        menuButton.position = CGPoint(x: frame.midX, y: frame.midY)
        self.addChild(menuButton)
    }
    
    func getConstants()
    {
        SCALE = size.height/736

        //Ball
        BALL_MASS = 0.02
        BALL_RADIUS = 12.9 * SCALE
        BALL_SPEED = 10 * SCALE
        
        //Platforms
        //print(size.width, "x", size.height)
        PLATFORM_RADIUS = 50 * SCALE
        PLATFORM_TURN_POINT = PLATFORM_RADIUS + 2 * BALL_RADIUS + (5 * SCALE)
        STARTING_DISTANCE_FROM_BOTTOM = 100 * SCALE
        PLATFORM_DESCENT_SPEED = 120 * SCALE
        
        //Base platform variables:
        PLATFORM_ROTATION_SPEED = 0.8
        PLATFORM_LATERAL_SPEED = 38 * SCALE
        PLATFORM_DISTANCE_APART = 260 * SCALE
        
        ANCHOR_DISTANCE = BALL_RADIUS + PLATFORM_RADIUS
    }
}
