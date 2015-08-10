//
//  Tutorial.swift
//  ApplianceSmash
//
//  Created by Varsha Ramakrishnan on 7/10/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Tutorial: CCNode
{
    enum GameState
    {
        case Tutorial, Practice, GameOver
    }
    
    weak var gamePhysicsNode: CCPhysicsNode!
    weak var scoreLabel: CCLabelTTF!
    weak var hitsRemainingLabel: CCLabelTTF!
    weak var swipeLabel: CCLabelTTF!
    weak var tapLabel: CCLabelTTF!
    weak var timeLabel: CCLabelTTF!
    weak var barrelLabel: CCLabelTTF!
    weak var tooMuchLabel: CCLabelTTF!
    var currentAppliance: Appliance!
    var previousAppliance: Appliance!
    var gameState: GameState!
    var turnsInTutorial: Int = 0
    var popup: GameOver!
    weak var lifeBar: CCSprite!
    weak var lifeBarNode: CCNode!
    var timeLeft: Float = 8
    {
        didSet
        {
            timeLeft = max(min(timeLeft, 8), 0)
            lifeBar.scaleX = timeLeft / Float(8)
        }
    }
    
    var hitsRemaining: Int = 0
    {
        didSet
        {
            if(hitsRemaining > -1)
            {
                hitsRemainingLabel.string = "\(hitsRemaining)"
            }
            else
            {
                hitsRemainingLabel.string = "0"
            }
        }
    }

    func didLoadFromCCB()
    {
        setupGestures()
        gamePhysicsNode.collisionDelegate = self
    }
    
    override func onEnterTransitionDidFinish()
    {
        super.onEnterTransitionDidFinish()
        self.userInteractionEnabled = true
        gameState = .Tutorial
        summonAppliance()
    }
    
    override func update(delta: CCTime)
    {
        if (turnsInTutorial>5)
        {
            timeLeft -= Float(delta)
            if timeLeft == 0
            {
                gameOver()
            }
        }
        if(gameState == .Tutorial)
        {
            if(hitsRemaining == 0)
            {
                timeLabel.visible = false
                swipeLabel.visible = true
            }
            switch(turnsInTutorial)
            {
            case 0:
                tapLabel.visible = true
            case 5:
                tapLabel.visible = false
            case 6:
                timeLabel.visible = true
            case 11:
                tooMuchLabel.visible = true
            default:
                return
            }
        }
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
        if(gameState == .Tutorial)
        {
            println(turnsInTutorial)
            if(hitsRemaining > 0)
            {
                turnsInTutorial++
            }
        }
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
        if(gameState == .Practice)
        {
            if(hitsRemaining < 1)
            {
                gameOver()
            }
            currentAppliance.animationManager.runAnimationsForSequenceNamed("tap")
            currentAppliance.makeShatter(hitsRemaining)
//            score++
            hitsRemaining--
            timeLeft = timeLeft + 0.25
        }
        if(gameState == .Tutorial)
        {
            currentAppliance.animationManager.runAnimationsForSequenceNamed("tap")
            currentAppliance.makeShatter(hitsRemaining)
            if(hitsRemaining > 0)
            {
//                score++
                hitsRemaining--
                timeLeft = timeLeft + 0.25
            }
        }
    }
    
    func gameOver()
    {
        if(gameState == .Tutorial)
        {
            gameState = .GameOver
            let popup = CCBReader.load("GameOverT", owner: self) as! GameOver
            popup.positionType = CCPositionType(xUnit: .Normalized, yUnit: .Normalized, corner: .BottomLeft)
            popup.position = CGPoint(x: 0.5, y: 0.5)
            self.popup = popup
            parent.addChild(popup)
        }
    }
    
    func tryAgainButton()
    {
        //gameState = .Tutorial
//        let gameplayScene = CCBReader.loadAsScene("Tutorial")
//        let transition = CCTransition(fadeWithDuration: 0.8)
//        CCDirector.sharedDirector().presentScene(gameplayScene, withTransition: transition)
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
        
        let numberOfAppliances: Int = 4
        let randomPrecision = UInt32(numberOfAppliances)
        let random = Int(arc4random_uniform(randomPrecision))
        
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
            applianceName = "Laptop"
        default:
            applianceName = "Laptop"
        }
        if(turnsInTutorial<10)
        {
            applianceName = "Television"
        }
        
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
    
    func dealWithSuccessfulSwipe()
    {
        if(gameState == .Tutorial)
        {
            swipeLabel.visible = false
            turnsInTutorial++
        }
        summonAppliance()
        timeLeft += 0.25
    }
    
    func swipeLeft()
    {
        if(hitsRemaining < 1)
        {
            currentAppliance.animationManager.runAnimationsForSequenceNamed("removeAppliance")
            dealWithSuccessfulSwipe()
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
            dealWithSuccessfulSwipe()
        }
        else
        {
            gameOver()
        }
    }
    
    func returnToMainMenu()
    {
        let mainMenuScene = CCBReader.loadAsScene("MainScene")
        let transition = CCTransition(fadeWithDuration: 0.8)
        CCDirector.sharedDirector().presentScene(mainMenuScene, withTransition: transition)
    }
    
    func swipeUp() { swipeLeft() }
    func swipeDown() { swipeLeft() }
}
