//
//  ReminderViewController.swift
//  Hypnonerd
//
//  Created by Spencer Greene on 6/29/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import UIKit

class ReminderViewController: UIViewController {
    
    @IBOutlet var datePicker: UIDatePicker?
    
    @IBAction func addReminder(AnyObject) {
        let date = self.datePicker!.date
        NSLog("Setting reminder for %@", date)
        
        let note = UILocalNotification()
        note.alertBody = "Hypnotize me"
        note.fireDate = date
        UIApplication.sharedApplication().scheduleLocalNotification(note)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        let nib = nibNameOrNil ?? "ReminderViewController"
        super.init(nibName: nib, bundle: nibBundleOrNil)
        self.tabBarItem.title = "Remind"
        self.tabBarItem.image = UIImage(named:"Time.png")
    }
    
    convenience override init() {
        // self.init(nibName: "ReminderViewController", bundle: nil)
        self.init(nibName: nil, bundle: nil)

    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("ReminderView loaded")
    }
    
    override func awakeFromNib() {
        println("awake from nib: datepicker is \(datePicker)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        println("viewWillAppear: datePicker = \(datePicker)")

        if (self.datePicker != nil) {
            self.datePicker!.minimumDate = NSDate(timeIntervalSinceNow: 60)
        }
    }
   
}
