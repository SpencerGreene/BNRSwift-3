//
//  TempDrawView.swift
//  TouchTracker
//
//  Created by Spencer Greene on 8/20/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import UIKit

class DrawViewY: UIView {
    
    enum SelectedFor {
        case Move
        case Delete
        case Draw
        case Nothing
    }
    
    var currentLines: Dictionary<NSValue, Line> = [:]
    var finishedShapes: Array<TTShape> = []
    
    // both corners are indexed to the current circle
    var currentCircles: Dictionary<NSValue, Circle> = [:]
    
    var lineWidthTemporary: CGFloat = 5.0
    let circleWidthTemporary: CGFloat = 5.0
    let lineWidthPermanent: CGFloat = 10.0
    
    weak var selectedShape:TTShape? = nil
    var selectedFor = SelectedFor.Nothing
    
    var moveRecognizer: UIPanGestureRecognizer? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.grayColor()
        self.multipleTouchEnabled = true
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "doubleTap:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delaysTouchesBegan = true
        self.addGestureRecognizer(doubleTapRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "tap:")
        tapRecognizer.delaysTouchesBegan = true
        tapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
        self.addGestureRecognizer(tapRecognizer)
        
        let longRecognizer = UILongPressGestureRecognizer(target: self, action: "longPress:")
        self.addGestureRecognizer(longRecognizer)
        
        self.moveRecognizer = UIPanGestureRecognizer(target: self, action: "moveLine:")
        // self.moveRecognizer!.delegate = self
        self.moveRecognizer!.cancelsTouchesInView = false
        self.addGestureRecognizer(self.moveRecognizer!)
        
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

}

// Rendering the current state
extension DrawView {

    // Drawing
    func setLineStyleForPath(path: UIBezierPath, temporary: Bool) {
        path.lineCapStyle = kCGLineCapRound
        if (temporary) {
            path.lineWidth = self.lineWidthTemporary
            path.setLineDash([6.0, 12.0], count: 2, phase: 0)
        } else {
            path.lineWidth = self.lineWidthPermanent
        }
    }
    
    func strokeLine(line: Line, temporary: Bool) {
        // println("\(__FUNCTION__) temporary=\(temporary)")
        let bp = UIBezierPath()
        
        setLineStyleForPath(bp, temporary: temporary)
        
        bp.moveToPoint(line.begin)
        bp.addLineToPoint(line.end)
        bp.stroke()
    }
    
    func strokeCircle(circle: Circle, temporary: Bool) {
        let bp = UIBezierPath()
        
        setLineStyleForPath(bp, temporary: temporary)
        if (temporary) { bp.lineWidth = circleWidthTemporary }
        bp.moveToPoint(circle.begin)
        bp.addArcWithCenter(circle.center, radius: circle.radius, startAngle: 0.0, endAngle: CGFloat(M_PI * 2.0), clockwise: true)
        bp.stroke()
        
        if (temporary) {
            let rp = UIBezierPath()
            rp.moveToPoint(circle.corner1)
            rp.addLineToPoint(circle.corner12)
            rp.addLineToPoint(circle.corner2)
            rp.addLineToPoint(circle.corner21)
            rp.addLineToPoint(circle.corner1)
            rp.lineWidth = 2
            rp.stroke()
        }
    }
    
    
    func strokeShape(shape: TTShape, temporary: Bool, selected: Bool) {
        if (temporary) {
            UIColor.redColor().setStroke()
        } else if (selected) {
            if (selectedFor == SelectedFor.Delete) { UIColor.greenColor().setStroke() }
            else if (selectedFor == SelectedFor.Move) { UIColor.yellowColor().setStroke() }
        } else {
            UIColor.blackColor().setStroke()
            // setAngleColor(line)
        }
        
        if (shape.isLine) {
            let line = shape as Line
            strokeLine(line, temporary: temporary)
        }
        if (shape.isCircle) {
            let circle = shape as Circle
            strokeCircle(circle, temporary: temporary)
        }
    }

    
    // ch12 Silver: set color of line based on angle of line
    func setAngleColor(line: Line) {
        
        let hue = CGFloat(Double(line.angle) / (2*M_PI))
        UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0).setStroke()
    }
    
    override func drawRect(rect: CGRect) {
        // NSLog("\(__FUNCTION__)")
        
        // finished lines in color determined by angle (ch12 Silver)
        for shape in finishedShapes {
            strokeShape(shape, temporary: false, selected: false)
        }
        
        // current lines in red, if any
        for (key, line) in currentLines {
            strokeShape(line, temporary: true, selected: false)
        }
        
        for (key, circle) in currentCircles {
            strokeShape(circle, temporary:true, selected: false)
        }
        
        if let shape = selectedShape {
            strokeShape(shape, temporary: false, selected: true)
        }
        
    }
    
}

