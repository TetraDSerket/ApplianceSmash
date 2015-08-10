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
    weak var clippingNode: CCClippingNode!
    weak var stencil: CCNode!
    
    func didLoadFromCCB()
    {
        println("loaded")
        clippingNode.stencil = stencil
        clippingNode.alphaThreshold = 0.0
    }
//    func makeFire(fireNumber: Int)
//    {
//        if(fireNumber%2 == 1)
//        {
//            let currentFire = CCBReader.load("Fire", owner: self) as! CCParticleSystem!
//            let x = Int(arc4random_uniform(UInt32(image.contentSize.width)))
//            let y = Int(arc4random_uniform(UInt32(image.contentSize.height/2)))
//            //println()
//            currentFire.position = CGPoint(x: x,y: y)
//            currentFire.scaleX = 0.75/Float(fireNumber)
//            currentFire.scaleY = 0.75/Float(fireNumber)
//            image.addChild(currentFire)
//        }
//    }
    
    func makeShatter(shatterNumber: Int)
    {
        let currentShatter = CCBReader.load("CrackedGlass", owner: self) as CCNode!
        let width = Float(image.contentSize.width) //* image.scaleX
        let height = Float(image.contentSize.height) //* image.scaleY
        //println("w: \(width) h: \(height)")
        let x = Int(arc4random_uniform(UInt32(width/2))) + Int(width/4)
        let y = Int(arc4random_uniform(UInt32(height/2))) + Int(height/4)
        currentShatter.position = CGPoint(x: x, y: y)
        let scalex = Float(image.contentSize.width) * image.scaleX
        let scaley = Float(image.contentSize.height) * image.scaleY
        currentShatter.scaleX = 0.8
        currentShatter.scaleY = 0.8
        currentShatter.rotation = Float(arc4random_uniform(UInt32(360)))
        clippingNode.addChild(currentShatter)
    }
}
