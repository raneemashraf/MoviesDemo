//
//  MovieDetailViewModel.swift
//  MoviesAppUIKit
//
//  Created by Raneem Ashraf on 11/25/2025.
//

import Foundation
import Combine

class MovieDetailViewModel {
    
    @Published private(set) var movieDetail: MovieDetail?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables: Set<AnyCancellable> = []
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func loadMovieDetails(title: String) {
        isLoading = true
        errorMessage = nil
        
        httpClient.fetchMovieDetails(title: title)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = "Failed to load movie details: \(error.localizedDescription)"
                }
            } receiveValue: { [weak self] detail in
                self?.movieDetail = detail
            }
            .store(in: &cancellables)
    }
}


