//
//  HomeViewController.swift
//  FilmMania
//
//  Created by Surote Gaide on 18/6/20.
//  Copyright © 2020 Surote Gaide. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    var dataManager = DataManager()
    var moviesArray = [Movie]()
    @IBOutlet weak var moviesCV: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dataManager.trendingMovieDelegate = self
        dataManager.downloadTrendingJSON()
        moviesCV.delegate = self
        moviesCV.dataSource = self
    }
    
    @IBAction func logoffButton(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let VC = storyboard.instantiateViewController(identifier: "Login")
            self.view.window?.rootViewController = VC
        } catch let logoffError as NSError {
            print(logoffError)
        }
        
    }

}

extension HomeViewController: TrendingMovieDelegate {
    
    func didGetMovieData(dataManager: DataManager, movie: MovieData) {
        moviesArray = movie.results
        print(moviesArray[0].id)
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
    
    
}

extension UIImageView {
    func load(url:URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
