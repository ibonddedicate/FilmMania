//
//  DataManager.swift
//  FilmMania
//
//  Created by Surote Gaide on 19/6/20.
//  Copyright © 2020 Surote Gaide. All rights reserved.
//

import Foundation

protocol TrendingMovieDelegate {
    func didGetMovieData(dataManager: DataManager, movie: MovieData)
    func didFail(error: Error)
}


class DataManager {
    
    var trendingMovieDelegate: TrendingMovieDelegate?
    let apiKey = "669dc7d62269256de672baf81a231594"
    let trendingUrl = "https://api.themoviedb.org/3/trending/movie/day?api_key="
    
    func downloadTrendingJSON(){
        let finalUrl = "\(trendingUrl)\(apiKey)"
        if let url = URL(string: finalUrl){
            let request = URLRequest(url: url)
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    self.trendingMovieDelegate?.didFail(error: error!)
                    return
                }
                print("Movies Downloaded")
                do {
                    let decoder = JSONDecoder()
                    let decodedMovie = try decoder.decode(MovieData.self, from: data!)
                    print(decodedMovie.results.count)
                    self.trendingMovieDelegate?.didGetMovieData(dataManager: self, movie: decodedMovie)
                } catch {
                    self.trendingMovieDelegate?.didFail(error: error)
                }
            }
            task.resume()
        }
    }
    
}
