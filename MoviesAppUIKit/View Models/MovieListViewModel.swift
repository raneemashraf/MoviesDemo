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
    @Published var isLoadingMore: Bool = false
    
    private var searchSubject = CurrentValueSubject<String, Never>("")
    private var currentPage: Int = 1
    private var canLoadMore: Bool = true
    private var currentSearchText: String = ""
    
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
        setupSearchPublisher()
    }
    
    private func setupSearchPublisher() {
        
        searchSubject
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                self?.currentPage = 1
                self?.canLoadMore = true
                self?.currentSearchText = searchText
                self?.loadMovies(search: searchText, page: 1, isLoadingMore: false)
            }.store(in: &cancellables)
        
    }
    
    func setSearchText(_ searchText: String) {
        searchSubject.send(searchText)
    }
    
    func loadMovies(search: String, page: Int = 1, isLoadingMore: Bool = false) {
        guard !search.isEmpty else {
            self.movies = []
            self.loadingCompleted = true
            return
        }
        
        guard !self.isLoadingMore else { return }
        
        if isLoadingMore {
            self.isLoadingMore = true
        }
        
        httpClient.fetchMovies(search: search, page: page)
            .sink { [weak self] completion in
                switch completion {
                    case .finished:
                        self?.loadingCompleted = true
                        self?.isLoadingMore = false
                case .failure(_):
                        self?.loadingCompleted = true
                        self?.isLoadingMore = false
                }
            } receiveValue: { [weak self] newMovies in
                guard let self = self else { return }
                
                if isLoadingMore {
                    self.movies.append(contentsOf: newMovies)
                } else {
                    self.movies = newMovies
                }
                
                if newMovies.isEmpty {
                    self.canLoadMore = false
                }
            }.store(in: &cancellables)
    }
    
    func loadNextPage() {
        guard canLoadMore && !isLoadingMore && !currentSearchText.isEmpty else {
            return
        }
        
        currentPage += 1
        loadMovies(search: currentSearchText, page: currentPage, isLoadingMore: true)
    }
    
}
