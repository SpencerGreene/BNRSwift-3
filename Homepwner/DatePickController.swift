//
//  DatePickController.swift
//  Homepwner
//
//  Created by Spencer Greene on 7/3/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import UIKit

class DatePickController: UIViewController {

    weak var item: Item? = nil

    @IBOutlet var datePicker: UIDatePicker!


    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        NSLog("DatePickController initialized with nibName=\(nibNameOrNil) and bundle=\(nibBundleOrNil) and item=\(item)")
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }
    
    convenience init(item: Item) {
        self.init()
        self.item = item
        NSLog("initialized with item=\(self.item) and datePicker=\(self.datePicker)")
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("DatePickController did load with datePicker=\(datePicker)")
        datePicker.setDate(self.item!.dateCreated! as Date, animated: true)
        datePicker.datePickerMode = UIDatePickerMode.date
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.item!.dateCreated = datePicker.date
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
