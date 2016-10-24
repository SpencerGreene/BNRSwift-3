//
//  Item.swift
//  RandomItems
//
//  Created by Spencer Greene on 6/28/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import Foundation
import UIKit

extension String {
    subscript(i: Int) -> String {
        get {
            // let istart = advance(self.startIndex, i)
            let istart = self.index(self.startIndex, offsetBy: i)
            let chopFront = self.substring(from: istart)
            // let iend = advance(chopFront.startIndex, 1)
            let iend = self.index(chopFront.startIndex, offsetBy: 1)
            let chopFrontEnd = chopFront.substring(to: iend)
            
            return chopFrontEnd
        }
    }
}

extension Date {
    static func now() -> Date {
        return Date(timeIntervalSinceNow: 0)
    }
}

var ItemDateFormatter = DateFormatter()


class Item: NSObject, NSCoding {
    var itemName = ""
    var serialNumber = ""
    var valueInDollars = 0
    var dateCreated: Date?
    var itemKey: String = ""
    var thumbnail: UIImage? = nil

    class func randFrom(_ s: String) -> String {
        let i = Int(arc4random_uniform(UInt32(s.characters.count)))
        return s[i]
        
    }
    
    class func randCap() -> String {
         return randFrom("ACDEFGHJKMNPQRSTUVWXYZ")
    }
    
    class func randDigit() -> String {
        return(randFrom("12345679"))
    }
    
    class func randomItem() -> Self {
        let ListOfAdj = ["Fluffy", "Rusty", "Shiny", "Clear"]
        let ListOfNoun = ["Bear", "Spork", "Sofa"]
        
        let adjIndex = Int(arc4random_uniform(UInt32(ListOfAdj.count)))
        let adj = ListOfAdj[adjIndex]
        
        
        let nounIndex = Int(arc4random_uniform(UInt32(ListOfNoun.count)))
        let noun = ListOfNoun[nounIndex]

        let serial = randCap() + randCap() + randDigit() +  randDigit() + randDigit()
        
        let randItem = self.init(itemName:adj+" "+noun, serialNumber:serial,
                                 valueInDollars: Int(arc4random_uniform(100)))
        return(randItem)
    }
    
    required init(itemName: String, serialNumber: String, valueInDollars: Int) {
        // XXX not sure why these are initialized more than once
        self.itemKey = UUID().uuidString
        self.itemName = itemName
        self.serialNumber = serialNumber
        self.valueInDollars = valueInDollars
        self.dateCreated = Date.now()
        
        super.init()

    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.itemName, forKey: "itemName")
        coder.encode(self.serialNumber, forKey: "serialNumber")
        coder.encode(self.dateCreated, forKey: "dateCreated")
        coder.encode(self.itemKey, forKey: "itemKey")
        coder.encode(self.valueInDollars, forKey: "valueInDollars")
        coder.encode(self.thumbnail, forKey: "thumbnail")
    }
    
    required init(coder: NSCoder)  {
        super.init()
        itemName = coder.decodeObject(forKey: "itemName") as! String
        serialNumber = coder.decodeObject(forKey: "serialNumber") as! String
        dateCreated = coder.decodeObject(forKey: "dateCreated") as? Date
        itemKey = coder.decodeObject(forKey: "itemKey") as! String
        valueInDollars = coder.decodeInteger(forKey: "valueInDollars")
        thumbnail = coder.decodeObject(forKey: "thumbnail") as? UIImage
    }
    
    convenience init(itemName: String) {
        self.init(itemName: itemName, serialNumber: "", valueInDollars: 0)
    }
    
    convenience override init() {
        self.init(itemName: "Blank Item")
    }
    
    override var description: String {
        ItemDateFormatter.dateStyle = DateFormatter.Style.medium
        ItemDateFormatter.timeStyle = DateFormatter.Style.none
        let dateString = ItemDateFormatter.string(from: dateCreated!)
        // NSLog("Date created is \(dateCreated), dateString is \(dateString)")
        let s = "\(itemName) (\(serialNumber)): worth $\(valueInDollars), recorded on \(dateString)"
        return(s)
    }
    
}

// handle image thumbnail
extension Item {
    func setThumbnailFromImage(_ image: UIImage) {
        let newRect = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        let hratio = newRect.width / image.size.width
        let vratio = newRect.height / image.size.height
        let ratio = max(hratio, vratio)
        
        // create transparent bitmap context with scaling equal to screen
        UIGraphicsBeginImageContextWithOptions(newRect.size, false, 0.0)
        
        // create rounded rectangle path
        let curveSize = CGSize(width: 5.0, height: 5.0)
        let path = UIBezierPath(roundedRect: newRect, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: curveSize)
        path.addClip()
        
        // center image in thumbnail rectangle
        var projectRect = CGRect()
        projectRect.size.width = image.size.width * ratio
        projectRect.size.height = image.size.height * ratio
        projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0
        projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0
        
        // draw the image in it
        image.draw(in: projectRect)
        
        // now get the image from the context, as our thumbnail
        self.thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }


}
