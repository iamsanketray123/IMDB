//
//  MovieViewController.swift
//  IMDB
//
//  Created by Sanket  Ray on 10/09/22.
//

import UIKit

class MovieViewController: UIViewController {
    
    
    @IBOutlet var tableView: UITableView!
    var movies = [Movie]()
//    var savedPlayLists = UserDefaults.getSavedPlaylists()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(MovieCell.nib(), forCellReuseIdentifier:  MovieCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchMovies()
    }
    
    fileprivate func fetchMovies() {
        MovieAPIService.getItemsFromJSON { [weak self] (movies) in
            
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                strongSelf.movies = movies
                strongSelf.tableView.reloadData()
            }
        }
    }
}


extension MovieViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.identifier, for: indexPath) as! MovieCell
        
        let movie = movies[indexPath.row]
        let viewModel = MovieViewModel(imagePath: movie.imagePath, title: movie.title, rating: movie.rating, playlist: nil)
        cell.configureView(viewModel)
        cell.delegate = self
        
        return cell
    }
}

extension MovieViewController: MovieCellDelegate {
    func shouldFavourite(_ cell: MovieCell, movie: String, val: Bool) {
        print(movie)

        let alert = UIAlertController(title: "Playlists", message: nil, preferredStyle: .actionSheet)

//        for playList in playlists {
//
//        }
    }
}
//
//
//extension UserDefaults {
//
//    private class func playlistsKey() -> String { return "playlistsKey" }
//    public class func getSavedPlaylists()-> [String: String] {
//
//    }
//    public class func addMovieToPlaylist(movie: String, playlist: String) {
//
//    }
//}
