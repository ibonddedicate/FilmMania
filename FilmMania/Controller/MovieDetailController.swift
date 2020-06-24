//
//  MovieDetailController.swift
//  FilmMania
//
//  Created by Surote Gaide on 20/6/20.
//  Copyright © 2020 Surote Gaide. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class MovieDetailController: UIViewController {

    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieOverview: UILabel!
    @IBOutlet weak var movieGlobalRating: UILabel!
    @IBOutlet weak var movieReleasedDate: UILabel!
    @IBOutlet weak var releaseDateBox: UIView!
    @IBOutlet weak var ratingBox: UIView!
    @IBOutlet weak var ratingLine: UIView!
    var localMovieTitle: String?
    var localMoviePosterURL: String?
    var localMovieOverview : String?
    var localMovieGlobalRating : Double?
    var localMovieReleasedDate : String?
    var localMovieID : Int?
    var fmColor = FMColor()
    var ref: DatabaseReference!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("\(localMovieTitle!) Details Downloaded")
        releaseDateBox.layer.cornerRadius = 10
        releaseDateBox.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
        ratingBox.layer.cornerRadius = 15
        ratingBox.layer.maskedCorners = [.layerMinXMinYCorner]
        movieTitle.text = localMovieTitle!
        setMovieData()
        setRatingColor()
    }
    
    @IBAction func markAsWatched(_ sender: Any) {
        ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        print(userID!)
        let watchedRef = db.collection("users").document(userID!)
        watchedRef.updateData([
            "watched": FieldValue.arrayUnion([localMovieID!])
        ])
        
        
    }
    
    
    func setRatingColor() {
        if localMovieGlobalRating! >= 5.0 {
            ratingBox.layer.backgroundColor = fmColor.orangeFM.cgColor
            ratingLine.layer.backgroundColor = fmColor.orangeFM.cgColor
            if localMovieGlobalRating! >= 7.5 {
                ratingBox.layer.backgroundColor = fmColor.greenFM.cgColor
                ratingLine.layer.backgroundColor = fmColor.greenFM.cgColor
            }
        } else {
            ratingBox.layer.backgroundColor = fmColor.redFM.cgColor
            ratingLine.layer.backgroundColor = fmColor.redFM.cgColor
        }
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
            if localMovieGlobalRating != 0.0 {
                movieGlobalRating.text = String(localMovieGlobalRating!)
            } else {
                movieGlobalRating.text = "N/A"
            }
        }
        if localMovieReleasedDate != nil {
            movieReleasedDate.text = localMovieReleasedDate!
        }
    }
}
