//
//  ItemPicCell.swift
//  Homepwner
//
//  Created by Spencer Greene on 7/21/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import UIKit

class ItemPicCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var serialNumberLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!
    
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    var actionBlock: (() -> Void)? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.updateFontForDynamicTypeSize()
        let constraint = NSLayoutConstraint(item: self.thumbnailView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self.thumbnailView, attribute: NSLayoutAttribute.width, multiplier: 1.0, constant: 0.0)
        self.thumbnailView.addConstraint(constraint)

        NotificationCenter.default.addObserver(self, selector: #selector(ItemPicCell.updateFontForDynamicTypeSize),
            name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func showImage(_ sender: AnyObject) {
        if let block = self.actionBlock {
            block()
        }
        
    }

    
}

// dealing with dynamic type
extension ItemPicCell {
    func updateFontForDynamicTypeSize() {
        let font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        self.nameLabel.font = font
        self.serialNumberLabel.font = font
        self.valueLabel.font = font
        
        let iDict: Dictionary<String, CGFloat> = [
            UIContentSizeCategory.extraSmall.rawValue : 40.0,
            UIContentSizeCategory.small.rawValue : 40.0,
            UIContentSizeCategory.medium.rawValue : 40.0,
            UIContentSizeCategory.large.rawValue: 40.0,
            UIContentSizeCategory.extraLarge.rawValue: 45.0,
            UIContentSizeCategory.extraExtraLarge.rawValue: 55.0,
            UIContentSizeCategory.extraExtraExtraLarge.rawValue: 65.0
        ]
        
        let userSize = UIApplication.shared.preferredContentSizeCategory.rawValue
        if let imageSize = iDict[userSize] {
            self.imageViewHeightConstraint.constant = imageSize
            // self.imageViewWidthConstraint.constant = imageSize
            NSLog("\(#function) updating image size to \(userSize) -> \(imageSize)")
        } else {
            NSLog("\(#function) font size not in dictionary \(userSize) ")
        }

    }
    
}
