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
        let mainFrame = UIScreen.main.bounds
        let backgroundView = HypnosisView(frame: mainFrame)
        
        // let textField = UITextField(frame: CGRectMake(40, 70, 240, 30))
        let textField = UITextField(frame: CGRect(x: 40, y: -30, width: 240, height: 30))

        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.placeholder = "sample text"
        textField.returnKeyType = UIReturnKeyType.done
        textField.delegate = self
        
        backgroundView.addSubview(textField)
        self.textField = textField
        
        self.view = backgroundView
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func rand(_ max: Int) -> Int {
        let r = arc4random_uniform(UInt32(max))
        return(Int(r))
    }
    
    func drawHypnoticMessage(_ text: String) {
        print("drawing message with \(text)\n")
        for _ in 1...20 {
            let messageLabel = UILabel()
            messageLabel.backgroundColor = UIColor.clear
            messageLabel.textColor = UIColor.blue
            messageLabel.text = text
            messageLabel.sizeToFit()
            
            let originify: () -> () = {
                messageLabel.center = self.view.center
            }

            
            let width = Int(self.view.bounds.size.width - messageLabel.bounds.size.width)
            let x = rand(width)
            let height = Int(self.view.bounds.size.height - messageLabel.bounds.size.height)
            let y = rand(height)
            var frame = messageLabel.frame
            frame.origin = CGPoint(x: x, y: y)
            messageLabel.frame = frame
            self.view.addSubview(messageLabel)
            
            let randify: () -> () = {
                let x = CGFloat(self.rand(width))
                let y = CGFloat(self.rand(height))
                messageLabel.center = CGPoint(x: x, y: y)
            }
            
            func alpha1() {
                messageLabel.alpha = 1.0
            }
            
            messageLabel.alpha = 0.0
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn,
                animations: alpha1, completion: nil)
            
            func keyframes() {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.8, animations: originify)
                UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2, animations: randify)
            }
            
            func animationDone(_ finished: Bool) {
                NSLog("Animation finished")
            }
            
            UIView.animateKeyframes(withDuration: 1.0, delay: 0.0, options: [], animations: keyframes, completion: animationDone)

        }
        
    }
    
    func textFieldShouldReturn(_ tf: UITextField) -> Bool {
        drawHypnoticMessage(tf.text!)
        tf.text = ""
        tf.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("HypnosisView loaded")
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tabBarItem.title = "Hypnotize"
        self.tabBarItem.image = UIImage(named:"Hypno.png")
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        func placeTextField() {
            let frame = CGRect(x: 40, y: 70, width: 240, height: 30)
            self.textField.frame = frame
        }
        
        UIView.animate(withDuration: 2.0, delay: 0.0,
            usingSpringWithDamping: 0.25, initialSpringVelocity: 0.0, options: [],
            animations: placeTextField, completion: nil)
    }
   
}
