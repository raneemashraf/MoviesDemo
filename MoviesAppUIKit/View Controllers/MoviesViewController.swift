//
//  MoviesViewController.swift
//  MoviesAppUIKit
//
//  Created by Raneem Ashraf on 10/11/2025.
//

import Foundation
import UIKit
import SwiftUI
import Combine

class MoviesViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var moviesTableView: UITableView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    private var viewModel: MovieListViewModel!
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize view model
        viewModel = MovieListViewModel(httpClient: HTTPClient())
        
        // setupUI()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupBindings() {
        // Observe loading state
        viewModel.$loadingCompleted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completed in
                if completed {
                    self?.activityIndicator.stopAnimating()
                    self?.moviesTableView.reloadData()
                }
            }.store(in: &cancellables)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension MoviesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movie = viewModel.movies[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell", for: indexPath)
        
        // Configure cell appearance
        var content = cell.defaultContentConfiguration()
        content.text = movie.title
        content.secondaryText = "Year: \(movie.year)"
        
        // Customize text styles
        content.textProperties.font = .systemFont(ofSize: 16, weight: .semibold)
        content.textProperties.color = .label
        content.secondaryTextProperties.font = .systemFont(ofSize: 13, weight: .regular)
        content.secondaryTextProperties.color = .secondaryLabel
        
        cell.contentConfiguration = content
        cell.backgroundColor = .white
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let movie = viewModel.movies[indexPath.row]
        navigateToMovieDetail(movieTitle: movie.title)
    }
    
    private func navigateToMovieDetail(movieTitle: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "MovieDetailViewController") as? MovieDetailViewController else {
            return
        }
        
        detailVC.movieTitle = movieTitle
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Load next page when user scrolls near the bottom (within 3 rows)
        let lastRowIndex = viewModel.movies.count - 1
        if indexPath.row >= lastRowIndex - 2 {
            viewModel.loadNextPage()
        }
    }
}

// MARK: - UISearchBarDelegate
extension MoviesViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            activityIndicator.startAnimating()
        }
        viewModel.setSearchText(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
