//
//  HypnosisView.swift
//  Hypnosister
//
//  Created by Spencer Greene on 6/28/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import Foundation
import UIKit

// the built-in hypot function only works on Double, need one that works on CGFloat
func hypot(x1: CGFloat, x2: CGFloat) -> CGFloat {
    let square = Double(x1*x1 + x2*x2)
    let hyp = sqrt(square)
    return(CGFloat(hyp))
}

class HypnosisView: UIView {
    
    var circleColor = UIColor.green
    
    class func randomColor() -> UIColor {
        func r1() -> CGFloat {
            let rInt = Int(arc4random_uniform(100))
            let rFloat = CGFloat(rInt) / 100.0
            return(rFloat)
        }
        
        let color = UIColor(red:r1(), green:r1(), blue:r1(), alpha:1.0)
        return(color)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        // Initialization code
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let bounds = self.bounds
        let center = CGPoint(x: bounds.origin.x + bounds.size.width / 2.0,
            y: bounds.origin.y + bounds.size.height / 2.0)

        let maxRadius = hypot(bounds.size.width, bounds.size.height) / 2.0
        let twoPi = CGFloat(M_PI * 2.0)
        
        let path = UIBezierPath()
        path.lineWidth = 10
        self.circleColor.setStroke()

        var currentRadius = maxRadius
        while currentRadius > 0.0 {
            path.move(to: CGPoint(x: center.x + currentRadius, y: center.y))
            path.addArc(withCenter: center, radius: currentRadius, startAngle: 0.0, endAngle: twoPi, clockwise: true)
            currentRadius = currentRadius - 20.0
        }
        
        path.stroke()
        
    }
    
    /*
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        NSLog("%@ was touched", self)
        self.circleColor = HypnosisView.randomColor()
        self.setNeedsDisplay()
    }
    */
    

}
