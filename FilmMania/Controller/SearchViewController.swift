//
//  SearchViewController.swift
//  FilmMania
//
//  Created by Surote Gaide on 22/6/20.
//  Copyright © 2020 Surote Gaide. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class SearchViewController: UIViewController, SearchedMovieDelegate  {
    
    var searchedMovieArray = [Movie]()
    var dataManager = DataManager()
    var movieDetail:MovieDetails?
    var ref: DatabaseReference!
    var watchedMovie = [Int]()
    var selectedMovieDetail:IndexPath?
    
    @IBOutlet weak var noResultPic: UIImageView!
    @IBOutlet weak var searchedMovieCV: UICollectionView!
    @IBOutlet weak var navBar: UINavigationItem!

    var movieSearched:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dataManager.searchedMovieDelegate = self
        dataManager.movieDetailsDelegate = self
        searchedMovieCV.delegate = self
        searchedMovieCV.dataSource = self
        bringUpSearchBox()
        getUserWatchedList {}
    }
    override func viewDidAppear(_ animated: Bool) {
        getUserWatchedList {
            if self.selectedMovieDetail != nil {
                self.searchedMovieCV.reloadItems(at: [self.selectedMovieDetail!])
            }
        }
    }

    @IBAction func searchButton(_ sender: Any) {
        bringUpSearchBox()
    }
    
    func bringUpSearchBox() {
        let searchAppearance = SCLAlertView.SCLAppearance(showCloseButton: false, showCircularIcon: false)
        let searchBox = SCLAlertView(appearance: searchAppearance)
        let txt = searchBox.addTextField("Movie Name")
        txt.layer.borderColor = UIColor.systemOrange.cgColor
        txt.backgroundColor = UIColor.white
        txt.textColor = UIColor.black
        searchBox.addButton("Search", backgroundColor: UIColor.systemOrange) {
            print("Search for : \(txt.text!)")
            if txt.text! != "" {
                self.navBar.title = "\(txt.text!)"
            }
            self.dataManager.downloadSearchedMovieJSON(named: txt.text!) {
                DispatchQueue.main.async {
                    self.searchedMovieCV.reloadData()
                    self.searchedMovieCV.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath,
                                                      at: .top,animated: true)
                }
            }
            
        }
        movieSearched = txt.text
        searchBox.showInfo("Search for movies", subTitle: "Enter full or partial movie name that you would like to find")
    }
    
    func didGetSearchedMovie(dataManager: DataManager, movie: MovieData) {
        searchedMovieArray = movie.results.filter({ (movie) -> Bool in
            movie.backdropPath != nil
        })
        print("\(searchedMovieArray.count) Proper search results were chosen from total results")
    }
    
    func didFail(error: Error) {
        print(error)
    }
    
    func getUserWatchedList(completion: @escaping (()->Void)) {
        ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        let watchedRef = db.collection("users").document(userID!)
        watchedRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let watched = document.get("watched")
                self.watchedMovie = watched as! [Int]
                completion()
            } else {
                print("Document does not exist \(error!)")
            }
        }
    }
    
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchedMovieArray.count == 0 {
            searchedMovieCV.isHidden = true
            noResultPic.isHidden = false
        } else {
            noResultPic.isHidden = true
            searchedMovieCV.isHidden = false
        }
        return searchedMovieArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchedMovie", for: indexPath) as! SearchedMovieCell
        cell.watchedBanner.isHidden = true
        for i in watchedMovie {
            if i == searchedMovieArray[indexPath.row].id {
                cell.watchedBanner.isHidden = false
            }
        }
        let imageUrl = searchedMovieArray[indexPath.row].backdropPath!
        let url = URL(string: "https://image.tmdb.org/t/p/original\(imageUrl)")!
        cell.movieImage.load(url: url)
        cell.movieName.text = searchedMovieArray[indexPath.row].title!
        cell.layer.cornerRadius = 10
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMovieDetail = indexPath
        dataManager.downloadMovieDetailJSON(id: searchedMovieArray[indexPath.row].id) {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "ToMovieDetail", sender: self)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, 50, 0)
        cell.layer.transform = rotationTransform
        cell.alpha = 0
        UIView.animate(withDuration: 0.50) {
            cell.layer.transform = CATransform3DIdentity
            cell.alpha = 1.0
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MovieDetailController {
            destination.localMovieTitle = movieDetail?.title
            destination.localMoviePosterURL = movieDetail?.backdropPath
            destination.localMovieOverview = movieDetail?.overview
            destination.localMovieGlobalRating = movieDetail?.voteAverage
            destination.localMovieReleasedDate = movieDetail?.releaseDate
            destination.localMovieID = movieDetail?.id
        }
    }
}

extension SearchViewController: MovieDetailsDelegate {
    func didGetMovieDetail(dataManager: DataManager, movie: MovieDetails) {
        movieDetail = movie
    }
    
}
