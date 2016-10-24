//
//  ImageViewController.swift
//  Homepwner
//
//  Created by Spencer Greene on 7/23/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    var image: UIImage? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let view = self.view as! UIImageView
        view.image = self.image
    }
    
    override func loadView() {
        let imageView = UIImageView()
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        self.view = imageView
    }
    
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
