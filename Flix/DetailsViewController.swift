//
//  DetailsViewController.swift
//  Flix
//
//  Created by Grace Kotick on 6/16/16.
//  Copyright © 2016 Grace Kotick. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var overviewLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moviePoster: UIImageView!
    var movie: NSDictionary!
    override func viewDidLoad() {
        super.viewDidLoad()
        let title = movie["title"] as? String
        titleLabel.text = title
        
        let overview = movie["overview"]
        overviewLabel.text = overview as? String
        overviewLabel.sizeToFit()
        let baseURL = "http://image.tmdb.org/t/p/w500/"
        if let posterPath = movie["poster_path"] as? String {
            let posterURL = NSURL(string: baseURL + posterPath)
            moviePoster.setImageWithURL(posterURL!)
        }
        self.view.backgroundColor = UIColor.blackColor()
        print(movie)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
