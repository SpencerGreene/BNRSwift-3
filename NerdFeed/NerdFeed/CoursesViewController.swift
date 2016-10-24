//
//  CoursesViewController.swift
//  NerdFeed
//
//  Created by Spencer Greene on 7/24/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import UIKit

class CoursesViewController: UITableViewController {
    
    var session: Foundation.URLSession!
    var courses: Array<NSDictionary>? = nil
    var webViewController: WebViewController? = nil
    

    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nil, bundle: nil)

        let config = URLSessionConfiguration.default
        self.session = Foundation.URLSession(configuration: config, delegate: self, delegateQueue: nil)
        
        self.navigationItem.title = "Course List"
        
        self.fetchFeed()
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    convenience override init(style: UITableViewStyle) {
        self.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if let array = self.courses {
            // NSLog("table row count returning \(array.count)")
            return array.count
        } else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath) as UITableViewCell

        // Configure the cell...
        let course = self.courses![(indexPath as NSIndexPath).row]
        let title = course["title"] as! String?
        cell.textLabel!.text = title!
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let course = self.courses![(indexPath as NSIndexPath).row]
        let urlString = course["url"] as! String
        let myurl = URL(string: urlString)
        NSLog("Set URL to \(myurl) for string \(urlString)")
        
        self.webViewController!.title = course["title"] as? String
        self.webViewController!.installURL(myurl)
        self.webViewController!.hideSplitPopover()
        
        // if we're not in a split controller then go ahead and push the web view on top
        if (self.splitViewController == nil) {
            self.navigationController!.pushViewController(webViewController!, animated: true)
        } else {
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}

// deal with web service
extension CoursesViewController: URLSessionDataDelegate {
    func fetchFeed() {
        // let url = URL(string: "http://bookapi.bignerdranch.com/courses.json")
        let url = URL(string: "https://bookapi.bignerdranch.com/private/courses.json")

        let req = URLRequest(url: url!)
        NSLog("1. formed request")
        
        func handler(_ data: Data?, response: URLResponse?, error: Error?) {
            print("3. entered handler, error is \(error)")
            // let jsonOption = JSONSerialization.ReadingOptions(rawValue: 0)
            if let unwrappedData = data {
                // let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                print("data is \(unwrappedData)")
                let jsonDecoded = try? JSONSerialization.jsonObject(with: unwrappedData)
                if let jsonResult = jsonDecoded as? [String: Any] {
                    self.courses = jsonResult["courses"] as? Array<NSDictionary>
                    if let array = self.courses {
                        NSLog("fetched json \(array.count) courses")
                    } else {
                        NSLog("json fetched but no key for courses")
                    }
                } else {
                    NSLog("jsonResult was not valid dictionary")
                    NSLog("result received was \(jsonDecoded)")
                }
            } else {
                NSLog("data was nil")
            }
            DispatchQueue.main.async(execute: self.tableView.reloadData)
        }
        
        let dataTask = self.session.dataTask(with: req, completionHandler: handler)
        NSLog("2. formed task")
        dataTask.resume()
    }
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            
            print("credential delegate called\n")
            
            let cred = URLCredential(
                user: "BigNerdRanch",
                password: "AchieveNerdvana",
                persistence: URLCredential.Persistence.forSession)
            
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, cred)
    }
    
}
