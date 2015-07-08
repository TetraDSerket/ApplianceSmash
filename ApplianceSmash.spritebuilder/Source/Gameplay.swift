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
    var currentAppliance: Appliance!
    var gameState: GameState!
    var hitsRemaining: Int = 0
    {
        didSet
        {
            hitsRemainingLabel.string = "\(hitsRemaining)"
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
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
//        println("IM TOUCHED")
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
        if(gameState == .Playing)
        {
            println("DONT LEAVE ME YOU SELFLESS PIE")
            if(hitsRemaining < 1)
            {
                gameOver()
            }
            score++
            hitsRemaining--
        }
    }
    
    func gameOver()
    {
        println("gameOver")
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
        currentAppliance = CCBReader.load("Appliances/Television") as! Appliance
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
        println("swipe Left")
        if(hitsRemaining < 1)
        {
            summonAppliance()
        }
        else
        {
            gameOver()
        }
    }
    
    func swipeRight() {
        println("Right swipe!")
    }
    
    func swipeUp() {
        println("Up swipe!")
    }
    
    func swipeDown() {
        println("Down swipe!")
    }
}
