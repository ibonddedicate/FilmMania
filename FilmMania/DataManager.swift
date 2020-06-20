//
//  DataManager.swift
//  FilmMania
//
//  Created by Surote Gaide on 19/6/20.
//  Copyright © 2020 Surote Gaide. All rights reserved.
//

import Foundation

protocol MovieDetailsDelegate {
    func didGetMovieDetail(dataManager: DataManager, movie: MovieDetails)
    func didFail(error: Error)
}
protocol AllMoviesDelegate {
    func didGetMovies(dataManager: DataManager, movie: MovieData)
    func didFail(error: Error)
}


class DataManager {
    
    var movieDetailsDelegate: MovieDetailsDelegate?
    var allMoviesDelegate: AllMoviesDelegate?
    let apiKey = "669dc7d62269256de672baf81a231594"
    let movieDetailsURL = "https://api.themoviedb.org/3/movie/"
    let movieDetailsTrailingURL = "?api_key="
    let allMoviesURL = "https://api.themoviedb.org/3/discover/movie?api_key="
    let allMoviesTrailingURL = "&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page="
    
    func downloadMovieDetailJSON(id : Int, completionHandler completion: @escaping ((MovieDetails)->Void)){
        let finalUrl = "\(movieDetailsURL)\(id)\(movieDetailsTrailingURL)\(apiKey)"
        if let url = URL(string: finalUrl){
            let request = URLRequest(url: url)
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    self.movieDetailsDelegate?.didFail(error: error!)
                    return
                }
                print("Movie Details Downloaded")
                do {
                    let decoder = JSONDecoder()
                    let decodedMovie = try decoder.decode(MovieDetails.self, from: data!)
                    self.movieDetailsDelegate?.didGetMovieDetail(dataManager: self, movie: decodedMovie)
                    completion(decodedMovie)
                } catch {
                    self.movieDetailsDelegate?.didFail(error: error)
                }
            }
            task.resume()
        }
    }
    
    func downloadAllMoviesJSON(page : Int){
        let finalUrl = "\(allMoviesURL)\(apiKey)\(allMoviesTrailingURL)\(page)"
        if let url = URL(string: finalUrl){
            let request = URLRequest(url: url)
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    self.allMoviesDelegate?.didFail(error: error!)
                    return
                }
                print("All Movies on page \(page) Downloaded")
                do {
                    let decoder = JSONDecoder()
                    let decodedMovie = try decoder.decode(MovieData.self, from: data!)
                    self.allMoviesDelegate?.didGetMovies(dataManager: self, movie: decodedMovie)
                } catch {
                    self.allMoviesDelegate?.didFail(error: error)
                }
            }
            task.resume()
        }
    }
    
}
