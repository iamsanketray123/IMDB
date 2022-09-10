//
//  MovieCell.swift
//  IMDB
//
//  Created by Sanket  Ray on 10/09/22.
//

import UIKit
import Kingfisher

protocol MovieCellDelegate {
    func shouldFavourite(_ cell: MovieCell, movie: Movie, val: Bool)
}

class MovieCell: UITableViewCell {
    
    
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var rating: UILabel!
    @IBOutlet var playlist: UILabel!
    @IBOutlet var star: UIImageView!
    
    static let identifier = "movieCell"
    static func nib() -> UINib {
        return UINib(nibName: "MovieCell", bundle: nil)
    }
    
    private var viewModel: MovieViewModel?
    
    public var delegate: MovieCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func configureView(_ viewModel: MovieViewModel) {
        
        self.viewModel = viewModel
        star.image = UIImage(systemName: "star")
        
        let imagePath = viewModel.imagePath
        let imageString = "https://image.tmdb.org/t/p/w500" + imagePath
        let imageURL = URL(string: imageString)!
        
        backgroundImage.kf.cancelDownloadTask()
        backgroundImage.kf.setImage(with: imageURL)
        
        title.text = viewModel.title
        rating.text = "\(viewModel.rating)"
        playlist.text = viewModel.playlist
        playlist.isHidden = viewModel.playlist == nil
    }
    
    @IBAction func starButtonTapped(_ sender: Any) {
        
        // Validation
        guard let viewModel = viewModel else { return }
        
        // Call Delegate Method
        delegate?.shouldFavourite(self, movie: Movie(imagePath: viewModel.imagePath, title: viewModel.title, rating: viewModel.rating, id: viewModel.id, playlist: viewModel.playlist), val: true)
    }
}
