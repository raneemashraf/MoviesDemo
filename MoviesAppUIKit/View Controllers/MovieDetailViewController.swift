//
//  MovieDetailViewController.swift
//  MoviesAppUIKit
//
//  Created by Raneem Ashraf on 11/25/2025.
//

import UIKit
import Combine

class MovieDetailViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var yearLabel: UILabel!
    @IBOutlet private weak var runtimeLabel: UILabel!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!
    @IBOutlet private weak var directorLabel: UILabel!
    @IBOutlet private weak var actorsLabel: UILabel!
    @IBOutlet private weak var plotTextView: UITextView!
    @IBOutlet private weak var imdbRatingLabel: UILabel!
    @IBOutlet private weak var awardsLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    // MARK: - Properties
    private var viewModel: MovieDetailViewModel!
    private var cancellables: Set<AnyCancellable> = []
    var movieTitle: String?
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = MovieDetailViewModel(httpClient: HTTPClient())
        setupBindings()
        
        if let title = movieTitle {
            self.title = "Movie Details"
            viewModel.loadMovieDetails(title: title)
        }
        
        scrollView.alpha = 0
    }
    
    private func setupBindings() {

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        

        viewModel.$movieDetail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] detail in
                guard let self = self, let detail = detail else { return }
                self.updateUI(with: detail)
            }
            .store(in: &cancellables)
        

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let error = errorMessage {
                    self?.showError(error)
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(with detail: MovieDetail) {
        titleLabel.text = detail.title
        yearLabel.text = detail.year
        runtimeLabel.text = detail.runtime
        ratingLabel.text = detail.rated
        genreLabel.text = "Genre: \(detail.genre)"
        directorLabel.text = "Director: \(detail.director)"
        actorsLabel.text = "Cast: \(detail.actors)"
        plotTextView.text = detail.plot
        imdbRatingLabel.text = "⭐️ \(detail.imdbRating)/10 (\(detail.imdbVotes) votes)"
        awardsLabel.text = detail.awards
        
        // Load poster image
        loadPosterImage(from: detail.poster)
        
        // Fade in content
        UIView.animate(withDuration: 0.3) {
            self.scrollView.alpha = 1
        }
    }
    
    private func loadPosterImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.posterImageView.image = image
            }
        }.resume()
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

