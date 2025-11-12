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
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    private var viewModel: MovieListViewModel!
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize view model
        viewModel = MovieListViewModel(httpClient: HTTPClient())
        
        setupUI()
        setupBindings()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        // Customize search bar
        searchBar.searchBarStyle = .minimal
        searchBar.barTintColor = .systemBlue
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.layer.cornerRadius = 10
        searchBar.searchTextField.clipsToBounds = true
        
        // Customize table view
        moviesTableView.backgroundColor = .systemGroupedBackground
        moviesTableView.separatorStyle = .singleLine
        moviesTableView.rowHeight = UITableView.automaticDimension
        moviesTableView.estimatedRowHeight = 60
        
        // Customize activity indicator
        activityIndicator.style = .large
        activityIndicator.color = .systemBlue
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
