//
//  ReminderViewController.swift
//  Hypnonerd
//
//  Created by Spencer Greene on 6/29/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import UIKit
import UserNotifications

class ReminderViewController: UIViewController {
    
    func makeNotificationTrigger(at date: Date) -> UNCalendarNotificationTrigger {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        
        return trigger
    }
    
    @IBOutlet var datePicker: UIDatePicker?
    
    @IBAction func addReminder(_: AnyObject) {
        let date = self.datePicker!.date
        // NSLog("Setting reminder for %@", date)
        
        let noteContent = UNMutableNotificationContent()
        noteContent.title = "You asked for it"
        noteContent.body  = "This is your Hypnonerd reminder!"
        noteContent.sound = UNNotificationSound.default()
        
        let trigger = makeNotificationTrigger(at: date)
        
        let request = UNNotificationRequest(identifier: "textNotification", content: noteContent, trigger: trigger)
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("O no there was an error: \(error)")
            }
        }
        print("reminder scheduled")
        
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
