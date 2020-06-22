//
//  MovieData.swift
//  FilmMania
//
//  Created by Surote Gaide on 19/6/20.
//  Copyright © 2020 Surote Gaide. All rights reserved.
//

import Foundation

struct MovieData : Codable {
    let results : [Movie]
}

struct Movie : Codable {
    let id : Int
    let title : String?
    let posterPath : String?
    let backdropPath : String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
    }
}

struct MovieDetails : Codable {
    let backdropPath : String?
    let title : String?
    let overview : String?
    let voteAverage : Double
    let releaseDate : String?
    
    enum CodingKeys: String, CodingKey {
        case backdropPath = "backdrop_path"
        case title
        case overview
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
    }
}
