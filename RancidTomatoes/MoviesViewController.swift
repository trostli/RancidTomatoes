//
//  MoviesViewController.swift
//  RancidTomatoes
//
//  Created by Daniel Trostli on 5/10/15.
//  Copyright (c) 2015 Trostli. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    var url: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "downloadMovieData", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        downloadMovieData()
    }
    
    func downloadMovieData() {
        SVProgressHUD.show()
        let tabBarSelected = self.tabBarItem.title
        if tabBarSelected == "Box Office" {
            url = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")!
        } else {
            url = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/e41513a57049e21bc6cf/raw/b490e79be2d21818f28614ec933d5d8f467f0a66/gistfile1.json")
        }
        
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            let json = (try? NSJSONSerialization.JSONObjectWithData(data!, options: [])) as? NSDictionary
            if let json = json {
                self.movies = json["movies"] as? [NSDictionary]
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
                self.refreshControl.endRefreshing()
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        
        cell.titleLabel?.text = movie["title"] as? String
        cell.synopsisLabel?.text = movie["synopsis"] as? String
        
        var urlString = movie.valueForKeyPath("posters.thumbnail") as! String!
        let range = urlString.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        if let range = range {
            urlString = urlString.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
    
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        cell.posterView.alpha = 0
        
        cell.posterView.setImageWithURLRequest(request, placeholderImage: nil, success: { (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) -> Void in
            cell.posterView.image = image
            UIView.animateWithDuration(0.3, animations: {
                cell.posterView.alpha = 1
            })
            }) { (request: NSURLRequest!, response: NSHTTPURLResponse!, error: NSError!) -> Void in
            print("ERROR")
//                Whats the best way to handle useful message here?
            }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

   //  MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)!
        
        let movie = movies![indexPath.row]
        
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        
        movieDetailsViewController.movie = movie
        movieDetailsViewController.title = movie["title"] as? String
        movieDetailsViewController.hidesBottomBarWhenPushed = true
    }

}
