//
//  CameraOverlayView.swift
//  Homepwner
//
//  Created by Spencer Greene on 7/4/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import UIKit

class CameraOverlayView: UIView {
    
    let path = UIBezierPath()

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        
        self.backgroundColor = UIColor.clear
        
        // Initialization code
        path.move(to: frame.center - CGPoint(x: 5, y: 0))
        path.addLine(to: frame.center + CGPoint(x: 5, y: 0))
        path.move(to: frame.center - CGPoint(x: 0, y: 5))
        path.addLine(to: frame.center + CGPoint(x: 0, y: 5))
        
        path.lineWidth = 1.0

    }
    
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect)
    {
        // super.drawRect(rect)
        // Drawing code
        UIColor.red.setStroke()
        path.stroke()
    }
    

}

extension CGRect {
    var center: CGPoint {
    let x = self.origin.x + self.size.width / 2
        let y = self.origin.y + self.size.height / 2
        return CGPoint(x: x, y: y)
    }
}


func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

