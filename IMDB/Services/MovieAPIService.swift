//
//  MovieAPIService.swift
//  IMDB
//
//  Created by Sanket  Ray on 10/09/22.
//

import Foundation


class MovieAPIService {
    
    
    public class func getItems(completion: @escaping (_ movies: [Movie]) -> Void) {
        
        
        let parameters = ""
        let postData =  parameters.data(using: .utf8)
        
        var request = URLRequest(url: URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=38a73d59546aa378980a88b645f487fc")!,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        request.httpBody = postData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                
                // JSON Validation
                guard let json = json else { return }
                
                if let movies = json["results"] as? [[String: AnyHashable]] {
                    
                    var movieArray = [Movie]()
                    
                    for movie in movies {
                        
                        // Validations
                        guard let imagePath = movie["backdrop_path"] as? String,
                              let title = movie["title"] as? String,
                              let rating = movie["vote_average"] as? Double,
                              let id = movie["id"] as? Int else { return }
                        
                        // Create Movie
                        let movie = Movie(imagePath: imagePath, title: title, rating: rating, id: String(id), playlist: nil)
                        
                        // Add Movie
                        movieArray.append(movie)
                    }
                    
                    // Call Completion
                    completion(movieArray)
                }
                
            } catch {
                print("errorMsg")
            }
            
        }
        
        task.resume()
    }
}
