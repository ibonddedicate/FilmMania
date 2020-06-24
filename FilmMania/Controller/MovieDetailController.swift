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
    @IBOutlet weak var watchedBox: UIButton!
    var localMovieTitle: String?
    var localMoviePosterURL: String?
    var localMovieOverview : String?
    var localMovieGlobalRating : Double?
    var localMovieReleasedDate : String?
    var localMovieID : Int?
    var fmColor = FMColor()
    var ref: DatabaseReference!
    var watchedMovie = [Int]()
    var watched = false
    
    
    
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
        checkForWatched()
        watchedBox.layer.cornerRadius = 10
    }
    
    func checkForWatched() {
        watchedBox.backgroundColor = UIColor.systemOrange
        ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        let watchedRef = db.collection("users").document(userID!)
        watchedRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let watched = document.get("watched")
                self.watchedMovie = watched as! [Int]
                for i in self.watchedMovie {
                    if i == self.localMovieID! {
                        self.watchedBox.setTitle("You have watched this movie", for: .normal)
                        self.watchedBox.backgroundColor = UIColor.systemGray
                        self.watched = true
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    @IBAction func markAsWatched(_ sender: Any) {
        ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        let watchedRef = db.collection("users").document(userID!)
        if watched == true {
            watchedRef.updateData(["watched": FieldValue.arrayRemove([localMovieID!])]) { (error) in
                self.watched = false
                self.watchedBox.setTitle("Mark as Watched", for: .normal)
                self.checkForWatched()
                print("removed movie ID \(self.localMovieID!) from \(userID!)")
            }
        } else {
            watchedRef.updateData(["watched": FieldValue.arrayUnion([localMovieID!])])
            print("added movie ID \(localMovieID!) to \(userID!)")
            watched = true
            checkForWatched()
        }
        
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
