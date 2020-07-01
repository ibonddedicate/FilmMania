//
//  HomeViewController.swift
//  FilmMania
//
//  Created by Surote Gaide on 18/6/20.
//  Copyright © 2020 Surote Gaide. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView


class HomeViewController: UIViewController {
    
    var dataManager = DataManager()
    var moviesArray = [Movie]()
    var currentPage = 1
    var movieDetail:MovieDetails?
    var genresArray = [Genres]()
    var selectedGenres = ""
    var ref: DatabaseReference!
    var watchedMovie = [Int]()
    var selectedMovieDetail:IndexPath?
    
    @IBOutlet weak var genreBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var moviesCV: UICollectionView!
    @IBOutlet weak var genreCV: UICollectionView!
    @IBOutlet weak var titleBar: UINavigationItem!

    
    let listRefresh: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.systemGray
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        makeGenreList()
        dataManager.allMoviesDelegate = self
        dataManager.movieDetailsDelegate = self
        moviesCV.delegate = self
        moviesCV.dataSource = self
        moviesCV.refreshControl = listRefresh
        genreCV.delegate = self
        genreCV.dataSource = self
        getUserWatchedList {
            self.dataManager.downloadAllMoviesJSON(page: self.currentPage, genres: self.selectedGenres)
            self.moviesCV.reloadData()
        }
    }
        
    @objc func refresh(sender: UIRefreshControl){
        dataManager.downloadAllMoviesJSON(page: 1, genres: selectedGenres)
        sender.endRefreshing()
        print("Refreshed : Reset back to Page 1")
    }
    
    func makeGenreList() {
        let all = Genres(id: "", name: "All", bgColor: UIColor.systemOrange)
        genresArray.append(all)
        let action = Genres(id: "28", name: "Action", bgColor: UIColor.systemGray)
        genresArray.append(action)
        let adventure = Genres(id: "12", name: "Adventure", bgColor: UIColor.systemGray)
        genresArray.append(adventure)
        let comedy = Genres(id: "35" , name: "Comedy", bgColor: UIColor.systemGray)
        genresArray.append(comedy)
        let drama = Genres(id: "18", name: "Drama", bgColor: UIColor.systemGray)
        genresArray.append(drama)
        let horror = Genres(id: "27", name: "Horror", bgColor: UIColor.systemGray)
        genresArray.append(horror)
        let romance = Genres(id: "10749", name: "Romance", bgColor: UIColor.systemGray)
        genresArray.append(romance)
        let thriller = Genres(id: "53", name: "Thriller", bgColor: UIColor.systemGray)
        genresArray.append(thriller)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        getUserWatchedList {
            if self.selectedMovieDetail != nil {
                self.moviesCV.reloadItems(at: [self.selectedMovieDetail!])
                print("Loaded updated user watched list")
            }
        }
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
    
    @IBAction func logoffButton(_ sender: Any) {
        let logoutAppearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        let logoutBox = SCLAlertView(appearance: logoutAppearance)
        logoutBox.addButton("Yes") {
            do {
                try Auth.auth().signOut()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let VC = storyboard.instantiateViewController(identifier: "Login")
                self.view.window?.rootViewController = VC
                SCLAlertView().showNotice("Logged out", subTitle: "You have sucessfully logged out from your account")
            } catch let logoffError as NSError {
                print(logoffError)
            }
        }
        logoutBox.addButton("No") {
            logoutBox.dismiss(animated: true) {
                print("Cancelled logout")
            }
        }
        logoutBox.showWarning("Logout", subTitle: "Are you sure you want to logout?")

    }
}

extension HomeViewController: AllMoviesDelegate, MovieDetailsDelegate {
    
    func didGetMovieDetail(dataManager: DataManager, movie: MovieDetails) {
        movieDetail = movie
    }

    func didGetMovies(dataManager: DataManager, movie: MovieData) {
        if currentPage > 1 {
            let lastInArray = moviesArray.count
            self.moviesArray.append(contentsOf: movie.results)
            let newLastInArray = moviesArray.count
            let indexPaths = Array(lastInArray..<newLastInArray).map{IndexPath(item: $0, section: 0)}
            DispatchQueue.main.async {
                    self.moviesCV.insertItems(at: indexPaths)
            }
        } else {
            moviesArray = movie.results
            DispatchQueue.main.async {
                self.moviesCV.reloadData()
            }
        }
    }
    
    func didFail(error: Error) {
        print(error)
    }
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.moviesCV {
            return moviesArray.count
        } else {
            return genresArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.moviesCV {
            let cellA = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell
            let imageUrl = moviesArray[indexPath.row].posterPath!
            let url = URL(string: "https://image.tmdb.org/t/p/w500\(imageUrl)")!
            cellA.watchedBanner.isHidden = true
            for i in watchedMovie {
                if i == moviesArray[indexPath.row].id {
                    cellA.watchedBanner.isHidden = false
                }
            }
            cellA.moviePoster.load(url: url)
            cellA.layer.cornerRadius = 10
            return cellA
        } else {
            let cellB = collectionView.dequeueReusableCell(withReuseIdentifier: "GenreCell", for: indexPath) as! GenreCell
            cellB.genreName.text = genresArray[indexPath.row].name
            cellB.backgroundColor = genresArray[indexPath.row].bgColor
            cellB.layer.cornerRadius = 15
            return cellB
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.moviesCV {
            let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, 50, 0)
            cell.layer.transform = rotationTransform
            cell.alpha = 0
            UIView.animate(withDuration: 0.50) {
                cell.layer.transform = CATransform3DIdentity
                cell.alpha = 1.0
            }
            if indexPath.row == moviesArray.count - 1 {
                currentPage += 1
                dataManager.downloadAllMoviesJSON(page: currentPage, genres: selectedGenres)
            }
        } else {
            cell.alpha = 0
            UIView.animate(withDuration: 0.50) {
                cell.alpha = 1.0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.moviesCV {
            selectedMovieDetail = indexPath
            dataManager.downloadMovieDetailJSON(id: moviesArray[indexPath.row].id) {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "ToMovieDetail", sender: self)
                }
            }
        } else {
            selectedGenres = genresArray[indexPath.row].id
            currentPage = 1
            dataManager.downloadAllMoviesJSON(page: currentPage, genres: selectedGenres)
            self.moviesCV.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .top,animated: true)
            titleBar.title = "\(genresArray[indexPath.row].name) Movies"
            for genre in genresArray {
                genre.bgColor = UIColor.systemGray
            }
            genresArray[indexPath.row].bgColor = UIColor.systemOrange
            genreCV.reloadData()
            genreCV.scrollToItem(at: indexPath, at: .left, animated: true)
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

extension HomeViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.y > 50 {
        view.layoutIfNeeded()
        genreBarHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.75, delay: 0, options: [.allowUserInteraction], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)

    }else {
        // expand the header
        view.layoutIfNeeded()
        genreBarHeightConstraint.constant = 50
        UIView.animate(withDuration: 0.35, delay: 0, options: [.allowUserInteraction], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
     }
    }
}
