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
        btnBuyTicket.layer.cornerRadius = btnBuyTicket.frame.size.width / 2.0
    }
    
}

extension MovieTVCell {
    
    func configure() {
        
    }
    
}
