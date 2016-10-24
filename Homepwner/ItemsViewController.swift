//
//  ItemsViewController.swift
//  Homepwner
//
//  Created by Spencer Greene on 6/29/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import UIKit

class ItemsViewController: UITableViewController {
    
    /* Old header before we used the navigation view controller

    // connect to XIB file
    var _headerView: UIView? = nil

    @IBOutlet var headerView: UIView {
    get {
        if (!_headerView) {
            NSBundle.mainBundle().loadNibNamed("HeaderView", owner: self, options: nil)
        }
        return _headerView!
    }
    set {
        _headerView = newValue
    }
    }
    
    @IBAction func toggleEditingMode(sender: UIButton) {
    if (self.editing) {
    sender.setTitle("Edit", forState: UIControlState.Normal)
    self.editing = false
    } else {
    sender.setTitle("Done", forState: UIControlState.Normal)
    self.editing = true
    }
    }
    */
    
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    var imagePopover: UIPopoverController? = nil
    
    func redraw() {
        self.tableView.reloadData()
    }
    
    @IBAction func addNewItem(_ sender: UIButton) {
        let newItem = ItemStore.sharedStore().createItem()
        
        /*
        let lastRow = ItemStore.sharedStore().allItems.indexOf(object: newItem)
        let indexPath = NSIndexPath(forRow: lastRow, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
        */
        
        let detailViewController = DetailViewController(isNew: true)
        detailViewController.item = newItem
        detailViewController.dismissBlock = self.redraw
        
        let navController = UINavigationController(rootViewController: detailViewController)
        navController.modalPresentationStyle = UIModalPresentationStyle.formSheet
        navController.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal

        self.present(navController, animated: true, completion: nil)
    }
    

    
    // display the table
    func tableSection(_ sec: Int) -> Array<Item> {
        assert(sec == 0, "This version only displays section 0")
        let allItems = ItemStore.sharedStore().allItems
        return allItems
    }
    
    func tableRows(_ section: Int) -> Int {
        let rows = tableSection(section).count
        // NSLog("number of rows in section \(section) is \(rows)")
        return rows
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let trailerRows = 0
        return tableRows(section) + trailerRows
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.row >= tableRows(indexPath.section)) { return false }
        else { return true }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // self.tableView.reloadData()
        
        self.updateTableViewForDynamicTypeSize()
    }
    

    
    // edit rows
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if (proposedDestinationIndexPath.row >= tableRows(proposedDestinationIndexPath.section)) {
            return sourceIndexPath
        } else {
            return proposedDestinationIndexPath
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let items = ItemStore.sharedStore().allItems
            let item = items[indexPath.row]
            ItemStore.sharedStore().removeItem(item)
            ImageStore.sharedStore().deleteImageForKey(item.itemKey)

            // also remove the row from the table view with animation
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)

        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        ItemStore.sharedStore().moveItem(sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemPicCell", for: indexPath) as! ItemPicCell

        let item = tableSection(indexPath.section)[indexPath.row]
        

        
        cell.nameLabel.text = item.itemName
        cell.serialNumberLabel.text = item.serialNumber
        let value = item.valueInDollars
        cell.valueLabel.text = String(format: "$%d", value)
        cell.thumbnailView.image = item.thumbnail
        
        weak var weakCell = cell
        
        // create and register a callback, no parameters -> Void, for when the thumbnail is touched
        cell.actionBlock = { () -> Void in
            NSLog("Block button press to show image for %@", item)
            
            let strongCell = weakCell
            
            // bail out if not an iPad
            if (UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.pad) { return }
            
            // bail out if no image
            let img = ImageStore.sharedStore().imageForKey(item.itemKey)
            if img == nil { return }
            
            
            // make a rectangle for the frame of the thumbnail relative to our table view
            let rect = self.view.convert(strongCell!.thumbnailView.bounds, from: strongCell!.thumbnailView)
            
            // create new ImageViewController & set its image
            let ivc = ImageViewController(image: img!)
            
            // present 600x600 popover from the rect
            self.imagePopover = UIPopoverController(contentViewController: ivc)
            self.imagePopover!.delegate = self
            self.imagePopover!.contentSize = CGSize(width: 600, height: 600)
            
            self.imagePopover!.present(from: rect, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
            
        }
        
        return cell
    }
    
    
    // display detail view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // NSLog("Row selected \(indexPath.row)")
        let detailCtlr = DetailViewController(isNew: false)
        detailCtlr.item = ItemStore.sharedStore().allItems[indexPath.row]
        
        self.navigationController!.pushViewController(detailCtlr, animated: true)
    }
    
    
    // initialization stuff
    override func viewDidLoad() {
        super.viewDidLoad()
        // self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        
        let nib = UINib(nibName: "ItemPicCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "ItemPicCell")
        // self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.translatesAutoresizingMaskIntoConstraints = true

        
        // let header = self.headerView
        // self.tableView.tableHeaderView = header
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.title = "Homepwner"
        let bbi = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(ItemsViewController.addNewItem(_:)))
        self.navigationItem.rightBarButtonItem = bbi
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(ItemsViewController.updateTableViewForDynamicTypeSize), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)

    }
    
    convenience override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        self.init()
    }
    
    convenience override init(style: UITableViewStyle) {
        self.init()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
   
}

extension ItemsViewController: UIPopoverControllerDelegate {
    func popoverControllerDidDismissPopover(_ popController: UIPopoverController) {
        self.imagePopover = nil
    }
}

// dealing with dynamic fonts
extension ItemsViewController {
    func updateTableViewForDynamicTypeSize() {
        let hDict: Dictionary<String, CGFloat> = [
            UIContentSizeCategory.extraSmall.rawValue : 44.0,
            UIContentSizeCategory.small.rawValue : 44.0,
            UIContentSizeCategory.medium.rawValue : 44.0,
            UIContentSizeCategory.large.rawValue: 44.0,
            UIContentSizeCategory.extraLarge.rawValue: 55.0,
            UIContentSizeCategory.extraExtraLarge.rawValue: 65.0,
            UIContentSizeCategory.extraExtraExtraLarge.rawValue: 75.0
        ]
        
        let userSize = UIApplication.shared.preferredContentSizeCategory.rawValue
        if let cellHeight = hDict[userSize] {
            self.tableView.rowHeight = cellHeight
            NSLog("\(#function) updating font size to \(userSize) -> \(cellHeight)")
        } else {
            NSLog("\(#function) font size not in dictionary \(userSize) ")
        }
        
        self.tableView.reloadData()
    }
    

}