// Converting touches to shapes
extension DrawView {
    func processNewCircle(circleBeginTouches: [UITouch]) {
        NSLog("\(__FUNCTION__)")
        
        let currentTouches = circleBeginTouches.count
        assert(currentTouches == 2, "beginning circle that doesn't have 2 touches?")
        
        let corner1 = circleBeginTouches[0].locationInView(self)
        let corner2 = circleBeginTouches[1].locationInView(self)
        let key1 = NSValue(nonretainedObject: circleBeginTouches[0])
        let key2 = NSValue(nonretainedObject: circleBeginTouches[1])
        
        let circle = Circle(corner1: corner1, corner2: corner2)
        circle.key1 = key1
        circle.key2 = key2
        
        circle.currentTouches = currentTouches
        
        
        // we always key on the touch from corner1
        self.currentCircles[key1] = circle
        self.currentCircles[key2] = circle
        
        // clear any lines in progress
        currentLines[key1] = nil
        currentLines[key2] = nil
    }


    func processNewLines(lineBeginTouches: [UITouch]) {
        NSLog("\(__FUNCTION__)")
        for t in lineBeginTouches {
            let location = t.locationInView(self)
            let line = Line()
            line.begin = location
            line.end = location
            let key = NSValue(nonretainedObject: t)
            self.currentLines[key] = line
        }
    }

    func numTouches(touches: NSSet!) -> Int {
        return touches.allObjects.count
    }

    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        
        // println("\(__FUNCTION__)  touches=\(numTouches(touches))")
        
        // remove any selection that may be active
        UIMenuController.sharedMenuController().setMenuVisible(false, animated: true)
        selectedShape = nil
        selectedFor = SelectedFor.Draw
        
        let tList = touches.allObjects as [UITouch]
        if (numTouches(touches) == 2) {
            processNewCircle(tList)
        } else {
            processNewLines(tList)
        }
        
        
        self.setNeedsDisplay()
    }

    // Touch handling
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
        
        // println("\(__FUNCTION__)  touches=\(numTouches)")
        
        let tList = touches.allObjects as [UITouch]
        
        for t in tList {
            let location = t.locationInView(self)
            let key = NSValue(nonretainedObject: t)
            if let line = currentLines[key] {
                line.end = location
                // println("Adjusting a line")
            } else if let circle = currentCircles[key] {
                circle.updateCorner(location, key: key)
                // println("Adjusting a circle")
            }
        }
        
        self.setNeedsDisplay()
    }

    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        
        let tList = touches.allObjects as [UITouch]
        
        for t in tList {
            let location = t.locationInView(self)
            let key = NSValue(nonretainedObject: t)

            if let line = currentLines[key] {
                line.end = location
                self.finishedShapes.append(line)
                line.finished = true
                // currentLines.removeValueForKey(key) // - this doesn't decrement refcnt
                self.currentLines[key] = nil
                self.selectedShape = nil
                NSLog("touchesEnded: drew a line!")
            } else if let circle = currentCircles[key] {
                circle.updateCorner(location, key: key)
                assert(circle.currentTouches == 1 || circle.currentTouches == 2, "Finishing circle with out of bounds currentTouches")
                circle.currentTouches -= 1
                if (circle.currentTouches == 0) {
                    finishedShapes.append(circle)
                    circle.finished = true
                }
                // currentCircles.removeValueForKey(key) // - same issue as above
                self.currentCircles[key] = nil
            } else {
                // assert(false, "DrawView: touchesEnded with empty currentLine and empty currentCircle")
            }
        }
        
        self.setNeedsDisplay()
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!)  {
        NSLog("\(__FUNCTION__)");
        
        let tList = touches.allObjects as [UITouch]
        for t in tList {
            let key = NSValue(nonretainedObject: t)
            // currentLines.removeValueForKey(key)
            // currentCircles.removeValueForKey(key)
            currentLines[key] = nil
            currentCircles[key] = nil
        }
        self.setNeedsDisplay()
    }
    
    func cancelCurrentShapes() {
        self.currentLines.removeAll(keepCapacity: false)
        self.currentCircles.removeAll(keepCapacity: false)
        self.setNeedsDisplay()
    }
    
}




