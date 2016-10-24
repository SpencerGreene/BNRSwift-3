//
//  DetailViewController.swift
//  Homepwner
//
//  Created by Spencer Greene on 7/1/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UINavigationControllerDelegate {
    
    let dateFormatter = DateFormatter()
    var dismissBlock: () -> Void = {}
    
    weak var item: Item? = nil {
    didSet {
        if let realItem = item {
            self.navigationItem.title = realItem.itemName
        }
    }
    }
    

    convenience override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.init(isNew: true)
        let exception = NSException(name: NSExceptionName(rawValue: "Wrong initializer"), reason: "Use init(isNew:)", userInfo: nil)
        exception.raise()
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    // new designated initializer
    init(isNew: Bool) {
        super.init(nibName: "DetailViewController", bundle: nil)

        if (isNew) {
            let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(DetailViewController.save(_:)))
            self.navigationItem.rightBarButtonItem = doneItem
            
            let cancelItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(DetailViewController.cancel(_:)))
            self.navigationItem.leftBarButtonItem = cancelItem

        }
        self.dateFormatter.dateStyle = DateFormatter.Style.medium
        self.dateFormatter.timeStyle = DateFormatter.Style.none
        
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.updateFonts),
            name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    // code for rendering the view
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let iv = UIImageView()
        iv.contentMode = UIViewContentMode.scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(iv)
        self.itemPicture = iv
        
        let hpriNew = UILayoutPriority(200.0)
        let vpriNew = hpriNew
        self.itemPicture.setContentHuggingPriority(hpriNew, for: UILayoutConstraintAxis.horizontal)
        self.itemPicture.setContentHuggingPriority(vpriNew, for: UILayoutConstraintAxis.vertical)

        let hcompNew = UILayoutPriority(700.0)
        let vcompNew = hcompNew
        self.itemPicture.setContentCompressionResistancePriority(hcompNew, for: UILayoutConstraintAxis.horizontal)
        self.itemPicture.setContentCompressionResistancePriority(vcompNew, for: UILayoutConstraintAxis.vertical)

        let nameMap = ["itemPicture" : self.itemPicture,
            "dateLabel" : self.createDateLabel,
            "toolBar" : self.toolBar,
            "dateButton" : self.dateButton
        ] as [String : Any]
        
        // set itemPicture to 0 points from left and right edges of superview
        let options = NSLayoutFormatOptions(rawValue: 0)

        let hstring = "H:|-0-[itemPicture]-0-|"
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: hstring, options: options, metrics: nil, views: nameMap)
        
        let vstring = "V:[dateButton]-0-[itemPicture]-[toolBar]"
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: vstring, options: options, metrics: nil, views: nameMap)

        self.view.addConstraints(hConstraints)
        self.view.addConstraints(vConstraints)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let orientation = UIApplication.shared.statusBarOrientation
        self.prepareViewsForOrientation(orientation)
        
        if item == nil { return }

        self.nameField.text = item!.itemName
        self.serialField.text = item!.serialNumber
        self.valueField.text = String(item!.valueInDollars)
        
        let dateString = dateFormatter.string(from: item!.dateCreated!)
        self.createDateLabel.text = dateString

        let displayImage = ImageStore.sharedStore().imageForKey(item!.itemKey)
        self.itemPicture.image = displayImage

        self.updateFonts()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // clear first responder
        self.view.endEditing(true)
        
        // save changes to item
        if self.item != nil {
            
        } else {
            self.item = Item()
        }
        
        self.item!.itemName = self.nameField.text!
        self.item!.serialNumber = self.serialField.text!
        if let dollars = Int(self.valueField.text!) {
            self.item!.valueInDollars = dollars
        }
    }
    
    /*
    // Text field delegate method when field is in editing mode
    -(void)textFieldDidBeginEditing:(UITextField *)textField
    {
    // Create a View for done button
    UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    
    // create a button for done button view and assign an action when button is tapped
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"DONE"
    style:UIBarButtonItemStyleBordered
    target:self
    action:@selector(doneClicked:)];
    
    // add the done button to the done button view
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    
    // add the done button view to the keyboard when the value field is in editing mode
    self.valueField.inputAccessoryView = keyboardDoneButtonView;
    
    }
    */
    

    
    func save(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true, completion: self.dismissBlock)
    }
    
    func cancel(_ sender: AnyObject) {
        // if user canceled this item has to be removed from the store
        if let item = self.item {
            ItemStore.sharedStore().removeItem(item)
        } else {
            assert(false, "canceling with empty self.item?!?")
        }
        self.presentingViewController?.dismiss(animated: true, completion: self.dismissBlock)
    }
    
    var imagePickerPopover: UIPopoverController? = nil

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var nameField: UITextField!
    
    @IBOutlet weak var serialLabel: UILabel!
    @IBOutlet var serialField: UITextField!
    
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet var valueField: UITextField!
    
    @IBOutlet var itemPicture: UIImageView!
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var cameraButton: UIBarButtonItem!
    @IBOutlet var dateButton: UIButton!
    @IBOutlet var createDateLabel: UILabel!
    
    @IBAction func backgroundTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        
    }
    
    @IBAction func takePicture(_ sender: AnyObject) {
        NSLog("DetailViewController: takePicture")
        
        if (self.imagePickerPopover?.isPopoverVisible != nil) {
            dismissPicker("\(#function)")

            return
        }
        
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            // imagePicker.cameraOverlayView = CameraOverlayView(frame: self.view.bounds)
            imagePicker.allowsEditing = true
        } else {
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = true
        }
        imagePicker.delegate = self
        
        // if device is iPad then display imagePicker in popover, else display imagePicker
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
            self.imagePickerPopover = UIPopoverController(contentViewController: imagePicker)
            self.imagePickerPopover!.delegate = self
            
            // display the popover
            self.imagePickerPopover!.present(from: sender as! UIBarButtonItem, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        } else {
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func buttonDeletePicture(_ sender: AnyObject) {
        NSLog("DetailViewController: DeletePicture")
        ImageStore.sharedStore().deleteImageForKey(item!.itemKey)
        self.itemPicture.image = nil
        self.item!.thumbnail = nil
    }

    
    @IBAction func buttonChangeDate(_ sender: UIButton) {
        NSLog("DetailViewController: buttonChangeDate")
        if let realItem = self.item {
            let dp = DatePickController(item: realItem)
            self.navigationController?.pushViewController(dp, animated: true)
        } else {
            NSLog("Trying to change date for nonexistent item")
        }
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

extension DetailViewController: UITextFieldDelegate {
    
    // Will dismiss the text keyboards whe their "Return" (or equivalent) button
    // is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("DetailViewController: textFieldShouldReturn")
        textField.resignFirstResponder()
        return true
    }
    
    /*
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        
        println("DetailViewController: touchesBegan")
        nameField.resignFirstResponder()
        serialField.resignFirstResponder()
        valueField.resignFirstResponder()
    }
    */
}

extension DetailViewController: UIImagePickerControllerDelegate {
    func dismissPicker(_ from: String) {
        if self.imagePickerPopover != nil {
            NSLog("dismissPicker dismissing popover from \(from)")
            
            self.imagePickerPopover!.dismiss(animated: true)
            self.imagePickerPopover = nil
        } else {
            self.dismiss(animated: true, completion: nil)
        }

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        NSLog("DetailViewController as UIImagePickerControllerDelegate: didFinishPickingMediaWithInfo")
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        self.itemPicture.image = image
        
        ImageStore.sharedStore().insertImage(image, forKey: self.item!.itemKey)
        self.item!.setThumbnailFromImage(image)
        
        // take image picker off the screen
        dismissPicker("\(#function)")

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismissPicker("\(#function)")
        
    }
    
}

// Dealing with rotation and iPad popover: Chapter 17
extension DetailViewController: UIPopoverControllerDelegate {
    func prepareViewsForOrientation(_ orientation: UIInterfaceOrientation) {
        let idiom = UIDevice.current.userInterfaceIdiom
        if idiom == UIUserInterfaceIdiom.pad {
            return
        } else if idiom == UIUserInterfaceIdiom.phone {
            // is it landscape?
            if UIInterfaceOrientationIsLandscape(orientation) {
                self.itemPicture.isHidden = true
                self.cameraButton.isEnabled = false
            } else {
                self.itemPicture.isHidden = false
                self.cameraButton.isEnabled = true
            }
        } else {
            NSLog("\(#function) found an unexpected idiom")
        }
    }
    
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        self.prepareViewsForOrientation(toInterfaceOrientation)
    }
    
    func popoverControllerDidDismissPopover(_ pc: UIPopoverController) {
        NSLog("Dismissing popover from \(#function)")
        self.imagePickerPopover = nil
    }
}

// Dealing with dynamic font sizing
extension DetailViewController {
    func updateFonts() {
        let font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        
        nameLabel.font = font
        nameField.font = font
        serialLabel.font = font
        serialField.font = font
        valueLabel.font = font
        valueField.font = font
        createDateLabel.font = font
    }
}
