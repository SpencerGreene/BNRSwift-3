//
//  HypnosisViewController.swift
//  Hypnonerd
//
//  Created by Spencer Greene on 6/29/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import UIKit

class HypnosisViewController: UIViewController, UITextFieldDelegate {
    
    var textField: UITextField! = nil
    
    override func loadView() {
        let mainFrame = UIScreen.mainScreen().bounds
        let backgroundView = HypnosisView(frame: mainFrame)
        
        // let textField = UITextField(frame: CGRectMake(40, 70, 240, 30))
        let textField = UITextField(frame: CGRectMake(40, -30, 240, 30))

        textField.borderStyle = UITextBorderStyle.RoundedRect
        textField.placeholder = "Yash & Anya!"
        textField.returnKeyType = UIReturnKeyType.Done
        textField.delegate = self
        
        backgroundView.addSubview(textField)
        self.textField = textField
        
        self.view = backgroundView
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func drawHypnoticMessage(text: String) {
        println("drawing message with \(text)")
        for _ in 1...20 {
            let messageLabel = UILabel()
            messageLabel.backgroundColor = UIColor.clearColor()
            messageLabel.textColor = UIColor.blueColor()
            messageLabel.text = text
            messageLabel.sizeToFit()
            
            let originify: () -> () = {
                messageLabel.center = self.view.center
            }

            
            let width = Int(self.view.bounds.size.width - messageLabel.bounds.size.width)
            let x = random() % width
            let height = Int(self.view.bounds.size.height - messageLabel.bounds.size.height)
            let y = random() % height
            var frame = messageLabel.frame
            frame.origin = CGPoint(x: x, y: y)
            messageLabel.frame = frame
            self.view.addSubview(messageLabel)
            
            let randify: () -> () = {
                let x = CGFloat(random() % width)
                let y = CGFloat(random() % height)
                messageLabel.center = CGPointMake(x, y)
            }
            
            func alpha1() {
                messageLabel.alpha = 1.0
            }
            
            messageLabel.alpha = 0.0
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn,
                animations: alpha1, completion: nil)
            
            func keyframes() {
                UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.8, animations: originify)
                UIView.addKeyframeWithRelativeStartTime(0.8, relativeDuration: 0.2, animations: randify)
            }
            
            func animationDone(finished: Bool) {
                NSLog("Animation finished")
            }
            
            UIView.animateKeyframesWithDuration(1.0, delay: 0.0, options: nil, animations: keyframes,
                completion: animationDone)

        }
        
    }
    
    func textFieldShouldReturn(tf: UITextField) -> Bool {
        drawHypnoticMessage(tf.text)
        tf.text = ""
        tf.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("HypnosisView loaded")
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tabBarItem.title = "Hypnotize"
        self.tabBarItem.image = UIImage(named:"Hypno.png")
    }
    
    convenience override init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        func placeTextField() {
            let frame = CGRectMake(40, 70, 240, 30)
            self.textField.frame = frame
        }
        
        UIView.animateWithDuration(2.0, delay: 0.0,
            usingSpringWithDamping: 0.25, initialSpringVelocity: 0.0, options: nil,
            animations: placeTextField, completion: nil)
    }
   
}
