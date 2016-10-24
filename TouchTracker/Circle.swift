//
//  Circle.swift
//  TouchTracker
//
//  Created by Spencer Greene on 7/6/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import Foundation
import UIKit

class Circle: TTShape {
    var corner1 = CGPoint(x: 0, y: 0)
    var corner2 = CGPoint(x: 0, y: 0)
    
    weak var key1 = NSValue()
    weak var key2 = NSValue()
    
    var currentTouches = 0
    
    func updateCorner(c: CGPoint, key: NSValue) {
        if (key == key1) {
            corner1 = c
        } else if (key == key2) {
            corner2 = c
        } else {
            assert(false, "Circle.updateCorner for invalid key")
        }
    }
    
    override func pointAlongShape(t: Double) -> CGPoint  {
        let theta = t * M_PI * 2.0
        
        let x1 = cos(theta) * Double(self.radius)
        let x2 = CGFloat(x1) + center.x
        
        let y1 = sin(theta) * Double(self.radius)
        let y2 = CGFloat(y1) + center.y
        
        return CGPoint(x: x2 , y: y2)
    }
    
    override func translateBy(vector: CGPoint) {
        corner1 = corner1 + vector
        corner2 = corner2 + vector
    }
    
    // MARK: computed properties
    var center: CGPoint {
    return CGPoint(x: (corner1.x + corner2.x) / 2.0,
            y: (corner1.y + corner2.y) / 2.0)
    }
    
    var xsize: CGFloat {
    let xdelt = CGFloat(corner1.x - corner2.x)
    return abs(xdelt)
    }
    
    var ysize: CGFloat {
    let ydelt = CGFloat(corner1.y - corner2.y)
    return abs(ydelt)
    }
    
    var radius: CGFloat {
    let r = min(xsize, ysize) / 2.0
    return CGFloat(r)
    }
    
    var begin: CGPoint {
    get {
        if (xsize <= ysize) {
            // use x as-is; constrain y
            return CGPoint(x: max(corner1.x, corner2.x), y: center.y)
        } else {
            // constrain x; use y as-is
            return CGPoint(x: center.x + ysize/2.0, y: center.y)
        }
        
    }
    }
    
    var corner12: CGPoint {
    return CGPoint(x: corner1.x, y: corner2.y)
    }
    
    var corner21: CGPoint {
    return CGPoint(x: corner2.x, y: corner1.y)
    }
    
    // #pragma mark - initialization
    init(corner1: CGPoint, corner2: CGPoint) {
        self.corner1 = corner1
        self.corner2 = corner2
        super.init()
        self.isCircle = true
    }
    
    convenience override init() {
        self.init(corner1: CGPointZero, corner2: CGPointZero)
    }
}


func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

