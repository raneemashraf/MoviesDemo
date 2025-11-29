//
//  Movie.swift
//  MoviesAppUIKit
//
//  Created by Raneem Ashraf on 10/11/2025.
//

import Foundation

struct MovieResponse: Decodable {
    let Search: [Movie]
}

struct Movie: Decodable {
    
    let title: String
    let year: String
    let type: String
    let poster: String
    
    private enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case type = "Type"
        case poster = "Poster"
    }
}

