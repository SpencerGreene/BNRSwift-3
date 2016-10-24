//
//  QuizViewController.swift
//  Quiz
//
//  Created by Spencer Greene on 6/28/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController {
    
    var currentQuestionIndex = -1
    let questions = ["Who am I?", "What is 12 x 3", "Who is hot", "Battle of Hastings?"]
    let answers = ["Toby", "36", "Santosh", "1066"]
    
    @IBOutlet var questionLabel: UILabel?
    @IBOutlet var answerLabel: UILabel?
    
    @IBAction func showQuestion(_: AnyObject) {
        currentQuestionIndex = (currentQuestionIndex + 1) % questions.count
        self.questionLabel!.text = questions[currentQuestionIndex]
        self.answerLabel!.text = "???"
    }
    
    @IBAction func showAnswer(_: AnyObject) {
        self.answerLabel!.text = answers[currentQuestionIndex]
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization

    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    convenience init() {
        self.init(nibName: "QuizViewController", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
