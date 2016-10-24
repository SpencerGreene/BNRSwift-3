//
//  HypnosisView-triangle.swift
//  Hypnosister
//
//  Created by Spencer Greene on 6/28/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import UIKit

// the built-in hypot function only works on Double, need one that works on CGFloat
func hypot(x1: CGFloat, x2: CGFloat) -> CGFloat {
    let square = x1*x1 + x2*x2
    let hyp = sqrt(square)
    return(hyp)
}

class HypnosisView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        // Initialization code
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    func makeTriangle(context: CGContext, span:CGRect) {
        let gradientLocations: Array<CGFloat>  = [0.0, 1.0]
        let gradientComponents: Array<CGFloat> = [0.0, 1.0, 0.0, 1.0,   // start green
            1.0, 1.0, 0.0, 1.0]                         // end yellow
        
        let triPath = UIBezierPath()
        
        let gradientColorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorSpace: gradientColorSpace, colorComponents: gradientComponents, locations: gradientLocations, count: 2)
        
        let startPoint = CGPoint(x: span.origin.x + span.size.width / 2.0,
            y: span.origin.y)
        let endPoint = CGPoint(x: startPoint.x,
            y: startPoint.y + span.size.height)
        
        context.saveGState()
        
        triPath.move(to: CGPoint(x:span.origin.x + span.size.width/2.0, y:span.origin.y))
        triPath.addLine(to: CGPoint(x:span.origin.x, y:span.origin.y+span.size.height))
        triPath.addLine(to: CGPoint(x:span.origin.x+span.size.width, y:span.origin.y+span.size.height))
        triPath.close()
        triPath.addClip()
        
        context.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        
        context.restoreGState()
        
        // CGGradientRelease(gradient)
        // CGColorSpaceRelease(gradientColorSpace)
    }
    
    func makeImage(context: CGContext) {
        
        let logoImage = UIImage(named:"logo.png")
        let vertMargin: CGFloat = 1.5 * 72.0     // half inch in points
        let horzMargin: CGFloat = 0.75 * 72.0    // quarter inch in points
        
        let origin = CGPoint(x: self.bounds.origin.x + horzMargin, y: self.bounds.origin.y + vertMargin)
        let size = CGSize(width: self.bounds.size.width - 2.0 * horzMargin,
            height: self.bounds.size.height - 2.0 * vertMargin)
        let imgRect = CGRect(origin: origin, size: size)
        
        makeTriangle(context: context, span: imgRect)
        
        context.saveGState()
        // context.setShadow(offset: CGSizeMake(4, 7), blur: 2)
        logoImage?.draw(in: imgRect)
        context.restoreGState()
        
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect)
    {

        // Drawing code
        let bounds = self.bounds
        let center = CGPoint(x: bounds.origin.x + bounds.size.width / 2.0,
            y: bounds.origin.y + bounds.size.height / 2.0)

        let maxRadius = hypot(bounds.size.width, bounds.size.height) / 2.0
        let twoPi = CGFloat(M_PI * 2.0)
        
        let path = UIBezierPath()
        path.lineWidth = 10
        UIColor.clear.setStroke()
        
        var currentRadius = maxRadius
        while currentRadius > 0.0 {
            path.move(to: CGPoint(x: center.x + currentRadius, y: center.y))
            path.addArc(withCenter: center, radius: currentRadius, startAngle: 0.0, endAngle: twoPi, clockwise: true)
            currentRadius = currentRadius - 20.0
        }
        
        path.stroke()
        
        // makeImage(UIGraphicsGetCurrentContext())

        
    }
    

}
