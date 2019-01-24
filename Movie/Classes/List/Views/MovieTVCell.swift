//
//  MovieTVCell.swift
//  Movie
//
//  Created by mac-0007 on 22/01/19.
//  Copyright © 2019 mac-0007. All rights reserved.
//

import UIKit
import Cosmos

class MovieTVCell: UITableViewCell {

    @IBOutlet fileprivate weak var imgVMovie: UIImageView!
    @IBOutlet fileprivate weak var lblMovieName: GenericLabel!
    @IBOutlet fileprivate weak var viewRating: CosmosView!
    @IBOutlet fileprivate weak var lblRating: GenericLabel!
    @IBOutlet fileprivate weak var viewAgeCategory: UIView!
    @IBOutlet fileprivate weak var lblAgeCategory: GenericLabel!
    @IBOutlet fileprivate weak var lblReleaseDate: GenericLabel!
    @IBOutlet fileprivate weak var lblMovieDescription: GenericLabel!
    @IBOutlet fileprivate weak var btnBuyTicket: GenericButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        imgVMovie.layer.cornerRadius = round(CScreenWidth * (16 / 375))
        
        btnBuyTicket.layoutIfNeeded()
        btnBuyTicket.layer.cornerRadius = btnBuyTicket.frame.size.height / 2.0
        
        viewAgeCategory.layoutIfNeeded()
        viewAgeCategory.layer.cornerRadius = viewAgeCategory.frame.size.height / 2.0
        viewAgeCategory.layer.borderColor = UIColor.gray.cgColor
        viewAgeCategory.layer.borderWidth = 1.0
    }
    
}

extension MovieTVCell {
    
    func configure(movie: MovieModel) {
        
        lblMovieName.text = movie.title ?? ""
        lblAgeCategory.text = movie.ageCategory ?? ""
        lblMovieDescription.text = movie.movieDescription ?? ""
        lblReleaseDate.text = ListViewModel.shared.stringReleaseDate(fromTimeInterval: movie.releaseDate ?? 0)
        
        if let rate = movie.rate {
            //... Divide by 2. Because rate (1 to 10) to show in range(1 to 5)
            viewRating.rating = Double(rate / 2) 
            lblRating.text = "\(rate)"
        }
        
        if let imgURL = URL(string: movie.posterPath ?? "") {
            imgVMovie.kf.setImage(with:imgURL)
        }
        
    }
    
}
