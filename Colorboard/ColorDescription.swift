//
//  ColorDescription.swift
//  Colorboard
//
//  Created by Spencer Greene on 8/6/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import UIKit

class ColorDescription: NSObject {
    var color = UIColor.clear
    var name = ""
    
    override init() {
        super.init()
        color = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        name = "Blue"
    }
   
}
