//
//  Appliance.swift
//  ApplianceSmash
//
//  Created by Varsha Ramakrishnan on 7/8/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Appliance: CCSprite
{
    var numOfHits: Int = 0
    weak var image: CCNode!
    
    func makeFire(fireNumber: Int)
    {
        let currentFire = CCBReader.load("Fire", owner: self) as! CCParticleSystem!
        let x = Int(arc4random_uniform(UInt32(image.contentSize.width)))
        let y = Int(arc4random_uniform(UInt32(image.contentSize.height/2)))
        //println()
        currentFire.position = CGPoint(x: x,y: y)
        currentFire.scaleX = 0.75/Float(fireNumber)
        currentFire.scaleY = 0.75/Float(fireNumber)
        image.addChild(currentFire)
    }
}
