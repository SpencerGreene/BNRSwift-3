//
//  ImageStore.swift
//  Homepwner
//
//  Created by Spencer Greene on 7/4/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import Foundation
import UIKit

struct StaticImageStore {
    static var instance: ImageStore? = nil
    static var onceToken: Bool = false
}

class ImageStore: NSObject {
    
    private static var __once: () = {
                StaticImageStore.instance = ImageStore(localInit: true)
            }()
    
    var privateImages: Dictionary<String, UIImage>
    
    class func sharedStore() -> ImageStore! {

        if let me = StaticImageStore.instance {
            return me
        } else {
            _ = ImageStore.__once
            return StaticImageStore.instance!
        }
    }
    
    func imagePathForKey(_ key: String) -> String {
        return DocumentsPathTo(key)
    }
    
    func deleteImageForKey(_ key: String) {
        privateImages.removeValue(forKey: key)
        let path = imagePathForKey(key)
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch {
            print(error)
        }
    }
    
    func imageForKey(_ key: String) -> UIImage? {
        var image = privateImages[key]
        if image == nil {
            let path = imagePathForKey(key)
            image = UIImage(contentsOfFile: path)
            
            // add to cache if it was found
            if image != nil {
                privateImages[key] = image
            } else {
                // NSLog("No image for key \(key)")
            }
            
        }
        return image
    }
    
    func insertImage(_ image: UIImage, forKey key: String) {
        privateImages[key] = image
        
        let path = imagePathForKey(key)
        
        // turn image into JPEG
        let jpeg = UIImageJPEGRepresentation(image, 0.5)
        
        // write to path
        // jpeg.writeToFile(path, atomically: true)
        
        do {
            try jpeg!.write(to: URL(fileURLWithPath: path), options: .atomic)
        } catch {
            print(error)
        }
    }
    
    // this is called when there is a low memory warning
    func clearCache(_ note: Notification) {
        NSLog("Flushing \(privateImages.count) from cache")
        privateImages.removeAll(keepingCapacity: false)
    }
    
    required init(localInit: Bool) {
        assert(localInit, "attempting to initialize ItemStore directly; use sharedStore instead")
        privateImages = Dictionary<String, UIImage>()
        super.init()
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(ImageStore.clearCache(_:)), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    convenience override init() {
        self.init(localInit: false)
    }
    
}



