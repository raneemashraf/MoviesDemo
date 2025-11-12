//
//  MovieListViewModel.swift
//  MoviesAppUIKit
//
//  Created by Raneem Ashraf on 10/11/2025.
//

import Foundation
import Combine

class MovieListViewModel {
    
    @Published private(set) var movies: [Movie] = []
    private var cancellables: Set<AnyCancellable> = []
    @Published var loadingCompleted: Bool = false
    
    private var searchSubject = CurrentValueSubject<String, Never>("")
    
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
        setupSearchPublisher()
    }
    
    private func setupSearchPublisher() {
        
        searchSubject
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                self?.loadMovies(search: searchText)
            }.store(in: &cancellables)
        
    }
    
    func setSearchText(_ searchText: String) {
        searchSubject.send(searchText)
    }
    
    func loadMovies(search: String) {
        guard !search.isEmpty else {
            self.movies = []
            self.loadingCompleted = true
            return
        }
        
        httpClient.fetchMovies(search: search)
            .sink { [weak self] completion in
                switch completion {
                    case .finished:
                        self?.loadingCompleted = true
                        print("✅ Movies loaded successfully")
                    case .failure(let error):
                        print("❌ Error loading movies: \(error.localizedDescription)")
                        self?.loadingCompleted = true
                }
            } receiveValue: { [weak self] movies in
                self?.movies = movies
                print("📽️ Received \(movies.count) movies")
            }.store(in: &cancellables)
    }
    
}
