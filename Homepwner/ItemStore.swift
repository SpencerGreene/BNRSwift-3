//
//  ItemStore.swift
//  Homepwner
//
//  Created by Spencer Greene on 6/29/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import Foundation

struct StaticItemStore {
    static var instance: ItemStore? = nil
    static var onceToken: Int = 0
}

class ItemStore: NSObject {
    
    private static var __once: () = {
                StaticItemStore.instance = ItemStore(localInit: true)
            }()
    
    var privateItems: Array<Item> = []
    
    var allItems: Array<Item> {
        // let's see what happens if we just return the array itself
        return self.privateItems
    }
    
    class func sharedStore() -> ItemStore! {

        if let me = StaticItemStore.instance {
            return me
        } else {
            _ = ItemStore.__once
            return StaticItemStore.instance!
        }
    }
    
    func createItem() -> Item {
        // let newItem = Item.randomItem()
        let newItem = Item()
        privateItems.append(newItem)
        return newItem
    }
    
    func removeItem(_ item: Item) {
        for (index, element) in privateItems.enumerated() {
            if element === item {
                NSLog("Removing item %@", element)
                privateItems.remove(at: index)
            }
        }
    }
    
    func moveItem(_ from: Int, to: Int) {
        if (from == to) { return }
        let item = privateItems[from]
        privateItems.remove(at: from)
        privateItems.insert(item, at: to)
    }
    
    required init(localInit: Bool) {
        assert(localInit, "attempting to initialize ItemStore directly; use sharedStore instead")
        super.init()
        
        let fetch = NSKeyedUnarchiver.unarchiveObject(withFile: itemArchivePath()) as? Array<Item>
        if let f = fetch {
            privateItems = f
            NSLog("Retrieved \(f.count) items from storage")
        }
    }
    
    convenience override init() {
        self.init(localInit: false)
    }
    

    
}

func DocumentsPathTo(_ s: String) -> String {
    let targetDir = FileManager.SearchPathDirectory.documentDirectory
    let targetMask = FileManager.SearchPathDomainMask.userDomainMask
    let dirArray = NSSearchPathForDirectoriesInDomains(targetDir, targetMask, true) as [String]
   
    let path = (dirArray[0] as NSString).appendingPathComponent(s)

    return path
}

// save & restore
extension ItemStore {
    
    func itemArchivePath() -> String {
        /*
        let targetDir = NSSearchPathDirectory.DocumentDirectory
        let targetMask = NSSearchPathDomainMask.UserDomainMask
        let dirArray = NSSearchPathForDirectoriesInDomains(targetDir, targetMask, true) as [String]
        let documentDirectory = dirArray[0]
        */
                
        return DocumentsPathTo("items.archive")
    }
    
    func saveChanges() -> Bool {
        
        return NSKeyedArchiver.archiveRootObject(self.privateItems, toFile: itemArchivePath())
    }
    
}
