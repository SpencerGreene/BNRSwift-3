//
//  TTShape.swift
//  TouchTracker
//
//  Created by Spencer Greene on 7/12/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import UIKit

class TTShape: NSObject {
    var isLine = false
    var isCircle = false
    var finished = false

    let closeThresholdPoints = 20.0
    
    // return a point somewhere on the shape - as t walks from 0 to 1 should trace entire shape
    func pointAlongShape(t: Double) -> CGPoint {
        assert(false, "pointAlongShape should be overridden")
        return CGPointZero
    }
    
    func translateBy(vector: CGPoint) {
        assert(false, "translateBy should be overridden")
    }
    
    func closeTo(p: CGPoint) -> Bool {
        for (var t = 0.0; t <= 1.0; t += 0.05) {
            let shapePoint = pointAlongShape(t)
            
            let xdelt = p.x - shapePoint.x
            let ydelt = p.y - shapePoint.y
            
            if (hypot(Double(xdelt), Double(ydelt)) < closeThresholdPoints) {
                return true
            }
        }
        return false
    }
   
}
