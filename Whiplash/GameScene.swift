//
//  GameScene.swift
//  ProjectNoName
//
//  Created by Julio "Jay Palm" Hernandez on 12/15/16.
//  Copyright © 2016 Palm Studios. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate
{
    //member variables
    var platformGenerator: PlatformGenerator!
    var currentPlatform: SKNode?
    var ball: SKShapeNode!
    var border: SKPhysicsBody!
    var joint = SKPhysicsJointFixed()
    
    var scoreLabel: ScoreLabel!
    var highScoreLabel: ScoreLabel!
    var isStarted = false
    var isGameOver = false
    
    override func didMove(to view: SKView)
    {
        
        //size = CGSize(width: size.width, height: size.height - AD_HEIGHT)
        
        backgroundColor = SKColor.lightGray

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
        if isGameOver
        {
            restart()
        }
        else if !isStarted
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
                
                let magnitude: CGFloat = ANCHOR_RADIUS/c
                
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
        if (bottomPlatform?.position.y)! + ANCHOR_RADIUS < AD_HEIGHT
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
            platformGenerator.rotationSpeed = platformGenerator.calcNewRotationSpeed(score: scoreLabel.number)
            platformGenerator.lateralSpeed = platformGenerator.calcNewLateralSpeed(score: scoreLabel.number)
            platformGenerator.distanceApart = platformGenerator.calcNewDistanceApart(score: scoreLabel.number)
            
            scoreLabel.scoreChanged = false;
        }
    }
    
    func addPhysicsWorld()
    {
        physicsWorld.contactDelegate = self
    }
    
    func addBorder()
    {
        let frame = CGRect(x: 0, y: AD_HEIGHT, width: self.frame.size.width, height: self.frame.size.height - AD_HEIGHT)
        border = SKPhysicsBody(edgeLoopFrom: frame)
        border.categoryBitMask = CollisionCategoryBitMask.Border
        border.contactTestBitMask = CollisionCategoryBitMask.Ball
        border.collisionBitMask = 0
        self.physicsBody = border
    }
    
    func addPlatformGenerator()
    {
        platformGenerator = PlatformGenerator(color: UIColor.clear, size: view!.frame.size)
        addChild(platformGenerator)
    }
    
    func addBall()
    {
        ball = SKShapeNode(circleOfRadius: BALL_RADIUS)
        ball.fillColor = UIColor.white
        ball.strokeColor = UIColor.darkGray
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: BALL_RADIUS)
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.usesPreciseCollisionDetection = true
        ball.physicsBody?.categoryBitMask = CollisionCategoryBitMask.Ball
        ball.physicsBody?.contactTestBitMask = CollisionCategoryBitMask.Platform
        ball.physicsBody?.collisionBitMask = 0
        ball.physicsBody?.affectedByGravity = false
        
        let startingPlat: Platform = platformGenerator.platforms[0]
        
        let x: CGFloat = size.width / 2
        let y: CGFloat = startingPlat.position.y + ANCHOR_RADIUS
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
        scoreLabel.position = CGPoint(x: 35.0, y: view!.frame.size.height - 35)
        scoreLabel.name = "scoreLabel"
        addChild(scoreLabel)
        
        //high score
        highScoreLabel = ScoreLabel(num: 0)
        highScoreLabel.name = "highScoreLabel"
        highScoreLabel.position = CGPoint(x: view!.frame.size.width - 35, y: view!.frame.size.height - 35)
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
        isStarted = true
        
        let tapToStartLabel = childNode(withName: "tapToStartLabel")
        tapToStartLabel?.removeFromParent()
        
        for platform in platformGenerator.platforms
        {
            platform.startMovingLong()
        }
        
    }
    
    func restart()
    {
        let newScene = GameScene(size: view!.bounds.size)
        newScene.scaleMode = .aspectFill
        view!.presentScene(newScene)
    }
    
    func gameOver()
    {
        isGameOver = true
        
        // stop everything
        for platform in platformGenerator.platforms
        {
            platform.stopActions()
        }
        
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
