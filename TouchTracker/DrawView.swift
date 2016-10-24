//
//  DrawView.swift
//  TouchTracker
//
//  Created by Spencer Greene on 7/5/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import UIKit

class DrawView: UIView {
    
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
        self.moveRecognizer!.delegate = self
        self.moveRecognizer!.cancelsTouchesInView = false
        self.addGestureRecognizer(self.moveRecognizer!)

    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    
}


// Rendering the current state
extension DrawView {
    // #pragma mark - Drawing
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
        // NSLog("\(__FUNCTION__) temporary=\(temporary)")
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
        // println("\(__FUNCTION__)")
        
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
        
        /*
        var f = 0.0
        for i in 1...1_000_000 {
            let t = Double(time(nil)) + Double(i)
            f += sin(sin(sin(sin(t))))
        }
        NSLog("I calculated \(f)")
        */
    }
    
}


// Converting touches to shapes
extension DrawView {
    // #pragma mark - Touch handling
    
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
        // currentLines.removeValueForKey(key1)
        // currentLines.removeValueForKey(key2)
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
        
        // println("\(__FUNCTION__)  touches=\(numTouches)")
        
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
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
        
        // NSLog("\(__FUNCTION__)  touches=\(numTouches)");
        
        let tList = touches.allObjects as [UITouch]
        
        for t in tList {
            let location = t.locationInView(self)
            let key = NSValue(nonretainedObject: t)
            if let line = currentLines[key] {
                line.end = location
                // NSLog("Adjusting a line")
            } else if let circle = currentCircles[key] {
                circle.updateCorner(location, key: key)
                // NSLog("Adjusting a circle")
            }
        }
        
        self.setNeedsDisplay()
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        
        NSLog("\(__FUNCTION__)  touches=\(numTouches(touches))");
        
        
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


// delegate methods for UIPanGestureRecognizer
extension DrawView: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        if (gestureRecognizer == self.moveRecognizer) { return true }
        return false
    }
}

// Gestures and associated actions
extension DrawView {
    
    func tap(gr: UIGestureRecognizer) {
        NSLog("\(__FUNCTION__)")
        let tapPoint = gr.locationInView(self)
        self.selectedShape = shapeAtPoint(tapPoint)
        self.selectedFor = SelectedFor.Delete
        
        let menu = UIMenuController.sharedMenuController()
        
        if let selected = selectedShape {
            // make ourselves the target of menu item action messages
            self.becomeFirstResponder()
            
            // grab the menu controller
            
            // create a new "Delete" UIMenuItem
            let deleteItem = UIMenuItem(title: "Delete", action: "deleteShape:")
            menu.menuItems = [deleteItem]
            
            // tell the menu where it should come from, and show it
            menu.setTargetRect(CGRect (origin: tapPoint, size: CGSize(width: 2, height: 2)), inView: self)
            menu.setMenuVisible(true, animated: true)
            
        } else {
            // hide menu if no line selected
            menu.setMenuVisible(false, animated: true)
        }
        
        self.setNeedsDisplay()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    func deleteShape(obj: AnyObject?) {
        NSLog("\(__FUNCTION__)")
        assert(self.selectedFor == SelectedFor.Delete, "calling deleteShape but not SelectedFor.Delete")
        if let sel = selectedShape {
            for (index, shape) in enumerate(self.finishedShapes) {
                if sel === shape {
                    NSLog("Deleting shape at index \(index)")
                    self.finishedShapes.removeAtIndex(index)
                    self.selectedShape = nil
                    self.setNeedsDisplay()
                    return
                }
            }
            assert(false, "deleteShape called but selectedShape can't be found")
        } else {
            assert(false, "deleteShape called with no selectedShape")
        }
    }
    
    func shapeAtPoint(p: CGPoint) -> TTShape? {
        for shape in self.finishedShapes {
            if shape.closeTo(p) {
                NSLog("\(__FUNCTION__) found a shape")
                return shape
            }
        }
        NSLog("\(__FUNCTION__) did not find a shape")
        return(nil)
    }
    
    func doubleTap(gr: UIGestureRecognizer) {
        NSLog("\(__FUNCTION__)")
        cancelCurrentShapes()
        // self.finishedShapes.removeAll(keepCapacity: false)
        self.finishedShapes = Array<TTShape>()
        self.setNeedsDisplay()
    }
    
    func longPress(gr: UIGestureRecognizer) {
        NSLog("\(__FUNCTION__)")
   
        if (gr.state == UIGestureRecognizerState.Began) {
            selectedShape = shapeAtPoint(gr.locationInView(self))
            selectedFor = SelectedFor.Move
            UIMenuController.sharedMenuController().setMenuVisible(false, animated: true)
            if let moveShape = selectedShape {
                cancelCurrentShapes()
            }
        } else if (gr.state == UIGestureRecognizerState.Ended) {
            selectedShape = nil
            selectedFor = SelectedFor.Nothing
            self.setNeedsDisplay()
        }
    }
    

    func moveLine(gr: UIPanGestureRecognizer) {
        let translateVector = gr.translationInView(self)
        gr.setTranslation(CGPointZero, inView: self)

        if (selectedFor == SelectedFor.Draw) {
            let distance = hypot(Double(translateVector.x), Double(translateVector.y))
            if (distance > 1.0) {
                lineWidthTemporary = CGFloat(distance)
            }
            
            // NSLog("Distance since last call is \(distance)")
            return
        }
        
        if (selectedShape == nil) || (selectedFor != SelectedFor.Move)  { return }
        
        NSLog("\(__FUNCTION__)")
        selectedShape!.translateBy(translateVector)
        self.setNeedsDisplay()
    }

}

