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
    
    @IBOutlet weak var moviesCV: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dataManager.allMoviesDelegate = self
        dataManager.movieDetailsDelegate = self
        dataManager.downloadAllMoviesJSON(page: currentPage)
        moviesCV.delegate = self
        moviesCV.dataSource = self
    }
    
    @IBAction func logoffButton(_ sender: Any) {
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

}

extension HomeViewController: AllMoviesDelegate, MovieDetailsDelegate {
    
    func didGetMovieDetail(dataManager: DataManager, movie: MovieDetails) {
        movieDetail = movie
    }

    func didGetMovies(dataManager: DataManager, movie: MovieData) {
        if currentPage > 1 {
            self.moviesArray.append(contentsOf: movie.results)
        } else {
            moviesArray = movie.results
        }
        DispatchQueue.main.async {
            self.moviesCV.reloadData()
        }
    }
    
    func didFail(error: Error) {
        print(error)
    }
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        moviesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let imageUrl = moviesArray[indexPath.row].posterPath!
        let url = URL(string: "https://image.tmdb.org/t/p/w500\(imageUrl)")!
        cell.moviePoster.load(url: url)
        cell.layer.cornerRadius = 10
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == moviesArray.count - 1 {
            currentPage += 1
            dataManager.downloadAllMoviesJSON(page: currentPage)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataManager.downloadMovieDetailJSON(id: moviesArray[indexPath.row].id) { (data) in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "ToMovieDetail", sender: self)
            }
        }
        //let VC = storyboard?.instantiateViewController(identifier: "MovieDetail")
        //self.navigationController?.pushViewController(VC!, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MovieDetailController {
            destination.localMovieTitle = movieDetail?.title
            destination.localMoviePosterURL = movieDetail?.backdropPath
            destination.localMovieOverview = movieDetail?.overview
            destination.localMovieGlobalRating = movieDetail?.voteAverage
        }
    }
}
