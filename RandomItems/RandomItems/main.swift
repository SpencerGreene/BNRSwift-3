//
//  main.swift
//  RandomItems
//
//  Created by Spencer Greene on 6/28/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import Foundation

var items = [Item]()

for _ in 1...10 {
    items.append(Item.randomItem())
}

for item in items {
    NSLog("%@", item)
}

var item5:Item? = Item.randomItem()
print("Created \(item5)")

item5 = nil
print("Right now item5 is \(item5)")





