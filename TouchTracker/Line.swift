//
//  Line.swift
//  TouchTracker
//
//  Created by Spencer Greene on 7/5/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import Foundation
import UIKit

class Line: TTShape {
    
    var begin = CGPoint(x: 0, y: 0)
    var end = CGPoint(x: 0, y: 0)
    
    let pi = Float(M_PI)

    var angle: CGFloat {
    get {
        let xdelt = end.x - begin.x
        let ydelt = end.y - begin.y
        var theta = Float(atan(Double(abs(ydelt / xdelt))))
        var result: CGFloat = 0.0
        
        switch(xdelt >= 0.0, ydelt >= 0.0) {
        case (true, true):
            result = CGFloat(theta)
        case (true, false):
            result = CGFloat((2.0*pi - theta))
        case (false, true):
            result = CGFloat(pi - theta)
        case (false, false):
            result = CGFloat(pi + theta)
        default:
            assert(false, "line get(angle): switch reached unreachable statement")
        }
        return(result)
    }
    }
    
    override func pointAlongShape(t: Double) -> CGPoint  {
        let xAlong = begin.x + CGFloat(t) * (end.x - begin.x)
        let yAlong = begin.y + CGFloat(t) * (end.y - begin.y)
        return CGPoint(x: xAlong, y: yAlong)
    }
    
    override func translateBy(vector: CGPoint) {
        self.begin = self.begin + vector
        self.end = self.end + vector
    }
    
    override init() {
        super.init()
        self.isLine = true
    }
    
    deinit {
        NSLog("Line being deallocated")
    }
   
}
