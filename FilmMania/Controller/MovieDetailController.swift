//
//  MovieDetailController.swift
//  FilmMania
//
//  Created by Surote Gaide on 20/6/20.
//  Copyright © 2020 Surote Gaide. All rights reserved.
//

import UIKit

class MovieDetailController: UIViewController {

    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieOverview: UILabel!
    @IBOutlet weak var movieGlobalRating: UILabel!
    var localMovieTitle: String?
    var localMoviePosterURL: String?
    var localMovieOverview : String?
    var localMovieGlobalRating : Double?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        movieTitle.text = localMovieTitle!
        setMovieData()
    }
    
    func setMovieData() {
        if localMoviePosterURL != nil {
            let finalUrl = URL(string: "https://image.tmdb.org/t/p/original\(localMoviePosterURL!)")
            moviePoster.load(url: finalUrl!)
        }
        if localMovieOverview != nil {
            movieOverview.text = localMovieOverview!
        } else {
            movieOverview.text = "No Description Available."
        }
        if localMovieGlobalRating != nil {
            movieGlobalRating.text = String(localMovieGlobalRating!)
        }
    }
}
