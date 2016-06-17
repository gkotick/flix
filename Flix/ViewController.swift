//
//  ViewController.swift
//  Flix
//
//  Created by Grace Kotick on 6/15/16.
//  Copyright © 2016 Grace Kotick. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class ViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate, UICollectionViewDataSource {
    //var collectionOrTable = true
    var movies: [NSDictionary]?
    @IBOutlet weak var movieList: UITableView!
    var request: NSURLRequest?
    var session: NSURLSession?
    var filteredData: [NSDictionary]!
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        movieList.dataSource = self
        collectionView.dataSource = self
        self.loadDataFromNetwork()
        // Initialize a UIRefreshControl
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        movieList.insertSubview(refreshControl, atIndex: 0)
        movieList.dataSource = self
        searchBar.delegate = self
        self.movieList.backgroundColor = UIColor.blackColor()
        
        
        collectionView.insertSubview(refreshControl, atIndex: 0)
        movieList.hidden = false
        collectionView.hidden = true
        
        flowLayout.scrollDirection = .Vertical
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 10)
       

    }
   
    @IBAction func indexChanged(sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            collectionView.hidden = true
            movieList.hidden = false
        case 1:
            collectionView.hidden = false
            movieList.hidden = true
        default:
            break;
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //changed movies to filtered data twice
        if let filteredData = filteredData {
            //changed filtered data from movies
            return filteredData.count
        } else{
           return 0
        }
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        //changed movies to filtered data
        let movie = filteredData![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        let baseURL = "http://image.tmdb.org/t/p/w500"
        let posterPath = movie["poster_path"] as! String
        let imageURL = NSURL(string: baseURL + posterPath)
        
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.posterView.setImageWithURL(imageURL!)
        cell.backgroundColor = UIColor.blackColor()
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.darkGrayColor()
        cell.selectedBackgroundView = backgroundView
        return cell
        
        
        

    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let filteredData = filteredData {
            //changed filtered data from movies
            return filteredData.count
        } else{
            return 0
        }
        
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionCell", forIndexPath: indexPath) as! CollectionCell
        //changed movies to filtered data
        let movie = filteredData![indexPath.row]
        //let title = movie["title"] as! String
        //let overview = movie["overview"] as! String
        
        let baseURL = "http://image.tmdb.org/t/p/w500"
        let posterPath = movie["poster_path"] as! String
        let imageURL = NSURL(string: baseURL + posterPath)
        
        
        
        cell.collectionCell.setImageWithURL(imageURL!)
        
        let imageRequest = NSURLRequest(URL: imageURL!)
        
        cell.setImageWithURLRequest(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    print("Image was NOT cached, fade in image")
                    self.myImageView.alpha = 0.0
                    self.myImageView.image = image
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.myImageView.alpha = 1.0
                    })
                } else {
                    print("Image was cached so just update the image")
                    self.myImageView.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })
        return cell
        
    }

    func makeURL(){
        let apiKey = "e0e987722545d1d8cb1044748a1fbbc1"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        
        self.request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        self.session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
    }
    func loadDataFromNetwork() {
        self.makeURL()
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let task: NSURLSessionDataTask = session!.dataTaskWithRequest(request!,completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options:[]) as? NSDictionary {
                    print("response: \(responseDictionary)")
                    self.movies = responseDictionary["results"] as! [NSDictionary]
                    self.filteredData = self.movies
                    self.movieList.reloadData()
                    self.collectionView.reloadData()
                    
                }
            }
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            
            
        })
        task.resume()

    }
    func refreshControlAction(refreshControl: UIRefreshControl) {
        self.makeURL()
        let task : NSURLSessionDataTask = session!.dataTaskWithRequest(request!,completionHandler: { (data, response, error) in
            // ... Use the new data to update the data source ...
                                                                        
            // Reload the tableView now that there is new data
            self.movieList.reloadData()
                                                                        
            // Tell the refreshControl to stop spinning
            refreshControl.endRefreshing()
        });
        task.resume()
    }
    
    
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty {
            filteredData = movies
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            filteredData = movies!.filter({(dataItem: NSDictionary) -> Bool in
                // If dataItem matches the searchText, return true to include it
                if (dataItem["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                } else {
                    return false
                }
            })
        }
        movieList.reloadData()
        collectionView.reloadData()
    }
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if movieList.hidden == false{
            let cell = sender as! UITableViewCell
        
            let indexPath = movieList.indexPathForCell(cell)
        
            let movie = filteredData![indexPath!.row]
            let detailViewController = segue.destinationViewController as! DetailsViewController
            detailViewController.movie = movie

        }
        else{
            let cell = sender as! UICollectionViewCell
            
            let indexPath = collectionView.indexPathForCell(cell)
            
            let movie = filteredData![indexPath!.row]
            let detailViewController = segue.destinationViewController as! DetailsViewController
            detailViewController.movie = movie
        }
        
        
    }
    
}

