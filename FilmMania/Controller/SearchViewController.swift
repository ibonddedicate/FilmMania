//
//  SearchViewController.swift
//  FilmMania
//
//  Created by Surote Gaide on 22/6/20.
//  Copyright © 2020 Surote Gaide. All rights reserved.
//

import UIKit
import SCLAlertView

class SearchViewController: UIViewController, SearchedMovieDelegate  {
    
    var searchedMovieArray = [Movie]()
    var dataManager = DataManager()
    var movieDetail:MovieDetails?
    @IBOutlet weak var noResultPic: UIImageView!
    @IBOutlet weak var searchedMovieCV: UICollectionView!
    
    var movieSearched:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dataManager.searchedMovieDelegate = self
        dataManager.movieDetailsDelegate = self
        searchedMovieCV.delegate = self
        searchedMovieCV.dataSource = self
        bringUpSearchBox()
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
            print("Button Pressed : \(txt.text!)")
            self.dataManager.downloadSearchedMovieJSON(named: txt.text!) {
                DispatchQueue.main.async {
                    self.searchedMovieCV.reloadData()
                }
            }
            
        }
        movieSearched = txt.text
        searchBox.showInfo("Search", subTitle: "Enter full or partial movie name that you would like to find")
    }
    
    func didGetSearchedMovie(dataManager: DataManager, movie: MovieData) {
        searchedMovieArray = movie.results
    }
    
    func didFail(error: Error) {
        print(error)
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
        if searchedMovieArray[indexPath.row].backdropPath != nil {
            let imageUrl = searchedMovieArray[indexPath.row].backdropPath!
            let url = URL(string: "https://image.tmdb.org/t/p/original\(imageUrl)")!
            cell.movieImage.load(url: url)
        } else {
            cell.movieImage.image = UIImage(named: "noposter.jpg")
        }
        cell.movieName.text = searchedMovieArray[indexPath.row].title!
        cell.layer.cornerRadius = 10
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataManager.downloadMovieDetailJSON(id: searchedMovieArray[indexPath.row].id) {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "ToMovieDetail", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MovieDetailController {
            destination.localMovieTitle = movieDetail?.title
            destination.localMoviePosterURL = movieDetail?.backdropPath
            destination.localMovieOverview = movieDetail?.overview
            destination.localMovieGlobalRating = movieDetail?.voteAverage
            destination.localMovieReleasedDate = movieDetail?.releaseDate
        }
    }
}

extension SearchViewController: MovieDetailsDelegate {
    func didGetMovieDetail(dataManager: DataManager, movie: MovieDetails) {
        movieDetail = movie
    }
    
}
