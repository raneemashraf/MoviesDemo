//
//  HTTPClient.swift
//  MoviesAppUIKit
//
//  Created by Raneem Ashraf on 10/11/2025.
//

import Foundation
import Combine

enum NetworkError: Error {
    case badUrl
}

class HTTPClient {
    
    private let baseURL = "https://www.omdbapi.com"
    private let apiKey = "8a7faae1"
    
    func fetchMovies(search: String, page: Int) -> AnyPublisher<[Movie], Error> {
        
        guard let encodedSearch = search.urlEncoded,
              let url = URL(string: "\(baseURL)/?s=\(encodedSearch)&page=\(page)&apiKey=\(apiKey)")
        else {
            return Fail(error: NetworkError.badUrl).eraseToAnyPublisher()
        }
                
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: MovieResponse.self, decoder: JSONDecoder())
            .map(\.Search)
            .receive(on: DispatchQueue.main)
            .catch { error -> AnyPublisher<[Movie], Error> in
                return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func fetchMovieDetails(title: String) -> AnyPublisher<MovieDetail, Error> {
        
        guard let encodedTitle = title.urlEncoded,
              let url = URL(string: "\(baseURL)/?t=\(encodedTitle)&apiKey=\(apiKey)")
        else {
            return Fail(error: NetworkError.badUrl).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: MovieDetail.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
}
