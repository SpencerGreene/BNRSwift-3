//
//  ColorViewController.swift
//  Colorboard
//
//  Created by Spencer Greene on 8/3/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import UIKit

class ColorViewController: UIViewController, UITextFieldDelegate, UIViewControllerRestoration {
    
    var existingColor = true
    var colorDescription = ColorDescription()

    @IBAction func dismiss(_ sender: AnyObject) {
        self.presentingViewController!.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var textField: UITextField?
    @IBOutlet weak var redSlider: UISlider?
    @IBOutlet weak var greenSlider: UISlider?
    @IBOutlet weak var blueSlider: UISlider?
    
    @IBAction func changeColor(_ sender: AnyObject) {
        let red = CGFloat(self.redSlider!.value)
        let green = CGFloat(self.greenSlider!.value)
        let blue = CGFloat(self.blueSlider!.value)
        let newColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        self.view.backgroundColor = newColor
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color = self.colorDescription.color
        // get the RGB values
        var red = CGFloat(0.0)
        var green = red
        var blue = red
        var alpha = red
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        self.redSlider!.value = Float(red)
        self.greenSlider!.value = Float(green)
        self.blueSlider!.value = Float(blue)
        
        // set background color and text field value
        self.view.backgroundColor = color
        textField!.text = self.colorDescription.name
        textField!.returnKeyType = .done
        textField!.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // remove done button if this is an existing color
        if (existingColor) {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.colorDescription.name = self.textField!.text!
        self.colorDescription.color = self.view.backgroundColor!
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    class func viewController(
        withRestorationIdentifierPath identifierComponents: [Any], coder: NSCoder) -> UIViewController? {
            var vc: ColorViewController? = nil
            
            // the following line crashes the compiler in beta6 (it was fine in beta5)
            let storyboard = coder.decodeObject(forKey: UIStateRestorationViewControllerStoryboardKey) as? UIStoryboard
            // let storyboard: UIStoryboard? = UIStoryboard()   // -- this one compiles in beta6 (but does no good of course)
            
            if let sb = storyboard {
                vc = sb.instantiateViewController(withIdentifier: "ColorViewController") as? ColorViewController
                vc?.restorationIdentifier = identifierComponents.last as? String
            }
            
            
            return vc!
    }


}
