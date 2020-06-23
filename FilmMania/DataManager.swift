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
protocol SearchedMovieDelegate{
    func didGetSearchedMovie(dataManager: DataManager, movie: MovieData)
    func didFail(error: Error)
}


class DataManager {
    
    var movieDetailsDelegate: MovieDetailsDelegate?
    var allMoviesDelegate: AllMoviesDelegate?
    var searchedMovieDelegate: SearchedMovieDelegate?
    let apiKey = "669dc7d62269256de672baf81a231594"
    let movieDetailsURL = "https://api.themoviedb.org/3/movie/"
    let movieDetailsTrailingURL = "?api_key="
    let allMoviesURL = "https://api.themoviedb.org/3/discover/movie?api_key="
    let allMoviesTrailingURL = "&language=en-US&sort_by=popularity.desc&include_adult=false&page="
    let searchedMovieURL = "https://api.themoviedb.org/3/search/movie?api_key="
    
    func downloadMovieDetailJSON(id : Int, completionHandler completion: @escaping (()->Void)){
        let finalUrl = "\(movieDetailsURL)\(id)\(movieDetailsTrailingURL)\(apiKey)"
        if let url = URL(string: finalUrl){
            let request = URLRequest(url: url)
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    self.movieDetailsDelegate?.didFail(error: error!)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let decodedMovie = try decoder.decode(MovieDetails.self, from: data!)
                    self.movieDetailsDelegate?.didGetMovieDetail(dataManager: self, movie: decodedMovie)
                    completion()
                } catch {
                    self.movieDetailsDelegate?.didFail(error: error)
                }
            }
            task.resume()
        }
    }
    
    func downloadAllMoviesJSON(page : Int, genres : String){
        let finalUrl = "\(allMoviesURL)\(apiKey)\(allMoviesTrailingURL)\(page)&with_genres=\(genres)"
        if let url = URL(string: finalUrl){
            let request = URLRequest(url: url)
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    self.allMoviesDelegate?.didFail(error: error!)
                    return
                }
                print("Genre id \(genres) Movies on page \(page) Downloaded")
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
    
    func downloadSearchedMovieJSON(named: String, completionHandler completion: @escaping (()->Void)){
        let fixedName = named.replacingOccurrences(of: " ", with: "%20")
        let finalUrl = "\(searchedMovieURL)\(apiKey)&query=\(fixedName)"
        if let url = URL(string: finalUrl){
            let request = URLRequest(url: url)
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    self.searchedMovieDelegate?.didFail(error: error!)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let decodedMovie = try decoder.decode(MovieData.self, from: data!)
                    self.searchedMovieDelegate?.didGetSearchedMovie(dataManager: self, movie: decodedMovie)
                    print("Got \(decodedMovie.results.count) search results")
                    completion()
                } catch {
                    self.searchedMovieDelegate?.didFail(error: error)
                }
            }
            task.resume()
        }
    }
    
}
