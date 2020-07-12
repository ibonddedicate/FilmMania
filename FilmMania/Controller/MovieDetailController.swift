//
//  MovieDetailController.swift
//  FilmMania
//
//  Created by Surote Gaide on 20/6/20.
//  Copyright © 2020 Surote Gaide. All rights reserved.
//

import UIKit
import Firebase

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
    @IBOutlet weak var memberViews: UILabel!
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
        getCurrentView(movieID: localMovieID!)
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
                print("Document does not exist \(error!)")
            }
        }
    }
    
    @IBAction func markAsWatched(_ sender: UIButton) {
        ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        let watchedRef = db.collection("users").document(userID!)
        //let viewsRef = db.collection("films").document(String(localMovieID!))
        if watched == true {
            watchedRef.updateData(["watched": FieldValue.arrayRemove([localMovieID!])]) {[weak self] (error) in
                self?.watched = false
                self?.watchedBox.setTitle("Mark as Watched", for: .normal)
                self?.checkForWatched()
                self?.removeViews(movieID: (self?.localMovieID!)!)
                print("Removed movie ID \(self!.localMovieID!) from user ID : \(userID!)")
            }
        } else {
            self.addViews(movieID: self.localMovieID!)
            watchedRef.updateData(["watched": FieldValue.arrayUnion([localMovieID!])])
            print("Added movie ID \(localMovieID!) to user ID : \(userID!)")
            watched = true
            checkForWatched()
        }
        sender.onePulse()
    }
    
    func addViews(movieID: Int) {
        let viewRef = self.ref.child("films").child(String(movieID)).child("views")
        viewRef.observeSingleEvent(of: .value) {[weak self] (snapshot) in
            var currentView = snapshot.value as? Int ?? 0
            currentView += 1
            viewRef.setValue(currentView)
            self?.updateViewlabel(view: currentView)
        }
    }
    func removeViews(movieID: Int) {
        let viewRef = self.ref.child("films").child(String(movieID)).child("views")
        viewRef.observeSingleEvent(of: .value) {[weak self] (snapshot) in
            var currentView = snapshot.value as? Int ?? 0
            currentView -= 1
            viewRef.setValue(currentView)
            self?.updateViewlabel(view: currentView)
        }
    }
    
    func updateViewlabel(view: Int) {
        if view > 1 {
            self.memberViews.text = "\(view) members have watched this film"
        } else if view == 1 {
            self.memberViews.text = "Only 1 member have watched this film"
        } else {
            self.memberViews.text = "None of the members have watched this film"
        }
    }
    
    func getCurrentView(movieID: Int) {
        let viewRef = self.ref.child("films").child(String(movieID)).child("views")
        viewRef.observeSingleEvent(of: .value) { (snapshot) in
            let currentView = snapshot.value as? Int ?? 0
            self.updateViewlabel(view: currentView)
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
