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
    func pointAlongShape(_ t: Double) -> CGPoint {
        assert(false, "pointAlongShape should be overridden")
        return CGPoint.zero
    }
    
    func translateBy(_ vector: CGPoint) {
        assert(false, "translateBy should be overridden")
    }
    
    func closeTo(_ p: CGPoint) -> Bool {
        var t = 0.0
        while (t <= 1.0) {
            let shapePoint = pointAlongShape(t)
            
            let xdelt = p.x - shapePoint.x
            let ydelt = p.y - shapePoint.y
            
            if (hypot(Double(xdelt), Double(ydelt)) < closeThresholdPoints) {
                return true
            }
            t = t + 0.05
        }
        return false
    }
   
}
