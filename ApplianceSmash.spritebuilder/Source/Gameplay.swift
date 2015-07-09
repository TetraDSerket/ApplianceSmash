//
//  Gameplay.swift
//  ApplianceSmash
//
//  Created by Varsha Ramakrishnan on 7/8/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Gameplay: CCNode
{
    enum GameState
    {
        case Ready, Playing, GameOver
    }
    
    weak var gamePhysicsNode: CCPhysicsNode!
    weak var scoreLabel: CCLabelTTF!
    weak var hitsRemainingLabel: CCLabelTTF!
    let numberOfAppliances: Int = 3
    var currentAppliance: Appliance!
    var gameState: GameState!
    weak var lifeBar: CCSprite!
    weak var lifeBarNode: CCNode!
    var timeLeft: Float = 5
    {
        didSet
        {
            timeLeft = max(min(timeLeft, 5), 0)
            lifeBar.scaleX = timeLeft / Float(5)
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
    var score: Int = 0
    {
        didSet
        {
            scoreLabel.string = "\(score)"
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
        summonAppliance()
        gameState = .Playing
    }
    
    override func update(delta: CCTime)
    {
        if gameState != .Playing { return }
        timeLeft -= Float(delta)
        if timeLeft == 0
        {
            gameOver()
        }
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!)
    { }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
        if(gameState == .Playing)
        {
            if(hitsRemaining < 1)
            {
                gameOver()
            }
            currentAppliance.animationManager.runAnimationsForSequenceNamed("tap")
            score++
            hitsRemaining--
            timeLeft = timeLeft + 0.5
        }
    }
    
    func gameOver()
    {
        gameState = .GameOver
        let popup = CCBReader.load("GameOver", owner: self) as! GameOver
        popup.positionType = CCPositionType(xUnit: .Normalized, yUnit: .Normalized, corner: .BottomLeft)
        popup.position = CGPoint(x: 0.5, y: 0.5)
        parent.addChild(popup)
    }
    
    func tryAgainButton()
    {
        let gameplayScene = CCBReader.loadAsScene("Gameplay")
        let transition = CCTransition(fadeWithDuration: 0.8)
        CCDirector.sharedDirector().presentScene(gameplayScene, withTransition: transition)
    }
    
    func summonAppliance()
    {
        if(currentAppliance != nil)
        {
            removeAppliance(currentAppliance)
        }
        
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
        default:
            applianceName = "Television"
        }
        
        currentAppliance = CCBReader.load("Appliances/\(applianceName)") as! Appliance
        currentAppliance.animationManager.runAnimationsForSequenceNamed("summonAppliance")
        currentAppliance.position = CGPoint(x: 160, y: 219)
        gamePhysicsNode.addChild(currentAppliance)
        hitsRemaining = currentAppliance.numOfHits
    }
    
    func removeAppliance(appliance: Appliance)
    {
        appliance.animationManager.runAnimationsForSequenceNamed("removeAppliance")
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
            summonAppliance()
        }
        else
        {
            gameOver()
        }
    }
    func swipeRight() { }
    func swipeUp() { }
    func swipeDown() { }
}
