//
//  Gameplay.swift
//  ApplianceSmash
//
//  Created by Varsha Ramakrishnan on 7/8/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit
import Mixpanel
import GameKit

class Gameplay: CCNode
{
    enum GameState
    {
        case Playing, GameOver, Paused
    }
    
    var highScore: Int = NSUserDefaults.standardUserDefaults().integerForKey("myHighScore") ?? 0
    {
        didSet
        {
            NSUserDefaults.standardUserDefaults().setInteger(highScore, forKey:"myHighScore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    var timeLeft: Float = 4
    {
        didSet
        {
            timeLeft = max(min(timeLeft, 4), 0)
            lifeBar.scaleX = timeLeft / Float(4)
            let greenVariable = min((timeLeft*2/4), 0.8)
            let redVariable = min(2 - (timeLeft*2/4), 0.8)
            lifeBar.color = CCColor(red: redVariable, green: greenVariable, blue: 0)
        }
    }
    var hitsRemaining: Int = 0
    {
        didSet
        {
            if(hitsRemaining > 0)
            {
                hitsRemainingLabel.color = CCColor(red: 1, green: 1, blue: 1)
                hitsRemainingLabel.string = "\(hitsRemaining)"
            }
            else
            {
                hitsRemainingLabel.color = CCColor(red: 0.8, green: 0.2, blue: 0.2)
                hitsRemainingLabel.string = "0"
            }
        }
    }
    var score: Int = 0
    {
        didSet
        {
            scoreLabel.string = "\(score)"
        }
    }
    
    weak var gamePhysicsNode: CCPhysicsNode!
    weak var scoreLabel: CCLabelTTF!
    weak var hitsRemainingLabel: CCLabelTTF!
    weak var gradientNode: CCNodeGradient!
    weak var swipeLabel: CCLabelTTF!
    weak var tapLabel: CCLabelTTF!
    weak var timeLabel: CCLabelTTF!
    var currentAppliance: Appliance!
    var previousAppliance: Appliance!
    var gameState: GameState!
    var applianceNumberFromBeginning = 1 //for tutorial purposes
    let endOfTutorial = 3 //for tutorial purposes
    weak var lifeBar: CCSprite!
    weak var lifeBarNode: CCNode!
    weak var GOscoreLabel: CCLabelTTF!
    weak var GOhighScoreLabel: CCLabelTTF!
    var audio: OALSimpleAudio = OALSimpleAudio.sharedInstance()
    var mixpanel = Mixpanel.sharedInstance()
    
    func didLoadFromCCB()
    {
        gameState = .Paused
        audio.preloadEffect("Audio/Smash1.wav")
        audio.preloadEffect("Audio/Smash2.wav")
        audio.preloadEffect("Audio/Smash3.wav")
        audio.preloadEffect("Audio/Smash4.wav")
        audio.preloadEffect("Audio/SwooshNoise.wav")
        setupGestures()
        gamePhysicsNode.collisionDelegate = self
    }
    
    override func onEnterTransitionDidFinish()
    {
        super.onEnterTransitionDidFinish()
        self.userInteractionEnabled = true
        summonAppliance()
    }
    
    override func update(delta: CCTime)
    {
        if (gameState == .Playing)
        {
            timeLeft -= Float(delta)
            if timeLeft == 0
            {
                gameOver()
            }
            if applianceNumberFromBeginning < endOfTutorial && hitsRemaining < 1
            {
                tapLabel.visible = false
                swipeLabel.visible = true
            }
            if applianceNumberFromBeginning == endOfTutorial && hitsRemaining < 1
            {
                println("tap label false")
                tapLabel.visible = false
            }
        }
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
        if(gameState == .Paused)
        {
            gameState = .Playing
        }
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
        if(gameState == .Playing)
        {
            if(hitsRemaining < 1)
            {
                gameOver()
            }
            else
            {
                let random = Int(arc4random_uniform(UInt32(4)))
                //audio.playEffect("Audio/Smash\(random).wav", loop: false)
                audio.playEffect("Audio/Smash\(random).wav", volume: 1.0, pitch: 1.0, pan: 0, loop: false)
                currentAppliance.animationManager.runAnimationsForSequenceNamed("tap")
                currentAppliance.makeShatter(hitsRemaining)
                score++
                hitsRemaining--
                timeLeft = timeLeft + 0.25
            }
        }
    }
    
    func gameOver()
    {
        if(gameState == .Playing)
        {
            gameState = .GameOver
            if(score > highScore)
            {
                highScore = score
                reportHighScoreToGameCenter()
            }
            let popup = CCBReader.load("GameOver", owner: self) as! GameOver
            popup.positionType = CCPositionType(xUnit: .Normalized, yUnit: .Normalized, corner: .BottomLeft)
            popup.position = CGPoint(x: 0.5, y: 0.5)
            GOscoreLabel.string = "Score: \(score)"
            GOhighScoreLabel.string = "High Score: \(highScore)"
            mixpanel.track("Game Over", properties: ["Score" : score, "Score Level" : score/10])
            parent.addChild(popup)
        }
    }
    
    func tryAgainButton()
    {
        let gameplayScene = CCBReader.loadAsScene("Gameplay")
        let transition = CCTransition(fadeWithDuration: 0.8)
        CCDirector.sharedDirector().presentScene(gameplayScene, withTransition: transition)
    }
    
    func returnMainMenu()
    {
        let mainMenuScene = CCBReader.loadAsScene("MainScene")
        let transition = CCTransition(fadeWithDuration: 0.8)
        CCDirector.sharedDirector().presentScene(mainMenuScene, withTransition: transition)
    }
    
    func summonAppliance()
    {
        if(previousAppliance != nil)
        {
            previousAppliance.removeFromParentAndCleanup(true)
        }
        if(currentAppliance != nil)
        {
            removeAppliance(currentAppliance)
        }
        
        let numberOfAppliances: Int = 6
        let randomPrecision = UInt32(numberOfAppliances)
        var random = Int(arc4random_uniform(randomPrecision))
        if applianceNumberFromBeginning < endOfTutorial && random == 3
        {
            random = random + 1
        }
        
        var applianceName: String!
        switch(random)
        {
        case 0:
            applianceName = "Television"
        case 1:
            applianceName = "Laptop"
        case 2:
            applianceName = "Phone"
        case 3:
            applianceName = "OilBarrel"
        case 4:
            applianceName = "Dishwasher"
        case 5:
            applianceName = "Microwave"
        default:
            applianceName = "Phone"
        }
        println("summon \(applianceNumberFromBeginning)")
    
        currentAppliance = CCBReader.load("Appliances/\(applianceName)") as! Appliance
        currentAppliance.animationManager.runAnimationsForSequenceNamed("summonAppliance")
        let middleOfScreen = CCDirector.sharedDirector().designSize.width/2
        currentAppliance.position = CGPoint(x: middleOfScreen, y: 219)
        gamePhysicsNode.addChild(currentAppliance)
        hitsRemaining = currentAppliance.numOfHits
    }
    
    func removeAppliance(appliance: Appliance)
    {
        previousAppliance = appliance
    }
    
    func swipe()
    {
        audio.playEffect("Audio/SwooshNoise.wav")
        if applianceNumberFromBeginning < endOfTutorial
        {
            swipeLabel.visible = false
            tapLabel.visible = true
        }
        timeLeft += 0.35
        applianceNumberFromBeginning++
        summonAppliance()
    }
    
    func setupGestures()
    {
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "swipeLeft")
        swipeLeft.direction = .Left
        CCDirector.sharedDirector().view.addGestureRecognizer(swipeLeft)
        
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "swipeRight")
        swipeRight.direction = .Right
        CCDirector.sharedDirector().view.addGestureRecognizer(swipeRight)
        
        var swipeUp = UISwipeGestureRecognizer(target: self, action: "swipeUp")
        swipeUp.direction = .Up
        CCDirector.sharedDirector().view.addGestureRecognizer(swipeUp)
        
        var swipeDown = UISwipeGestureRecognizer(target: self, action: "swipeDown")
        swipeDown.direction = .Down
        CCDirector.sharedDirector().view.addGestureRecognizer(swipeDown)
    }
    
    func swipeLeft()
    {
        if(hitsRemaining < 1)
        {
            currentAppliance.animationManager.runAnimationsForSequenceNamed("removeAppliance")
            swipe()
        }
        else
        {
            gameOver()
        }
    }
    func swipeRight()
    {
        if(hitsRemaining < 1)
        {
            currentAppliance.animationManager.runAnimationsForSequenceNamed("removeApplianceRight")
            swipe()
        }
        else
        {
            gameOver()
        }
    }
    
    func swipeUp() { swipeRight() }
    func swipeDown() { swipeLeft() }
    
    func openGameCenter()
    {
        showLeaderboard()
    }
    
    func reportHighScoreToGameCenter()
    {
        var scoreReporter = GKScore(leaderboardIdentifier: "ApplianceSmashSinglePlayerLeaderBoard")
        scoreReporter.value = Int64(highScore)
        var scoreArray: [GKScore] = [scoreReporter]
        GKScore.reportScores(scoreArray, withCompletionHandler:
        {
            (error : NSError!) -> Void in
            if error != nil
            {
                println("Game Center: Score Submission Error")
            }
            else
            {
                println("YAY HIGH SCORE REPORTED")
            }
        })
    }
}

// MARK: Game Center Handling
extension Gameplay: GKGameCenterControllerDelegate
{
    func showLeaderboard()
    {
        var viewController = CCDirector.sharedDirector().parentViewController!
        var gameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        gameCenterViewController.viewState = GKGameCenterViewControllerState.Leaderboards
        gameCenterViewController.leaderboardIdentifier = "ApplianceSmashSinglePlayerLeaderBoard"
        viewController.presentViewController(gameCenterViewController, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
