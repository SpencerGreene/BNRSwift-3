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
        case move
        case delete
        case draw
        case nothing
    }
    
    var currentLines: Dictionary<NSValue, Line> = [:]
    var finishedShapes: Array<TTShape> = []
    
    // both corners are indexed to the current circle
    var currentCircles: Dictionary<NSValue, Circle> = [:]
    
    var lineWidthTemporary: CGFloat = 5.0
    let circleWidthTemporary: CGFloat = 5.0
    let lineWidthPermanent: CGFloat = 10.0
    
    weak var selectedShape:TTShape? = nil
    var selectedFor = SelectedFor.nothing
    
    var moveRecognizer: UIPanGestureRecognizer? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.gray
        self.isMultipleTouchEnabled = true
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawView.doubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delaysTouchesBegan = true
        self.addGestureRecognizer(doubleTapRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawView.tap(_:)))
        tapRecognizer.delaysTouchesBegan = true
        tapRecognizer.require(toFail: doubleTapRecognizer)
        self.addGestureRecognizer(tapRecognizer)
        
        let longRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DrawView.longPress(_:)))
        self.addGestureRecognizer(longRecognizer)
        
        self.moveRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DrawView.moveLine(_:)))
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
    func setLineStyleForPath(_ path: UIBezierPath, temporary: Bool) {
        path.lineCapStyle = CGLineCap.round
        if (temporary) {
            path.lineWidth = self.lineWidthTemporary
            path.setLineDash([6.0, 12.0], count: 2, phase: 0)
        } else {
            path.lineWidth = self.lineWidthPermanent
        }
    }
    
    func strokeLine(_ line: Line, temporary: Bool) {
        // NSLog("\(__FUNCTION__) temporary=\(temporary)")
        let bp = UIBezierPath()
        
        setLineStyleForPath(bp, temporary: temporary)
        
        bp.move(to: line.begin)
        bp.addLine(to: line.end)
        bp.stroke()
    }
    
    func strokeCircle(_ circle: Circle, temporary: Bool) {
        let bp = UIBezierPath()
        
        setLineStyleForPath(bp, temporary: temporary)
        if (temporary) { bp.lineWidth = circleWidthTemporary }
        bp.move(to: circle.begin)
        bp.addArc(withCenter: circle.center, radius: circle.radius, startAngle: 0.0, endAngle: CGFloat(M_PI * 2.0), clockwise: true)
        bp.stroke()
        
        if (temporary) {
            let rp = UIBezierPath()
            rp.move(to: circle.corner1)
            rp.addLine(to: circle.corner12)
            rp.addLine(to: circle.corner2)
            rp.addLine(to: circle.corner21)
            rp.addLine(to: circle.corner1)
            rp.lineWidth = 2
            rp.stroke()
        }
    }
    
    
    func strokeShape(_ shape: TTShape, temporary: Bool, selected: Bool) {
        if (temporary) {
            UIColor.red.setStroke()
        } else if (selected) {
            if (selectedFor == SelectedFor.delete) { UIColor.green.setStroke() }
            else if (selectedFor == SelectedFor.move) { UIColor.yellow.setStroke() }
        } else {
            UIColor.black.setStroke()
            // setAngleColor(line)
        }
        
        if (shape.isLine) {
            let line = shape as! Line
            strokeLine(line, temporary: temporary)
        }
        if (shape.isCircle) {
            let circle = shape as! Circle
            strokeCircle(circle, temporary: temporary)
        }
    }
    
    
    // ch12 Silver: set color of line based on angle of line
    func setAngleColor(_ line: Line) {
        
        let hue = CGFloat(Double(line.angle) / (2*M_PI))
        UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0).setStroke()
    }

    
    override func draw(_ rect: CGRect) {
        // println("\(__FUNCTION__)")
        
        // finished lines in color determined by angle (ch12 Silver)
        for shape in finishedShapes {
            strokeShape(shape, temporary: false, selected: false)
        }
        
        // current lines in red, if any
        for (_, line) in currentLines {
            strokeShape(line, temporary: true, selected: false)
        }
        
        for (_, circle) in currentCircles {
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
    
    func processNewCircle(_ circleBeginTouches: [UITouch]) {
        NSLog("\(#function)")
        
        let currentTouches = circleBeginTouches.count
        assert(currentTouches == 2, "beginning circle that doesn't have 2 touches?")
        
        let corner1 = circleBeginTouches[0].location(in: self)
        let corner2 = circleBeginTouches[1].location(in: self)
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
    
    func processNewLines(_ lineBeginTouches: [UITouch]) {
        NSLog("\(#function)")
        for t in lineBeginTouches {
            let location = t.location(in: self)
            let line = Line()
            line.begin = location
            line.end = location
            let key = NSValue(nonretainedObject: t)
            self.currentLines[key] = line
        }
    }
    
    func numTouches(_ touches: Set<UITouch>!) -> Int {
        return touches.count
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent!) {
        
        // println("\(__FUNCTION__)  touches=\(numTouches)")
        
        // remove any selection that may be active
        UIMenuController.shared.setMenuVisible(false, animated: true)
        selectedShape = nil
        selectedFor = SelectedFor.draw
        
        let tList = Array(touches)
        if (touches.count == 2) {
            processNewCircle(tList)
        } else {
            processNewLines(tList)
        }
        
        
        self.setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent!) {
        
        // NSLog("\(__FUNCTION__)  touches=\(numTouches)");
        
        let tList = Array(touches)
        
        for t in tList {
            let location = t.location(in: self)
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent!) {
        
        NSLog("\(#function)  touches=\(numTouches(touches))");
        
        
        let tList = Array(touches)
        
        for t in tList {
            let location = t.location(in: self)
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
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent!)  {
        NSLog("\(#function)");
        
        let tList = Array(touches)
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
        self.currentLines.removeAll(keepingCapacity: false)
        self.currentCircles.removeAll(keepingCapacity: false)
        self.setNeedsDisplay()
    }
    
}


// delegate methods for UIPanGestureRecognizer
extension DrawView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer == self.moveRecognizer) { return true }
        return false
    }
}

// Gestures and associated actions
extension DrawView {
    
    func tap(_ gr: UIGestureRecognizer) {
        NSLog("\(#function)")
        let tapPoint = gr.location(in: self)
        self.selectedShape = shapeAtPoint(tapPoint)
        self.selectedFor = SelectedFor.delete
        
        let menu = UIMenuController.shared
        
        if selectedShape != nil {
            // make ourselves the target of menu item action messages
            self.becomeFirstResponder()
            
            // grab the menu controller
            
            // create a new "Delete" UIMenuItem
            let deleteItem = UIMenuItem(title: "Delete", action: #selector(DrawView.deleteShape(_:)))
            menu.menuItems = [deleteItem]
            
            // tell the menu where it should come from, and show it
            menu.setTargetRect(CGRect (origin: tapPoint, size: CGSize(width: 2, height: 2)), in: self)
            menu.setMenuVisible(true, animated: true)
            
        } else {
            // hide menu if no line selected
            menu.setMenuVisible(false, animated: true)
        }
        
        self.setNeedsDisplay()
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    func deleteShape(_ obj: AnyObject?) {
        NSLog("\(#function)")
        assert(self.selectedFor == SelectedFor.delete, "calling deleteShape but not SelectedFor.Delete")
        if let sel = selectedShape {
            for (index, shape) in self.finishedShapes.enumerated() {
                if sel === shape {
                    NSLog("Deleting shape at index \(index)")
                    self.finishedShapes.remove(at: index)
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
    
    func shapeAtPoint(_ p: CGPoint) -> TTShape? {
        for shape in self.finishedShapes {
            if shape.closeTo(p) {
                NSLog("\(#function) found a shape")
                return shape
            }
        }
        NSLog("\(#function) did not find a shape")
        return(nil)
    }
    
    func doubleTap(_ gr: UIGestureRecognizer) {
        NSLog("\(#function)")
        cancelCurrentShapes()
        // self.finishedShapes.removeAll(keepCapacity: false)
        self.finishedShapes = Array<TTShape>()
        self.setNeedsDisplay()
    }
    
    func longPress(_ gr: UIGestureRecognizer) {
        NSLog("\(#function)")
   
        if (gr.state == UIGestureRecognizerState.began) {
            selectedShape = shapeAtPoint(gr.location(in: self))
            selectedFor = SelectedFor.move
            UIMenuController.shared.setMenuVisible(false, animated: true)
            if selectedShape != nil {
                cancelCurrentShapes()
            }
        } else if (gr.state == UIGestureRecognizerState.ended) {
            selectedShape = nil
            selectedFor = SelectedFor.nothing
            self.setNeedsDisplay()
        }
    }
    

    func moveLine(_ gr: UIPanGestureRecognizer) {
        let translateVector = gr.translation(in: self)
        gr.setTranslation(CGPoint.zero, in: self)

        if (selectedFor == SelectedFor.draw) {
            let distance = hypot(Double(translateVector.x), Double(translateVector.y))
            if (distance > 1.0) {
                lineWidthTemporary = CGFloat(distance)
            }
            
            // NSLog("Distance since last call is \(distance)")
            return
        }
        
        if (selectedShape == nil) || (selectedFor != SelectedFor.move)  { return }
        
        NSLog("\(#function)")
        selectedShape!.translateBy(translateVector)
        self.setNeedsDisplay()
    }

}

