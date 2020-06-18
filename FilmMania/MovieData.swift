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
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case posterPath = "poster_path"
    }
}
