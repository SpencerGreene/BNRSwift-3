//
//  Item.swift
//  RandomItems
//
//  Created by Spencer Greene on 6/28/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import Cocoa
import Foundation

extension String {
    subscript(i: Int) -> String {
        get {
            let myChar = self[self.index(self.startIndex, offsetBy: i)]
            return String(myChar)
            /*
            let istart = self.advancedBy(i)
            let chopFront = self.substring(from: istart)
            let iend = advance(chopFront.startIndex, 1)
            let chopFrontEnd = chopFront.substring(to: iend)
            
            return chopFrontEnd
            */
        }
    }
}

class Item: NSObject {
    var itemName = ""
    var serialNumber = ""
    var valueInDollars = 0
    var dateCreated: Date?

    class func randFrom(_ s: String) -> String {
        let len = s.characters.count
        let i = randInt(len)
        return s[i]
        
    }
    
    class func randInt(_ max: Int) -> Int {
        let maxUInt = UInt32(max)
        let randUInt = arc4random_uniform(maxUInt)
        let rand = Int(randUInt)
        return rand
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
        
        let adj = ListOfAdj[randInt(ListOfAdj.count)]
        let noun = ListOfNoun[randInt(ListOfNoun.count)]
        let serial = randCap() + randCap() + randDigit() +  randDigit() + randDigit()
        
        let randItem = self.init(itemName:adj+" "+noun, serialNumber:serial, valueInDollars: randInt(100))
        return(randItem)
    }
    
    required init(itemName: String, serialNumber: String, valueInDollars: Int) {
        super.init()
        self.itemName = itemName
        self.serialNumber = serialNumber
        self.valueInDollars = valueInDollars
        dateCreated = Date()             // this defaults to current date
    }
    
    convenience init(itemName: String) {
        self.init(itemName: itemName, serialNumber: "", valueInDollars: 0)
    }
    
    convenience override init() {
        self.init(itemName: "Blank Item")
    }
    
    deinit {
        NSLog("Destroyed: %@", self)
    }
    
    override var description : String {
        let s = "\(itemName) (\(serialNumber)): worth \(valueInDollars), recorded on \(dateCreated)"
        return(s)
    }
    
}
