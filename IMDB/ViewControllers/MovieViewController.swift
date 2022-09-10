//
//  MovieViewController.swift
//  IMDB
//
//  Created by Sanket  Ray on 10/09/22.
//

import UIKit

class MovieViewController: UIViewController {
    
    
    // MARK: - Variables
    @IBOutlet var tableView: UITableView!
    @IBOutlet var filterContainerView: UIView!
    @IBOutlet var filterButton: UIButton!
    
    private var movies = [Movie]() {
        didSet {
            filteredMovies = movies
        }
    }
    private var filteredMovies = [Movie]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    private var dictionary = UserDefaults.getDictionary() {
        didSet {
            UserDefaults.savePlaylist(movieDictionary: dictionary)
        }
    }
    
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(MovieCell.nib(), forCellReuseIdentifier:  MovieCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchMovies { [weak self] in
            self?.updatePlaylistOfMovies()
        }
    }
    
    
    // MARK: - Helper Methods
    fileprivate func fetchMovies(completion: @escaping ()->()) {
        MovieAPIService.getItems { [weak self] (movies) in
            
            DispatchQueue.main.async {
                self?.movies = movies
                completion()
            }
        }
    }
    fileprivate func updatePlaylistOfMovies() {
        var tempMovies = [Movie]()
        for i in 0..<self.movies.count {
            var movie = self.movies[i]
            if let playlistName = self.dictionary[movie.id] {
                movie.playlist = playlistName
            }
            tempMovies.append(movie)
        }
        self.movies = tempMovies
    }
    
    
    
    // MARK: - Button Click Events
    @IBAction func filterButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Playlists", message: nil, preferredStyle: .actionSheet)
        
        for playlist in Set(dictionary.values) {
            let playlistAction = UIAlertAction(title: playlist, style: .default) { action in
                var filteredMovies = [Movie]()
                for movie in self.movies where movie.playlist == playlist {
                    filteredMovies.append(movie)
                }
                self.filteredMovies = filteredMovies
            }
            alert.addAction(playlistAction)
        }
        
        let clearAction = UIAlertAction(title: "Clear", style: .destructive) { action in
            self.filteredMovies = self.movies
        }
        alert.addAction(clearAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
}


// MARK: - UITableViewDelegate
extension MovieViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.identifier, for: indexPath) as! MovieCell
        
        let movie = filteredMovies[indexPath.row]
        let viewModel = MovieViewModel(imagePath: movie.imagePath, title: movie.title, rating: movie.rating, id: movie.id, playlist: nil)
        cell.configureView(viewModel)
        cell.delegate = self
        
        return cell
    }
}


// MARK: - MovieCellDelegate
extension MovieViewController: MovieCellDelegate {
    
    func showAddPlaylistAlert(for movie: Movie) {
        let alert = UIAlertController(title: "New Playlist", message: "Enter the new playlist name", preferredStyle: .alert)
        
        // Add the text field
        alert.addTextField { (textField) in
            textField.placeholder = "Type name..."
        }
        
        // Grab the value from the text field
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            
            if let playlistName = textField?.text,
                !playlistName.isEmpty {
                
                self.dictionary[movie.id] = playlistName
            }
        }))
        
        DispatchQueue.main.async {
            
            // Present the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func shouldFavourite(_ cell: MovieCell, movie: Movie, val: Bool) {
        
        let alert = UIAlertController(title: "Playlists", message: nil, preferredStyle: .actionSheet)
        
        for playlist in Set(dictionary.values) {
            let playlistAction = UIAlertAction(title: playlist, style: .default) { action in
                self.dictionary[movie.id] = playlist
            }
            alert.addAction(playlistAction)
        }
        
        let addToPlayListAction = UIAlertAction(title: "Add To Playlist +", style: .default) { action in
            // Open text field alert to store playlist
            
            self.showAddPlaylistAlert(for: movie)
        }
        
        alert.addAction(addToPlayListAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
}


// MARK: - UserDefaults
extension UserDefaults {
    
    class func savePlaylist(movieDictionary: [String: String]) {
        
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(movieDictionary),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            UserDefaults.standard.set(jsonString, forKey: "movieDictionaryKey")
        }
    }
    
    class func getDictionary() -> [String: String] {
        
        if let jsonString = UserDefaults.standard.value(forKey: "movieDictionaryKey") as? String,
           let data = jsonString.data(using: .utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                    return json
                }
            } catch {
                print("Something went wrong")
            }
        }
        
        return [:]
    }
}
