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
    
    @IBAction func addReminder(_: AnyObject) {
        let date = self.datePicker!.date
        // NSLog("Setting reminder for %@", date)
        
        let note = UILocalNotification()
        note.alertBody = "Hypnotize me"
        note.fireDate = date
        UIApplication.shared.scheduleLocalNotification(note)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        let nib = nibNameOrNil ?? "ReminderViewController"
        super.init(nibName: nib, bundle: nibBundleOrNil)
        self.tabBarItem.title = "Remind"
        self.tabBarItem.image = UIImage(named:"Time.png")
    }
    
    convenience init() {
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
        print("awake from nib: datepicker is \(datePicker)\n")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear: datePicker = \(datePicker)\n")

        if (self.datePicker != nil) {
            self.datePicker!.minimumDate = Date(timeIntervalSinceNow: 60)
        }
    }
   
}
